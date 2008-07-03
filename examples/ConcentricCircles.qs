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


function CircleWidget(parent)
{
    QWidget.call(this, parent);

    this.floatBased = false;
    this.antialiased = false;
    this.frameNo = 0;

    this.setBackgroundRole(QPalette.Base);
    this.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding);
}

CircleWidget.prototype = new QWidget();

CircleWidget.prototype.setFloatBased = function(floatBased)
{
    this.floatBased = floatBased;
    this.update();
}

CircleWidget.prototype.setAntialiased = function(antialiased)
{
    this.antialiased = antialiased;
    this.update();
}

CircleWidget.prototype.getMinimumSizeHint = function()
{
    return new QSize(50, 50);
}

CircleWidget.prototype.getSizeHint = function()
{
    return new QSize(180, 180);
}

CircleWidget.prototype.nextAnimationFrame = function()
{
    ++this.frameNo;
    this.update();
}

CircleWidget.prototype.paintEvent = function(/* event */)
{
    var painter = new QPainter();
    painter.begin(this);
    painter.setRenderHint(QPainter.Antialiasing, this.antialiased);
    painter.translate(this.width / 2, this.height / 2);

    for (var diameter = 0; diameter < 256; diameter += 9) {
        var delta = Math.abs((this.frameNo % 128) - diameter / 2);
        var alpha = 255 - (delta * delta) / 4 - diameter;
        if (alpha > 0) {
            painter.setPen(new QPen(new QColor(0, diameter / 2, 127, alpha), 3));

            if (this.floatBased) {
                painter.drawEllipse(new QRectF(-diameter / 2.0, -diameter / 2.0,
                                               diameter, diameter));
            } else {
                painter.drawEllipse(new QRect(-diameter / 2, -diameter / 2,
                                              diameter, diameter));
            }
        }
    }

    painter.end();
}


function Window(parent)
{
    QWidget.call(this, parent);

    var aliasedLabel = this.createLabel(tr("Aliased"));
    var antialiasedLabel = this.createLabel(tr("Antialiased"));
    var intLabel = this.createLabel(tr("Int"));
    var floatLabel = this.createLabel(tr("Float"));

    var layout = new QGridLayout();
    layout.addWidget(aliasedLabel, 0, 1);
    layout.addWidget(antialiasedLabel, 0, 2);
    layout.addWidget(intLabel, 1, 0);
    layout.addWidget(floatLabel, 2, 0);

    var timer = new QTimer(this);

    for (var i = 0; i < 2; ++i) {
        for (var j = 0; j < 2; ++j) {
            var cw = new CircleWidget();
            cw.setAntialiased(j != 0);
            cw.setFloatBased(i != 0);

            timer.timeout.connect(
                    cw, cw.nextAnimationFrame);

            layout.addWidget(cw, i + 1, j + 1);
        }
    }
    timer.start(100);
    this.setLayout(layout);

    this.windowTitle = tr("Concentric Circles");
}

Window.prototype = new QWidget();

Window.prototype.createLabel = function(text)
{
    var label = new QLabel(text);
    label.alignment = Qt.AlignCenter;
    label.margin = 2;
    label.setFrameStyle(QFrame.Box | QFrame.Sunken);
    return label;
}

var win = new Window();
win.show();
QCoreApplication.exec();
