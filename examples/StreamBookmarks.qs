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

function tr(s) { return s; }


function XbelWriter(treeWidget)
{
    QXmlStreamWriter.call(this);
    this.treeWidget = treeWidget;
    this.setAutoFormatting(true);
}

XbelWriter.prototype = new QXmlStreamWriter();

XbelWriter.prototype.writeFile = function(device)
{
    this.setDevice(device);

    this.writeStartDocument();
    this.writeDTD("<!DOCTYPE xbel>");
    this.writeStartElement("xbel");
    this.writeAttribute("version", "1.0");
    for (var i = 0; i < this.treeWidget.topLevelItemCount; ++i)
        this.writeItem(this.treeWidget.topLevelItem(i));

    this.writeEndDocument();
    return true;
}

XbelWriter.prototype.writeItem = function(item)
{
    var tagName = item.data(0, Qt.UserRole);
    if (tagName == "folder") {
        var folded = !item.isExpanded();
        this.writeStartElement(tagName);
        this.writeAttribute("folded", folded ? "yes" : "no");
        this.writeTextElement("title", item.text(0));
        for (var i = 0; i < item.childCount(); ++i)
            this.writeItem(item.child(i));
        this.writeEndElement();
    } else if (tagName == "bookmark") {
        this.writeStartElement(tagName);
        if (item.text(1) != "")
            this.writeAttribute("href", item.text(1));
        this.writeTextElement("title", item.text(0));
        this.writeEndElement();
    } else if (tagName == "separator") {
        this.writeEmptyElement(tagName);
    }
}



function XbelReader(treeWidget)
{
    QXmlStreamReader.call(this);
    this.treeWidget = treeWidget;

    var style = treeWidget.style();

    this.folderIcon = new QIcon();
    this.folderIcon.addPixmap(style.standardPixmap(QStyle.SP_DirClosedIcon),
                         QIcon.Normal, QIcon.Off);
    this.folderIcon.addPixmap(style.standardPixmap(QStyle.SP_DirOpenIcon),
                         QIcon.Normal, QIcon.On);
    this.bookmarkIcon = new QIcon();
    this.bookmarkIcon.addPixmap(style.standardPixmap(QStyle.SP_FileIcon));
}

XbelReader.prototype = new QXmlStreamReader();

XbelReader.prototype.read = function(device)
{
    this.setDevice(device);

    while (!this.atEnd()) {
        this.readNext();

        if (this.isStartElement()) {
            if (this.name() == "xbel" && this.attributes().value("version") == "1.0")
                this.readXBEL();
            else
                this.raiseError(tr("The file is not an XBEL version 1.0 file."));
        }
    }

    return this.error() == QXmlStreamReader.NoError;
}

XbelReader.prototype.readUnknownElement = function()
{
    while (!this.atEnd()) {
        this.readNext();

        if (this.isEndElement())
            break;

        if (this.isStartElement())
            this.readUnknownElement();
    }
}

XbelReader.prototype.readXBEL = function()
{
//    Q_ASSERT(isStartElement() && name() == "xbel");

    while (!this.atEnd()) {
        this.readNext();

        if (this.isEndElement())
            break;

        if (this.isStartElement()) {
            if (this.name() == "folder")
                this.readFolder(null);
            else if (name() == "bookmark")
                this.readBookmark(null);
            else if (name() == "separator")
                this.readSeparator(null);
            else
                this.readUnknownElement();
        }
    }
}

XbelReader.prototype.readTitle = function(item)
{
//    Q_ASSERT(isStartElement() && name() == "title");

    var title = this.readElementText();
    item.setText(0, title);
}

XbelReader.prototype.readSeparator = function(item)
{
    var separator = this.createChildItem(item);
    separator.setFlags(Qt.ItemFlags(item.flags() & ~Qt.ItemIsSelectable));
    separator.setText(0, "---" /*QString(30, 0xB7)*/);
    this.readElementText();
}

XbelReader.prototype.readFolder = function(item)
{
//    Q_ASSERT(isStartElement() && name() == "folder");

    var folder = this.createChildItem(item);
    var folded = (this.attributes().value("folded") != "no");
    folder.setExpanded(!folded);

    while (!this.atEnd()) {
        this.readNext();

        if (this.isEndElement())
            break;

        if (this.isStartElement()) {
            if (this.name() == "title")
                this.readTitle(folder);
            else if (this.name() == "folder")
                this.readFolder(folder);
            else if (this.name() == "bookmark")
                this.readBookmark(folder);
            else if (this.name() == "separator")
                this.readSeparator(folder);
            else
                this.readUnknownElement();
        }
    }
}

XbelReader.prototype.readBookmark = function(item)
{
//    Q_ASSERT(isStartElement() && name() == "bookmark");

    var bookmark = this.createChildItem(item);
    bookmark.setFlags(Qt.ItemFlags(bookmark.flags() | Qt.ItemIsEditable));
    bookmark.setIcon(0, this.bookmarkIcon);
    bookmark.setText(0, tr("Unknown title"));
    bookmark.setText(1, this.attributes().value("href"));
    while (!this.atEnd()) {
        this.readNext();

        if (this.isEndElement())
            break;

        if (this.isStartElement()) {
            if (this.name() == "title")
                this.readTitle(bookmark);
            else
                this.readUnknownElement();
        }
    }
}

XbelReader.prototype.createChildItem = function(item)
{
    var childItem;
    if (item) {
        childItem = new QTreeWidgetItem(item);
    } else {
// ###       childItem = new QTreeWidgetItem(this.treeWidget);
        childItem = new QTreeWidgetItem();
        this.treeWidget.addTopLevelItem(childItem);
    }
    childItem.setData(0, Qt.UserRole, this.name());
    return childItem;
}



function MainWindow()
{
    QMainWindow.call(this);

    var labels = new Array();
    labels.push(tr("Title"));
    labels.push(tr("Location"));

    this.treeWidget = new QTreeWidget();
    this.treeWidget.header().setResizeMode(QHeaderView.Stretch);
    this.treeWidget.setHeaderLabels(labels);
    this.setCentralWidget(this.treeWidget);

    this.createActions();
    this.createMenus();

    this.statusBar().showMessage(tr("Ready"));

    this.windowTitle = tr("QXmlStream Bookmarks");
    this.resize(480, 320);
}

MainWindow.prototype = new QMainWindow();

MainWindow.prototype.open = function()
{
    var fileName =
            QFileDialog.getOpenFileName(this, tr("Open Bookmark File"),
                                         QDir.currentPath(),
                                         tr("XBEL Files (*.xbel *.xml)"));
    if (fileName == "")
        return;

    this.treeWidget.clear();


    var file = new QFile(fileName);
    if (!file.open(QIODevice.OpenMode(QIODevice.ReadOnly, QIODevice.Text))) {
        QMessageBox.warning(this, tr("QXmlStream Bookmarks"),
                             tr("Cannot read file %1:\n%2.")
                             .arg(fileName)
                             .arg(file.errorString()));
        return;
    }

    var reader = new XbelReader(this.treeWidget);
    if (!reader.read(file)) {
        QMessageBox.warning(this, tr("QXmlStream Bookmarks"),
                            tr("Parse error in file " + fileName + " at line " + reader.lineNumber()
                               + ", column " + reader.columnNumber() + ":\n" + reader.errorString()));
    } else {
        this.statusBar().showMessage(tr("File loaded"), 2000);
    }

}

MainWindow.prototype.saveAs = function()
{
    var fileName =
            QFileDialog.getSaveFileName(this, tr("Save Bookmark File"),
                                         QDir.currentPath(),
                                         tr("XBEL Files (*.xbel *.xml)"));
    if (fileName == "")
        return;

    var file = new QFile(fileName);
    if (!file.open(QIODevice.OpenMode(QIODevice.WriteOnly, QIODevice.Text))) {
        QMessageBox.warning(this, tr("QXmlStream Bookmarks"),
                             tr("Cannot write file %1:\n%2.")
                             .arg(fileName)
                             .arg(file.errorString()));
        return;
    }

    var writer = new XbelWriter(this.treeWidget);
    if (writer.writeFile(file))
        this.statusBar().showMessage(tr("File saved"), 2000);
}

MainWindow.prototype.about = function()
{
   QMessageBox.about(this, tr("About QXmlStream Bookmarks"),
            tr("The <b>QXmlStream Bookmarks</b> example demonstrates how to use Qt's QXmlStream classes to read and write XML documents."));
}

MainWindow.prototype.createActions = function()
{
    this.openAct = new QAction(tr("&Open..."), this);
    this.openAct.shortcut = tr("Ctrl+O");
    this.openAct.triggered.connect(this, this.open);

    this.saveAsAct = new QAction(tr("&Save As..."), this);
    this.saveAsAct.shortcut = tr("Ctrl+S");
    this.saveAsAct.triggered.connect(this, this.saveAs);

    this.exitAct = new QAction(tr("E&xit"), this);
    this.exitAct.shortcut = tr("Ctrl+Q");
    this.exitAct.triggered.connect(this, this.close);

    this.aboutAct = new QAction(tr("&About"), this);
    this.aboutAct.triggered.connect(this, this.about);

    this.aboutQtAct = new QAction(tr("About &Qt"), this);
// ###    this.aboutQtAct.triggered.connect(QApplication.aboutQt);
    this.aboutQtAct.triggered.connect(qApp.aboutQt);
}

MainWindow.prototype.createMenus = function()
{
    this.fileMenu = this.menuBar().addMenu(tr("&File"));

// ### working around bug in QMenu.prototype.addAction
    QMenu.prototype.addAction = QWidget.prototype.addAction;

    this.fileMenu.addAction(this.openAct);
    this.fileMenu.addAction(this.saveAsAct);
    this.fileMenu.addAction(this.exitAct);

    this.menuBar().addSeparator();

    this.helpMenu = this.menuBar().addMenu(tr("&Help"));
    this.helpMenu.addAction(this.aboutAct);
    this.helpMenu.addAction(this.aboutQtAct);
}


var mainWin = new MainWindow();
mainWin.show();
mainWin.open();
QCoreApplication.exec();
