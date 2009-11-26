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

#include <QtScript>

#include <QtCore/QFile>
#include <QtCore/QTextStream>
#include <QtCore/QStringList>
#include <QtCore/QCoreApplication>
#include <QtCore/QSet>
#include <QtDebug>

namespace {

void printUsage()
{
    QFile info(QCoreApplication::applicationDirPath()+"/README.TXT");
    if (!info.exists() || !info.open(QFile::ReadOnly)) {
        qDebug() << "Can't read README.TXT";
    } else {
        QTextStream stream(&info);
        qDebug() << stream.readAll();
        info.close();
    }
}

bool loadFile(QString fileName, QScriptEngine *engine)
{
    // avoid loading files more than once
    static QSet<QString> loadedFiles;
    QFileInfo fileInfo(fileName);
    QString absoluteFileName = fileInfo.absoluteFilePath();
    QString absolutePath = fileInfo.absolutePath();
    QString canonicalFileName = fileInfo.canonicalFilePath();
    if (loadedFiles.contains(canonicalFileName)) {
        return true;
    }
    loadedFiles.insert(canonicalFileName);
    QString path = fileInfo.path();

    // load the file
    QFile file(fileName);
    if (file.open(QFile::ReadOnly)) {
        QTextStream stream(&file);
        QString contents = stream.readAll();
        file.close();

        int endlineIndex = contents.indexOf('\n');
        QString line = contents.left(endlineIndex);
        int lineNumber = 1;

        // strip off #!/usr/bin/env qscript line
        if (line.startsWith("#!")) {
            contents.remove(0, endlineIndex+1);
            ++lineNumber;
        }

        // set qt.script.absoluteFilePath
        QScriptValue script = engine->globalObject().property("qs").property("script");
        QScriptValue oldFilePathValue = script.property("absoluteFilePath");
        QScriptValue oldPathValue = script.property("absolutePath");
        script.setProperty("absoluteFilePath", engine->toScriptValue(absoluteFileName));
        script.setProperty("absolutePath", engine->toScriptValue(absolutePath));

        QScriptValue r = engine->evaluate(contents, fileName, lineNumber);
        if (engine->hasUncaughtException()) {
            QStringList backtrace = engine->uncaughtExceptionBacktrace();
            qDebug() << QString("    %1\n%2\n\n").arg(r.toString()).arg(backtrace.join("\n"));
            return true;
        }
        script.setProperty("absoluteFilePath", oldFilePathValue); // if we come from includeScript(), or whereever
        script.setProperty("absolutePath", oldPathValue); // if we come from includeScript(), or whereever
    } else {
        return false;
    }
    return true;
}

QScriptValue includeScript(QScriptContext *context, QScriptEngine *engine)
{
    QString currentFileName = engine->globalObject().property("qs").property("script").property("absoluteFilePath").toString();
    QFileInfo currentFileInfo(currentFileName);
    QString path = currentFileInfo.path();
    QString importFile = context->argument(0).toString();
    QFileInfo importInfo(importFile);
    if (importInfo.isRelative()) {
        importFile =  path + "/" + importInfo.filePath();
    }
    if (!loadFile(importFile, engine)) {
        return context->throwError(QString("Failed to resolve include: %1").arg(importFile));
    }
    return engine->toScriptValue(true);
}

QScriptValue importExtension(QScriptContext *context, QScriptEngine *engine)
{
    return engine->importExtension(context->argument(0).toString());
}

bool stopInteractiveMode;

QScriptValue exitInteractiveMode(QScriptContext *context, QScriptEngine *engine)
{
    Q_UNUSED(context);
    stopInteractiveMode = true;
    return engine->undefinedValue();
}
void interactiveMode(QScriptEngine *engine)
{
    engine->globalObject().setProperty("quit", engine->newFunction(exitInteractiveMode));
    qDebug() << "Running in interactive mode. Press Ctrl+C or call quit() to stop.";

    QTextStream input(stdin, QFile::ReadOnly);
    const char *qtScriptPrompt = "qs> ";
    const char *dotPrompt = ".... ";
    const char *prompt = qtScriptPrompt;
    QString code;
    stopInteractiveMode = false;
    while (!stopInteractiveMode) {
        QString line;
        printf("%s", prompt);
        fflush(stdout);
        line = input.readLine();
        if (line.isNull())
            break;
        code += line;
        code += QLatin1Char('\n');
        if (line.trimmed().isEmpty()) {
            continue;
        } else if (!engine->canEvaluate(code)) {
            prompt = dotPrompt;
        } else {
            QScriptValue result = engine->evaluate(code, QLatin1String("stdin"));
            code.clear();
            prompt = qtScriptPrompt;
            if (!result.isUndefined())
                fprintf(stderr, "%s\n", qPrintable(result.toString()));
        }
    }
}

} // namespace

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    QStringList paths = QStringList() << QCoreApplication::applicationDirPath() + "/../../plugins";
    app.setLibraryPaths(paths);

    QScriptEngine *engine = new QScriptEngine();

    QScriptValue global = engine->globalObject();
    // add the qt object
    global.setProperty("qs", engine->newObject());
    // add a 'script' object
    QScriptValue script = engine->newObject();
    global.property("qs").setProperty("script", script);
    // add a 'system' object
    QScriptValue system = engine->newObject();
    global.property("qs").setProperty("system", system);

    // add os information to qt.system.os
#ifdef Q_OS_WIN32
    QScriptValue osName = engine->toScriptValue(QString("windows"));
#elif defined(Q_OS_LINUX)
    QScriptValue osName = engine->toScriptValue(QString("linux"));
#elif defined(Q_OS_MAC)
    QScriptValue osName = engine->toScriptValue(QString("mac"));
#elif defined(Q_OS_UNIX)
    QScriptValue osName = engine->toScriptValue(QString("unix"));
#endif
    system.setProperty("os", osName);

    // add environment variables to qt.system.env
    QMap<QString,QVariant> envMap;
    QStringList envList = QProcess::systemEnvironment();
    foreach (const QString &entry, envList) {
        QStringList keyVal = entry.split('=');
        if (keyVal.size() == 1)
            envMap.insert(keyVal.at(0), QString());
        else
            envMap.insert(keyVal.at(0), keyVal.at(1));
    }
    system.setProperty("env", engine->toScriptValue(envMap));

    // add the include functionality to qt.script.include
    script.setProperty("include", engine->newFunction(includeScript));
    // add the importExtension functionality to qt.script.importExtension
    script.setProperty("importExtension", engine->newFunction(importExtension));

    QStringList args = QCoreApplication::arguments();
    args.takeFirst();
    if (args.isEmpty()) {
        interactiveMode(engine);
    } else if (args.size() == 1 &&
            (args.at(0) == "-help" || args.at(0) == "--help" || args.at(0) == "-h" || args.at(0) == "/h")) {
        printUsage();
    } else { // read script file and execute

        QStringList files;
        bool singlefile = (args.at(0) != "-f");
        if (singlefile) {
            files << args.takeFirst();
            // add arguments to qt.script.arguments
            script.setProperty("args", engine->toScriptValue(args));
        } else {
            args.takeFirst();
            files += args;
        }

        foreach (const QString &fileName, files) {
            if (!loadFile(fileName, engine)) {
                qDebug() << "Failed:" << fileName;
                return EXIT_FAILURE;
            }
        }
    }
    delete engine;
    return EXIT_SUCCESS;
}
