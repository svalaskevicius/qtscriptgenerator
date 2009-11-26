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
