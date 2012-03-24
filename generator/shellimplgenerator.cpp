/****************************************************************************
**
** Copyright (C) 2008-2009 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Script Generator project on Qt Labs.
**
** $QT_BEGIN_LICENSE:LGPL$
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions
** contained in the Technology Preview License Agreement accompanying
** this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
**
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "shellimplgenerator.h"
#include "reporthandler.h"
#include "fileout.h"

extern void declareFunctionMetaTypes(QTextStream &stream,
                                     const AbstractMetaFunctionList &functions,
                                     QSet<QString> &registeredTypeNames);

QString ShellImplGenerator::fileNameForClass(const AbstractMetaClass *meta_class) const
{
    return QString("qtscriptshell_%1.cpp").arg(meta_class->name());
}

static bool include_less_than(const Include &a, const Include &b)
{
    return a.name < b.name;
}

static void writeHelperCode(QTextStream &s, const AbstractMetaClass *)
{
    s << "#define QTSCRIPT_IS_GENERATED_FUNCTION(fun) ((fun.data().toUInt32() & 0xFFFF0000) == 0xBABE0000)" << endl;
    s << endl;
}

void writeQtScriptQtBindingsLicense(QTextStream &stream);

void ShellImplGenerator::write(QTextStream &s, const AbstractMetaClass *meta_class)
{
    if (FileOut::license)
        writeQtScriptQtBindingsLicense(s);

    QString packName = meta_class->package().replace(".", "_");

    priGenerator->addSource(packName, fileNameForClass(meta_class));

    s << "#include \"qtscriptshell_" << meta_class->name() << ".h\"" << endl << endl;

    if (!meta_class->generateShellClass())
        return;

    s << "#include <QtScript/QScriptEngine>" << endl;

    IncludeList list = meta_class->typeEntry()->extraIncludes();
    qSort(list.begin(), list.end(), include_less_than);
    foreach (const Include &inc, list) {
        if (inc.type == Include::TargetLangImport)
            continue;

        s << "#include ";
        if (inc.type == Include::LocalPath)
            s << "\"";
        else
            s << "<";

        s << inc.name;

        if (inc.type == Include::LocalPath)
            s << "\"";
        else
            s << ">";

        s << endl;
    }
    s << endl;

    writeHelperCode(s, meta_class);

    // find constructors
    AbstractMetaFunctionList ctors;
    ctors = meta_class->queryFunctions(AbstractMetaClass::Constructors
                                       | AbstractMetaClass::WasVisible
                                       | AbstractMetaClass::NotRemovedFromTargetLang);
    // find member functions
    AbstractMetaFunctionList functions = meta_class->queryFunctions(
        AbstractMetaClass:: VirtualFunctions | AbstractMetaClass::WasVisible
        | AbstractMetaClass::NotRemovedFromTargetLang
        );

    // write metatype declarations
    {
        QSet<QString> registeredTypeNames = m_qmetatype_declared_typenames;
        declareFunctionMetaTypes(s, functions, registeredTypeNames);
        s << endl;
    }

    // write constructors
    foreach (const AbstractMetaFunction *ctor, ctors) {
        s << "QtScriptShell_" << meta_class->name() << "::";
        writeFunctionSignature(s, ctor, 0, QString(), Option(OriginalName | ShowStatic));
        s << endl;
        s << "    : " << meta_class->qualifiedCppName() << "(";
        AbstractMetaArgumentList args = ctor->arguments();
        for (int i = 0; i < args.size(); ++i) {
            if (i > 0)
                s << ", ";
            s << args.at(i)->argumentName();
        }
        s << ")" << " {}" << endl << endl;
    }

    // write destructor
    s << "QtScriptShell_" << meta_class->name() << "::"
      << "~QtScriptShell_" << meta_class->name() << "()";
    if (!meta_class->destructorException().isEmpty())
        s << " " << meta_class->destructorException();
    s << " {}" << endl << endl;

    // write member functions
    for (int i = 0; i < functions.size(); ++i) {
        AbstractMetaFunction *fun = functions.at(i);
        writeFunctionSignature(s, fun, meta_class, QString(),
                               Option(OriginalName | ShowStatic | UnderscoreSpaces),
                               "QtScriptShell_");
        s << endl << "{" << endl;
        QString scriptFunctionName = fun->name();
        {
            QPropertySpec *read = 0;
            for (const AbstractMetaClass *cls = meta_class; !read && cls; cls = cls->baseClass())
                read = cls->propertySpecForRead(fun->name());
            if (read && (read->name() == fun->name())) {
                // use different name to avoid infinite recursion
                // ### not sure if this is the best solution though...
                scriptFunctionName.prepend("_qs_");
            }
        }
        s << "    QScriptValue _q_function = __qtscript_self.property(\""
          << scriptFunctionName << "\");" << endl;
        s << "    if (!_q_function.isFunction() || QTSCRIPT_IS_GENERATED_FUNCTION(_q_function)" << endl
          << "        || (__qtscript_self.propertyFlags(\"" << scriptFunctionName << "\") & QScriptValue::QObjectMember)) {" << endl;

        AbstractMetaArgumentList args = fun->arguments();
        s << "        ";
        if (fun->isAbstract()) {
            s << "qFatal(\"" << meta_class->name() << "::" << fun->name()
              << "() is abstract!\");" << endl;
        } else {
            // call the C++ implementation
            if (fun->type())
                s << "return ";
            s << meta_class->qualifiedCppName() << "::" << fun->originalName() << "(";
            for (int i = 0; i < args.size(); ++i) {
                if (i > 0)
                    s << ", ";
                s << args.at(i)->argumentName();
            }
            s << ");" << endl;
        }

        s << "    } else {" << endl;

        // call the script function
        if (args.size() > 0)
            s << "        QScriptEngine *_q_engine = __qtscript_self.engine();" << endl;
        s << "        ";
        if (fun->type()) {
            s << "return qscriptvalue_cast<";
            writeTypeInfo(s, fun->type());
            s << ">(";
        }
        s << "_q_function.call(__qtscript_self";
        if (args.size() > 0) {
            s << "," << endl;
            s << "            QScriptValueList()";
            int i = 0;
            for (int j = 0; j < args.size(); ++j) {
                if (fun->argumentRemoved(j+1))
                    continue;
                s << endl << "            << ";
                s << "qScriptValueFromValue(_q_engine, ";
                AbstractMetaType *atype = args.at(j)->type();
                QString asig = atype->cppSignature();
                bool constCastArg = asig.endsWith('*') && asig.startsWith("const ");
                if (constCastArg) {
                    s << "const_cast<" << asig << ">(";
                }
                s << args.at(i)->argumentName() << ")";
                if (constCastArg)
                    s << ")";
                ++i;
            }
        }
        s << ")";
        if (fun->type())
            s << ")";
        s << ";" << endl;

        s << "    }" << endl;

        s << "}" << endl << endl;
    }
}

void ShellImplGenerator::writeInjectedCode(QTextStream &s, const AbstractMetaClass *meta_class)
{
    CodeSnipList code_snips = meta_class->typeEntry()->codeSnips();
    foreach (const CodeSnip &cs, code_snips) {
        if (cs.language == TypeSystem::ShellCode) {
            s << cs.code() << endl;
        }
    }
}
