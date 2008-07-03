/****************************************************************************
**
** Copyright (C) 2008 Trolltech ASA. All rights reserved.
**
** This file is part of the Qt Script Generator project on Trolltech Labs.
**
** This file may be used under the terms of the GNU General Public
** License version 2.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of
** this file.  Please review the following information to ensure GNU
** General Public Licensing requirements will be met:
** http://www.trolltech.com/products/qt/opensource.html
**
** If you are unsure which license is appropriate for your use, please
** review the following information:
** http://www.trolltech.com/products/qt/licensing.html or contact the
** sales department at sales@trolltech.com.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

function getArgumentValue(name, names, values, from)
{
    var i = (from == undefined) ? 0 : from;
    for ( ; i < names.length; ++i) {
        if (names[i] == name)
            return values[i];
    }
    return undefined;
}

//
// Plugin class
//

function MyWebPlugin(formUrl, scriptUrl, parent)
{
    QWidget.call(this, parent);

    this.initialized = false;
    this.formReply = this.downloadFile(formUrl, this.formDownloaded);
    if (scriptUrl == undefined)
        this.script = "";
    else
        this.scriptReply = this.downloadFile(scriptUrl, this.scriptDownloaded);
}

MyWebPlugin.prototype = new QWidget();

MyWebPlugin.prototype.downloadFile = function(url, callback)
{
    if (this.accessManager == undefined)
        this.accessManager = new QNetworkAccessManager();
    var reply = this.accessManager.get(new QNetworkRequest(url));
    reply.finished.connect(this, callback);
    return reply;
}

MyWebPlugin.prototype.formDownloaded = function()
{
    var loader = new QUiLoader();
    this.form = loader.load(this.formReply);
    var layout = new QVBoxLayout(this);
    layout.addWidget(this.form, 0, Qt.AlignCenter);
    this.initialize();
}

MyWebPlugin.prototype.scriptDownloaded = function()
{
    var stream = new QTextStream(this.scriptReply);
    this.script = stream.readAll();
    this.initialize();
}

MyWebPlugin.prototype.initialize = function()
{
    if (this.initialized)
        return;
    if ((this.form == undefined) || (this.script == undefined))
        return;
    var ctor = eval(this.script);
    if (typeof ctor != "function")
        return;
    this.instance = new ctor(this.form);
    this.initialized = true;
}


//
// QWebPluginFactory subclass
//

function MyWebPluginFactory(parent)
{
    QWebPluginFactory.call(this, parent);
}

MyWebPluginFactory.prototype = new QWebPluginFactory();

MyWebPluginFactory.prototype.create = function(mimeType, url, argumentNames, argumentValues)
{
    if (mimeType != "application/x-qtform")
        return null;

    var formUrl = getArgumentValue("form", argumentNames, argumentValues);
    var scriptUrl = getArgumentValue("script", argumentNames, argumentValues);
    if (formUrl == undefined)
        return null;

    return new MyWebPlugin(new QUrl(formUrl), new QUrl(scriptUrl));
}


//
// Main
//

var view = new QWebView();
view.settings().setAttribute(QWebSettings.PluginsEnabled, true);

var factory = new MyWebPluginFactory();
view.page().setPluginFactory(factory);

view.load(new QUrl("WebKitPlugins.html"));
view.show();

QCoreApplication.exec();
