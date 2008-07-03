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



function RenderArea(path, parent)
{
    QWidget.call(this, parent);

    this.path = path;
    this.penWidth = 1;
    this.rotationAngle = 0;
    this.setBackgroundRole(QPalette.Base);
}

RenderArea.prototype = new QWidget();

RenderArea.prototype.getMinimumSizeHint = function()
{
    return new QSize(50, 50);
}

RenderArea.prototype.getSizeHint = function()
{
    return new QSize(100, 100);
}

RenderArea.prototype.setFillRule = function(rule)
{
    this.path.setFillRule(rule);
    this.update();
}

RenderArea.prototype.setFillGradient = function(color1, color2)
{
    this.fillColor1 = color1;
    this.fillColor2 = color2;
    this.update();
}

RenderArea.prototype.setPenWidth = function(width)
{
    this.penWidth = width;
    this.update();
}

RenderArea.prototype.setPenColor = function(color)
{
    this.penColor = color;
    this.update();
}

RenderArea.prototype.setRotationAngle = function(degrees)
{
    this.rotationAngle = degrees;
    this.update();
}

RenderArea.prototype.paintEvent = function()
{
    var painter = new QPainter();
    painter.begin(this);
    painter.setRenderHint(QPainter.Antialiasing);
    painter.scale(this.width / 100.0, this.height / 100.0);
    painter.translate(50.0, 50.0);
    painter.rotate(-this.rotationAngle);
    painter.translate(-50.0, -50.0);

    painter.setPen(new QPen(this.penColor, this.penWidth, Qt.SolidLine, Qt.RoundCap,
                        Qt.RoundJoin));
    var gradient = new QLinearGradient(0, 0, 0, 100);
    gradient.setColorAt(0.0, this.fillColor1);
    gradient.setColorAt(1.0, this.fillColor2);
    painter.setBrush(new QBrush(gradient));
    painter.drawPath(this.path);
    painter.end();
}



function Window(parent)
{
    QWidget.call(this, parent);

    var rectPath = new QPainterPath();
    rectPath.moveTo(20.0, 30.0);
    rectPath.lineTo(80.0, 30.0);
    rectPath.lineTo(80.0, 70.0);
    rectPath.lineTo(20.0, 70.0);
    rectPath.closeSubpath();

    var roundRectPath = new QPainterPath();
    roundRectPath.moveTo(80.0, 35.0);
    roundRectPath.arcTo(70.0, 30.0, 10.0, 10.0, 0.0, 90.0);
    roundRectPath.lineTo(25.0, 30.0);
    roundRectPath.arcTo(20.0, 30.0, 10.0, 10.0, 90.0, 90.0);
    roundRectPath.lineTo(20.0, 65.0);
    roundRectPath.arcTo(20.0, 60.0, 10.0, 10.0, 180.0, 90.0);
    roundRectPath.lineTo(75.0, 70.0);
    roundRectPath.arcTo(70.0, 60.0, 10.0, 10.0, 270.0, 90.0);
    roundRectPath.closeSubpath();

    var ellipsePath = new QPainterPath();
    ellipsePath.moveTo(80.0, 50.0);
    ellipsePath.arcTo(20.0, 30.0, 60.0, 40.0, 0.0, 360.0);

    var piePath = new QPainterPath();
    piePath.moveTo(50.0, 50.0);
    piePath.arcTo(20.0, 30.0, 60.0, 40.0, 60.0, 240.0);
    piePath.closeSubpath();

    var polygonPath = new QPainterPath();
    polygonPath.moveTo(10.0, 80.0);
    polygonPath.lineTo(20.0, 10.0);
    polygonPath.lineTo(80.0, 30.0);
    polygonPath.lineTo(90.0, 70.0);
    polygonPath.closeSubpath();

    var groupPath = new QPainterPath();
    groupPath.moveTo(60.0, 40.0);
    groupPath.arcTo(20.0, 20.0, 40.0, 40.0, 0.0, 360.0);
    groupPath.moveTo(40.0, 40.0);
    groupPath.lineTo(40.0, 80.0);
    groupPath.lineTo(80.0, 80.0);
    groupPath.lineTo(80.0, 40.0);
    groupPath.closeSubpath();

    var textPath = new QPainterPath();
    var timesFont = new QFont("Times", 50);
    timesFont.setStyleStrategy(QFont.ForceOutline);
    textPath.addText(10, 70, timesFont, tr("Qt"));

    var bezierPath = new QPainterPath();
    bezierPath.moveTo(20, 30);
    bezierPath.cubicTo(80, 0, 50, 50, 80, 80);

    var starPath = new QPainterPath();
    starPath.moveTo(90, 50);
    for (var i = 1; i < 5; ++i) {
        starPath.lineTo(50 + 40 * Math.cos(0.8 * i * Math.PI),
                        50 + 40 * Math.sin(0.8 * i * Math.PI));
    }
    starPath.closeSubpath();

    this.renderAreas = new Array(Window.NumRenderAreas);
    this.renderAreas[0] = new RenderArea(rectPath);
    this.renderAreas[1] = new RenderArea(roundRectPath);
    this.renderAreas[2] = new RenderArea(ellipsePath);
    this.renderAreas[3] = new RenderArea(piePath);
    this.renderAreas[4] = new RenderArea(polygonPath);
    this.renderAreas[5] = new RenderArea(groupPath);
    this.renderAreas[6] = new RenderArea(textPath);
    this.renderAreas[7] = new RenderArea(bezierPath);
    this.renderAreas[8] = new RenderArea(starPath);

    this.fillRuleComboBox = new QComboBox();
    this.fillRuleComboBox.addItem(tr("Odd Even"), Qt.OddEvenFill);
    this.fillRuleComboBox.addItem(tr("Winding"), Qt.WindingFill);

    this.fillRuleLabel = new QLabel(tr("Fill &Rule:"));
    this.fillRuleLabel.setBuddy(this.fillRuleComboBox);

    this.fillColor1ComboBox = new QComboBox();
    this.populateWithColors(this.fillColor1ComboBox);
    this.fillColor1ComboBox.setCurrentIndex(
            this.fillColor1ComboBox.findText("mediumslateblue"));

    this.fillColor2ComboBox = new QComboBox();
    this.populateWithColors(this.fillColor2ComboBox);
    this.fillColor2ComboBox.setCurrentIndex(
            this.fillColor2ComboBox.findText("cornsilk"));

    this.fillGradientLabel = new QLabel(tr("&Fill Gradient:"));
    this.fillGradientLabel.setBuddy(this.fillColor1ComboBox);

    this.fillToLabel = new QLabel(tr("to"));
    this.fillToLabel.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed);

    this.penWidthSpinBox = new QSpinBox();
    this.penWidthSpinBox.setRange(0, 20);

    this.penWidthLabel = new QLabel(tr("&Pen Width:"));
    this.penWidthLabel.setBuddy(this.penWidthSpinBox);

    this.penColorComboBox = new QComboBox();
    this.populateWithColors(this.penColorComboBox);
    this.penColorComboBox.setCurrentIndex(
            this.penColorComboBox.findText("darkslateblue"));

    this.penColorLabel = new QLabel(tr("Pen &Color:"));
    this.penColorLabel.setBuddy(this.penColorComboBox);

    this.rotationAngleSpinBox = new QSpinBox();
    this.rotationAngleSpinBox.setRange(0, 359);
    this.rotationAngleSpinBox.wrapping = true;
    this.rotationAngleSpinBox.suffix = "\xB0";

    this.rotationAngleLabel = new QLabel(tr("&Rotation Angle:"));
    this.rotationAngleLabel.setBuddy(this.rotationAngleSpinBox);

    this.fillRuleComboBox["activated(int)"].connect(
            this, this.fillRuleChanged);
    this.fillColor1ComboBox["activated(int)"].connect(
            this, this.fillGradientChanged);
    this.fillColor2ComboBox["activated(int)"].connect(
            this, this.fillGradientChanged);
    this.penColorComboBox["activated(int)"].connect(
        this, this.penColorChanged);

    for (var i = 0; i < Window.NumRenderAreas; ++i) {
        this.penWidthSpinBox["valueChanged(int)"].connect(
                this.renderAreas[i], this.renderAreas[i].setPenWidth);
        this.rotationAngleSpinBox["valueChanged(int)"].connect(
                this.renderAreas[i], this.renderAreas[i].setRotationAngle);
    }

    var topLayout = new QGridLayout();
    for (var i = 0; i < Window.NumRenderAreas; ++i)
        topLayout.addWidget(this.renderAreas[i], i / 3, i % 3);

    var mainLayout = new QGridLayout();
    mainLayout.addLayout(topLayout, 0, 0, 1, 4);
    mainLayout.addWidget(this.fillRuleLabel, 1, 0);
    mainLayout.addWidget(this.fillRuleComboBox, 1, 1, 1, 3);
    mainLayout.addWidget(this.fillGradientLabel, 2, 0);
    mainLayout.addWidget(this.fillColor1ComboBox, 2, 1);
    mainLayout.addWidget(this.fillToLabel, 2, 2);
    mainLayout.addWidget(this.fillColor2ComboBox, 2, 3);
    mainLayout.addWidget(this.penWidthLabel, 3, 0);
    mainLayout.addWidget(this.penWidthSpinBox, 3, 1, 1, 3);
    mainLayout.addWidget(this.penColorLabel, 4, 0);
    mainLayout.addWidget(this.penColorComboBox, 4, 1, 1, 3);
    mainLayout.addWidget(this.rotationAngleLabel, 5, 0);
    mainLayout.addWidget(this.rotationAngleSpinBox, 5, 1, 1, 3);
    this.setLayout(mainLayout);

    this.fillRuleChanged();
    this.fillGradientChanged();
    this.penColorChanged();
    this.penWidthSpinBox.value = 2;

    this.windowTitle = tr("Painter Paths");
}

Window.NumRenderAreas = 9;

Window.prototype = new QWidget();

Window.prototype.fillRuleChanged = function()
{
    var rule = Qt.FillRule(this.currentItemData(this.fillRuleComboBox));

    for (var i = 0; i < Window.NumRenderAreas; ++i)
        this.renderAreas[i].setFillRule(rule);
}

Window.prototype.fillGradientChanged = function()
{
    var color1 = this.currentItemData(this.fillColor1ComboBox);
    var color2 = this.currentItemData(this.fillColor2ComboBox);

    for (var i = 0; i < Window.NumRenderAreas; ++i)
        this.renderAreas[i].setFillGradient(color1, color2);
}

Window.prototype.penColorChanged = function()
{
    var color = this.currentItemData(this.penColorComboBox);

    for (var i = 0; i < Window.NumRenderAreas; ++i)
        this.renderAreas[i].setPenColor(color);
}

Window.prototype.populateWithColors = function(comboBox)
{
    var colorNames = QColor.colorNames();
    for (var i = 0; i < colorNames.length; ++i) {
        var name = colorNames[i];
        comboBox.addItem(name, new QColor(name));
    }
}

Window.prototype.currentItemData = function(comboBox)
{
    return comboBox.itemData(comboBox.currentIndex);
}



var win = new Window();
win.show();
QCoreApplication.exec();
