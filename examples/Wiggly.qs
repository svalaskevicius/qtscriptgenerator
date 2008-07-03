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


function WigglyWidget(parent)
{
    QWidget.call(this, parent);

    this.setBackgroundRole(QPalette.Midlight);
    this.autoFillBackground = true;

    var newFont = new QFont(this.font);
    newFont.setPointSize(newFont.pointSize() + 20);
    this.font = newFont;

    this.step = 0;
    this.timer = new QBasicTimer();
    this.timer.start(60, this);
}

WigglyWidget.sineTable = new Array(0, 38, 71, 92, 100, 92, 71, 38, 0, -38, -71, -92, -100, -92, -71, -38);

WigglyWidget.prototype = new QWidget();

WigglyWidget.prototype.paintEvent = function(/* event */)
{
    var metrics = new QFontMetrics(this.font);
    var x = (this.width - metrics.width(this.text)) / 2;
    var y = (this.height + metrics.ascent() - metrics.descent()) / 2;
    var color = new QColor();

    var painter = new QPainter();
    painter.begin(this);
    for (var i = 0; i < this.text.length; ++i) {
        var index = (this.step + i) % 16;
        color.setHsv((15 - index) * 16, 255, 191);
        painter.setPen(new QPen(color));
        painter.drawText(x, y - ((WigglyWidget.sineTable[index] * metrics.height()) / 400),
                         this.text[i]);
        x += metrics.width(this.text[i]);
    }
    painter.end();
}

WigglyWidget.prototype.timerEvent = function(event)
{
    if (event.timerId() == this.timer.timerId()) {
        ++this.step;
        this.update();
    } else {
//	QWidget::timerEvent(event);
//      ### this.super_timerEvent(event);
    }
}

WigglyWidget.prototype.setText = function(newText)
{
    this.text = newText;
}


function Dialog(parent)
{
    QWidget.call(this, parent);

    var wigglyWidget = new WigglyWidget();
    var lineEdit = new QLineEdit();

    var layout = new QVBoxLayout();
    // ### workaround
    layout.addWidget(wigglyWidget, 0, Qt.AlignLeft);
    layout.addWidget(lineEdit, 0, Qt.AlignLeft);
    this.setLayout(layout);

    lineEdit.textChanged.connect(
            wigglyWidget, wigglyWidget.setText);

    lineEdit.text = tr("Hello world!");

    this.windowTitle = tr("Wiggly");
    this.resize(360, 145);
}

Dialog.prototype = new QDialog();


var dialog = new Dialog();
dialog.show();
QCoreApplication.exec();
