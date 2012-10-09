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

#include "shellheadergenerator.h"
#include "fileout.h"

#include <QtCore/QDir>

#include <qdebug.h>

QString ShellHeaderGenerator::fileNameForClass(const AbstractMetaClass *meta_class) const
{
    return QString("qtscriptshell_%1.h").arg(meta_class->name());
}

void writeQtScriptQtBindingsLicense(QTextStream &stream);

void ShellHeaderGenerator::write(QTextStream &s, const AbstractMetaClass *meta_class)
{
    if (FileOut::license)
        writeQtScriptQtBindingsLicense(s);

    QString include_block = "QTSCRIPTSHELL_" + meta_class->name().toUpper() + "_H";

    s << "#ifndef " << include_block << endl
      << "#define " << include_block << endl << endl;

    Include inc = meta_class->typeEntry()->include();
    s << "#include ";
    if (inc.type == Include::IncludePath)
        s << "<";
    else
        s << "\"";
    s << inc.name;
    if (inc.type == Include::IncludePath)
        s << ">";
    else
        s << "\"";
    s << endl << endl;

    s << "#include <QtScript/qscriptvalue.h>" << endl;
    s << "#include <__package_shared.h>" << endl;
    s << endl;

    QString packName = meta_class->package().replace(".", "_");

    if (!meta_class->generateShellClass()) {
        s << "#endif" << endl << endl;
        priGenerator->addHeader(packName, fileNameForClass(meta_class));
        return ;
    }

    s << "class " << shellClassName(meta_class)
      << " : public " << meta_class->qualifiedCppName() << endl
      << "{" << endl;


    s << "public:" << endl;
    foreach (const AbstractMetaFunction *function, meta_class->functions()) {
        if (function->isConstructor() && !function->isPrivate()) {
            s << "    ";
            writeFunctionSignature(s, function, 0, QString(),
                                   Option(IncludeDefaultExpression | OriginalName | ShowStatic));
            s << ";" << endl;
        }
    }

    s << "    ~" << shellClassName(meta_class) << "()";
    if (!meta_class->destructorException().isEmpty())
        s << " " << meta_class->destructorException();
    s << ";" << endl;
    s << endl;

    AbstractMetaFunctionList functions = meta_class->queryFunctions(
        AbstractMetaClass:: VirtualFunctions | AbstractMetaClass::WasVisible
        | AbstractMetaClass::NotRemovedFromTargetLang
        );

    for (int i = 0; i < functions.size(); ++i) {
        s << "    ";
        writeFunctionSignature(s, functions.at(i), 0, QString(),
                               Option(IncludeDefaultExpression | OriginalName | ShowStatic | UnderscoreSpaces));
        s << ";" << endl;
    }

    writeInjectedCode(s, meta_class);

    s  << endl << "    QScriptValue __qtscript_self;" << endl;

    s  << "};" << endl << endl
       << "#endif // " << include_block << endl;

    priGenerator->addHeader(packName, fileNameForClass(meta_class));
}

void ShellHeaderGenerator::writeInjectedCode(QTextStream &s, const AbstractMetaClass *meta_class)
{
    CodeSnipList code_snips = meta_class->typeEntry()->codeSnips();
    foreach (const CodeSnip &cs, code_snips) {
        if (cs.language == TypeSystem::ShellDeclaration) {
            s << cs.code() << endl;
        }
    }
}
