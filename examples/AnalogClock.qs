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

function AnalogClock(parent) {
    QWidget.call(this, parent);

    var timer = new QTimer(this);
    timer.timeout.connect(this, "update()");
    timer.start(1000);

    this.setWindowTitle("Analog Clock");
    this.resize(200, 200);
}

AnalogClock.prototype = new QWidget();

AnalogClock.prototype.paintEvent = function() {
    var side = Math.min(this.width, this.height);
    var time = new Date();

    var painter = new QPainter();
    painter.begin(this);
    painter.setRenderHint(QPainter.Antialiasing);
    painter.translate(this.width / 2, this.height / 2);
    painter.scale(side / 200.0, side / 200.0);

    painter.setPen(new QPen(Qt.NoPen));
    painter.setBrush(new QBrush(AnalogClock.hourColor));

    painter.save();
    painter.rotate(30.0 * ((time.getHours() + time.getMinutes() / 60.0)));
    painter.drawConvexPolygon(AnalogClock.hourHand);
    painter.drawLine(0, 0, 100, 100);
    painter.restore();

    painter.setPen(AnalogClock.hourColor);

    for (var i = 0; i < 12; ++i) {
        painter.drawLine(88, 0, 96, 0);
        painter.rotate(30.0);
    }

    painter.setPen(new QPen(Qt.NoPen));
    painter.setBrush(new QBrush(AnalogClock.minuteColor));

    painter.save();
    painter.rotate(6.0 * (time.getMinutes() + time.getSeconds() / 60.0));
    painter.drawConvexPolygon(AnalogClock.minuteHand);
    painter.restore();

    painter.setPen(AnalogClock.minuteColor);

    for (var j = 0; j < 60; ++j) {
        if ((j % 5) != 0)
	painter.drawLine(92, 0, 96, 0);
        painter.rotate(6.0);
    }
    painter.end();
};

AnalogClock.hourColor = new QColor(127, 0, 127);

AnalogClock.minuteColor = new QColor(0, 127, 127, 191);

AnalogClock.hourHand = new QPolygon([new QPoint(7, 8),
                                     new QPoint(-7, 8),
                                     new QPoint(0, -40)]);
AnalogClock.minuteHand = new QPolygon([new QPoint(7, 8),
                                       new QPoint(-7, 8),
                                       new QPoint(0, -70)]);

var clock = new AnalogClock();
clock.show();

QCoreApplication.exec();
