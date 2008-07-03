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


function DigitalClock(parent)
{
    QLCDNumber.call(this, parent);

    this.segmentStyle = QLCDNumber.Filled;

    var timer = new QTimer(this);
    timer.timeout.connect(this, this.showTime);
    timer.start(1000);

    this.showTime();

    this.windowTitle = tr("Digital Clock");
    this.resize(150, 60);
}

DigitalClock.prototype = new QLCDNumber();

DigitalClock.prototype.showTime = function()
{
    var time = QTime.currentTime();
    var format = "hh";
    format += ((time.second() % 2) == 0) ? " " : ":";
    format += "mm";
    var text = time.toString(format);
    this.display(text);
}


var clock = new DigitalClock(5); // ### fixme
clock.show();
QCoreApplication.exec();
