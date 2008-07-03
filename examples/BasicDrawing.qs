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



function RenderArea(parent)
{
    QWidget.call(this, parent);

    this.shape = RenderArea.Polygon;
    this.antialiased = false;
    this.transformed = false;
    this.pen = new QPen();
    this.brush = new QBrush();
    this.pixmap = new QPixmap("images/qt-logo.png");

    this.setBackgroundRole(QPalette.Base);
    this.autoFillBackground = true;
}

RenderArea.prototype = new QWidget();

RenderArea.Line = 0;
RenderArea.Points = 1;
RenderArea.Polyline = 2;
RenderArea.Polygon = 3;
RenderArea.Rect = 4;
RenderArea.RoundedRect = 5;
RenderArea.Ellipse = 6;
RenderArea.Arc = 7;
RenderArea.Chord = 8;
RenderArea.Pie = 9;
RenderArea.Path = 10;
RenderArea.Text = 11;
RenderArea.Pixmap = 12;

RenderArea.prototype.getMinimumSizeHint = function()
{
    return new QSize(100, 100);
}

RenderArea.prototype.getSizeHint = function()
{
    return new QSize(400, 200);
}

RenderArea.prototype.setShape = function(shape)
{
    this.shape = shape;
    this.update();
}

RenderArea.prototype.setPen = function(pen)
{
    this.pen = pen;
    this.update();
}

RenderArea.prototype.setBrush = function(brush)
{
    this.brush = brush;
    this.update();
}

RenderArea.prototype.setAntialiased = function(antialiased)
{
    this.antialiased = antialiased;
    this.update();
}

RenderArea.prototype.setTransformed = function(transformed)
{
    this.transformed = transformed;
    this.update();
}

RenderArea.prototype.paintEvent = function(/* event */)
{
    if (RenderArea.points == undefined) {
        RenderArea.points = new QPolygon();
        RenderArea.points.append(new QPoint(10, 80));
        RenderArea.points.append(new QPoint(20, 10));
        RenderArea.points.append(new QPoint(80, 30));
        RenderArea.points.append(new QPoint(90, 70));
    }

    var rect = new QRect(10, 20, 80, 60);

    var path = new QPainterPath();
    path.moveTo(20, 80);
    path.lineTo(20, 30);
    path.cubicTo(80, 0, 50, 50, 80, 80);

    var startAngle = 20 * 16;
    var arcLength = 120 * 16;

    var painter = new QPainter();
    painter.begin(this);
    painter.setPen(this.pen);
    painter.setBrush(this.brush);
    if (this.antialiased) {
        painter.setRenderHint(QPainter.Antialiasing, true);
        painter.translate(+0.5, +0.5);
    }

    for (var x = 0; x < this.width; x += 100) {
        for (var y = 0; y < this.height; y += 100) {
            painter.save();
            painter.translate(x, y);
            if (this.transformed) {
                painter.translate(50, 50);
                painter.rotate(60.0);
                painter.scale(0.6, 0.9);
                painter.translate(-50, -50);
            }

            switch (this.shape) {
            case RenderArea.Line:
                painter.drawLine(rect.bottomLeft(), rect.topRight());
                break;
            case RenderArea.Points:
                painter.drawPoints(RenderArea.points);
                break;
            case RenderArea.Polyline:
                painter.drawPolyline(RenderArea.points);
                break;
            case RenderArea.Polygon:
                painter.drawPolygon(RenderArea.points);
                break;
            case RenderArea.Rect:
                painter.drawRect(rect);
                break;
            case RenderArea.RoundedRect:
                painter.drawRoundedRect(rect, 25, 25, Qt.RelativeSize);
                break;
            case RenderArea.Ellipse:
                painter.drawEllipse(rect);
                break;
            case RenderArea.Arc:
                painter.drawArc(rect, startAngle, arcLength);
                break;
            case RenderArea.Chord:
                painter.drawChord(rect, startAngle, arcLength);
                break;
            case RenderArea.Pie:
                painter.drawPie(rect, startAngle, arcLength);
                break;
            case RenderArea.Path:
                painter.drawPath(path);
                break;
            case RenderArea.Text:
                // ### overload issue
                //painter.drawText(rect, Qt.AlignCenter, tr("Qt by\nTrolltech"));
                painter.drawText(rect.x, rect.y, rect.width, rect.height, Qt.AlignCenter, tr("Qt by\nTrolltech"), undefined);
                break;
            case RenderArea.Pixmap:
                painter.drawPixmap(10, 10, this.pixmap);
            }
            painter.restore();
        }
    }

    painter.setPen(this.palette.dark().color());
    painter.setBrush(Qt.NoBrush);
    painter.drawRect(0, 0, this.width - 1, this.height - 1);
    painter.end();
}



function Window(parent)
{
    QWidget.call(this, parent);

    this.renderArea = new RenderArea();

    this.shapeComboBox = new QComboBox();
    var icon = new QIcon(); // ### working around addItem() overload issue
    this.shapeComboBox.addItem(icon, tr("Polygon"), RenderArea.Polygon);
    this.shapeComboBox.addItem(icon, tr("Rectangle"), RenderArea.Rect);
    this.shapeComboBox.addItem(icon, tr("Rounded Rectangle"), RenderArea.RoundedRect);
    this.shapeComboBox.addItem(icon, tr("Ellipse"), RenderArea.Ellipse);
    this.shapeComboBox.addItem(icon, tr("Pie"), RenderArea.Pie);
    this.shapeComboBox.addItem(icon, tr("Chord"), RenderArea.Chord);
    this.shapeComboBox.addItem(icon, tr("Path"), RenderArea.Path);
    this.shapeComboBox.addItem(icon, tr("Line"), RenderArea.Line);
    this.shapeComboBox.addItem(icon, tr("Polyline"), RenderArea.Polyline);
    this.shapeComboBox.addItem(icon, tr("Arc"), RenderArea.Arc);
    this.shapeComboBox.addItem(icon, tr("Points"), RenderArea.Points);
    this.shapeComboBox.addItem(icon, tr("Text"), RenderArea.Text);
    this.shapeComboBox.addItem(icon, tr("Pixmap"), RenderArea.Pixmap);

    this.shapeLabel = new QLabel(tr("&Shape:"));
    this.shapeLabel.setBuddy(this.shapeComboBox);

    this.penWidthSpinBox = new QSpinBox();
    this.penWidthSpinBox.setRange(0, 20);
    this.penWidthSpinBox.specialValueText = tr("0 (cosmetic pen)");

    this.penWidthLabel = new QLabel(tr("Pen &Width:"));
    this.penWidthLabel.setBuddy(this.penWidthSpinBox);

    this.penStyleComboBox = new QComboBox();
    this.penStyleComboBox.addItem(tr("Solid"), Qt.SolidLine);
    this.penStyleComboBox.addItem(tr("Dash"), Qt.DashLine);
    this.penStyleComboBox.addItem(tr("Dot"), Qt.DotLine);
    this.penStyleComboBox.addItem(tr("Dash Dot"), Qt.DashDotLine);
    this.penStyleComboBox.addItem(tr("Dash Dot Dot"), Qt.DashDotDotLine);
    this.penStyleComboBox.addItem(tr("None"), Qt.NoPen);

    this.penStyleLabel = new QLabel(tr("&Pen Style:"));
    this.penStyleLabel.setBuddy(this.penStyleComboBox);

    this.penCapComboBox = new QComboBox();
    this.penCapComboBox.addItem(tr("Flat"), Qt.FlatCap);
    this.penCapComboBox.addItem(tr("Square"), Qt.SquareCap);
    this.penCapComboBox.addItem(tr("Round"), Qt.RoundCap);

    this.penCapLabel = new QLabel(tr("Pen &Cap:"));
    this.penCapLabel.setBuddy(this.penCapComboBox);

    this.penJoinComboBox = new QComboBox();
    this.penJoinComboBox.addItem(tr("Miter"), Qt.MiterJoin);
    this.penJoinComboBox.addItem(tr("Bevel"), Qt.BevelJoin);
    this.penJoinComboBox.addItem(tr("Round"), Qt.RoundJoin);

    this.penJoinLabel = new QLabel(tr("Pen &Join:"));
    this.penJoinLabel.setBuddy(this.penJoinComboBox);

    this.brushStyleComboBox = new QComboBox();
    this.brushStyleComboBox.addItem(tr("Linear Gradient"),
            Qt.LinearGradientPattern);
    this.brushStyleComboBox.addItem(tr("Radial Gradient"),
            Qt.RadialGradientPattern);
    this.brushStyleComboBox.addItem(tr("Conical Gradient"),
            Qt.ConicalGradientPattern);
    this.brushStyleComboBox.addItem(tr("Texture"), Qt.TexturePattern);
    this.brushStyleComboBox.addItem(tr("Solid"), Qt.SolidPattern);
    this.brushStyleComboBox.addItem(tr("Horizontal"), Qt.HorPattern);
    this.brushStyleComboBox.addItem(tr("Vertical"), Qt.VerPattern);
    this.brushStyleComboBox.addItem(tr("Cross"), Qt.CrossPattern);
    this.brushStyleComboBox.addItem(tr("Backward Diagonal"), Qt.BDiagPattern);
    this.brushStyleComboBox.addItem(tr("Forward Diagonal"), Qt.FDiagPattern);
    this.brushStyleComboBox.addItem(tr("Diagonal Cross"), Qt.DiagCrossPattern);
    this.brushStyleComboBox.addItem(tr("Dense 1"), Qt.Dense1Pattern);
    this.brushStyleComboBox.addItem(tr("Dense 2"), Qt.Dense2Pattern);
    this.brushStyleComboBox.addItem(tr("Dense 3"), Qt.Dense3Pattern);
    this.brushStyleComboBox.addItem(tr("Dense 4"), Qt.Dense4Pattern);
    this.brushStyleComboBox.addItem(tr("Dense 5"), Qt.Dense5Pattern);
    this.brushStyleComboBox.addItem(tr("Dense 6"), Qt.Dense6Pattern);
    this.brushStyleComboBox.addItem(tr("Dense 7"), Qt.Dense7Pattern);
    this.brushStyleComboBox.addItem(tr("None"), Qt.NoBrush);

    this.brushStyleLabel = new QLabel(tr("&Brush Style:"));
    this.brushStyleLabel.setBuddy(this.brushStyleComboBox);

    this.otherOptionsLabel = new QLabel(tr("Other Options:"));
    this.antialiasingCheckBox = new QCheckBox(tr("&Antialiasing"));
    this.transformationsCheckBox = new QCheckBox(tr("&Transformations"));

    this.shapeComboBox["activated(int)"].connect(
            this, this.shapeChanged);
    this.penWidthSpinBox["valueChanged(int)"].connect(
            this, this.penChanged);
    this.penStyleComboBox["activated(int)"].connect(
            this, this.penChanged);
    this.penCapComboBox["activated(int)"].connect(
            this, this.penChanged);
    this.penJoinComboBox["activated(int)"].connect(
            this, this.penChanged);
    this.brushStyleComboBox["activated(int)"].connect(
            this, this.brushChanged);
    this.antialiasingCheckBox["toggled(bool)"].connect(
            this.renderArea, this.renderArea.setAntialiased);
    this.transformationsCheckBox["toggled(bool)"].connect(
            this.renderArea, this.renderArea.setTransformed);

    var mainLayout = new QGridLayout();
    mainLayout.setColumnStretch(0, 1);
    mainLayout.setColumnStretch(3, 1);
    mainLayout.addWidget(this.renderArea, 0, 0, 1, 4);
    mainLayout.setRowMinimumHeight(1, 6);
    mainLayout.addWidget(this.shapeLabel, 2, 1, Qt.AlignRight);
    mainLayout.addWidget(this.shapeComboBox, 2, 2);
    mainLayout.addWidget(this.penWidthLabel, 3, 1, Qt.AlignRight);
    mainLayout.addWidget(this.penWidthSpinBox, 3, 2);
    mainLayout.addWidget(this.penStyleLabel, 4, 1, Qt.AlignRight);
    mainLayout.addWidget(this.penStyleComboBox, 4, 2);
    mainLayout.addWidget(this.penCapLabel, 5, 1, Qt.AlignRight);
    mainLayout.addWidget(this.penCapComboBox, 5, 2);
    mainLayout.addWidget(this.penJoinLabel, 6, 1, Qt.AlignRight);
    mainLayout.addWidget(this.penJoinComboBox, 6, 2);
    mainLayout.addWidget(this.brushStyleLabel, 7, 1, Qt.AlignRight);
    mainLayout.addWidget(this.brushStyleComboBox, 7, 2);
    mainLayout.setRowMinimumHeight(8, 6);
    mainLayout.addWidget(this.otherOptionsLabel, 9, 1, Qt.AlignRight);
    mainLayout.addWidget(this.antialiasingCheckBox, 9, 2);
    mainLayout.addWidget(this.transformationsCheckBox, 10, 2);
    this.setLayout(mainLayout);

    this.shapeChanged();
    this.penChanged();
    this.brushChanged();
    this.antialiasingCheckBox.checked = true;

    this.windowTitle = tr("Basic Drawing");
}

Window.prototype = new QWidget();

Window.prototype.shapeChanged = function()
{
    var shape = this.shapeComboBox.itemData(this.shapeComboBox.currentIndex);
    this.renderArea.setShape(shape);
}

Window.prototype.penChanged = function()
{
    var width = this.penWidthSpinBox.value;
    var style = this.penStyleComboBox.itemData(
            this.penStyleComboBox.currentIndex);
    var cap = this.penCapComboBox.itemData(
            this.penCapComboBox.currentIndex);
    var join = this.penJoinComboBox.itemData(
            this.penJoinComboBox.currentIndex);

    this.renderArea.setPen(new QPen(new QColor(Qt.blue), width, style, cap, join));
}

Window.prototype.brushChanged = function()
{
    var style = Qt.BrushStyle(this.brushStyleComboBox.itemData(
            this.brushStyleComboBox.currentIndex));

    if (style == Qt.LinearGradientPattern) {
        var linearGradient = new QLinearGradient(0, 0, 100, 100);
        // ### working around issue with Qt.GlobalColor
        linearGradient.setColorAt(0.0, new QColor(Qt.white));
        linearGradient.setColorAt(0.2, new QColor(Qt.green));
        linearGradient.setColorAt(1.0, new QColor(Qt.black));
        this.renderArea.setBrush(new QBrush(linearGradient));
    } else if (style == Qt.RadialGradientPattern) {
        var radialGradient = new QRadialGradient(50, 50, 50, 70, 70);
        radialGradient.setColorAt(0.0, new QColor(Qt.white));
        radialGradient.setColorAt(0.2, new QColor(Qt.green));
        radialGradient.setColorAt(1.0, new QColor(Qt.black));
        this.renderArea.setBrush(new QBrush(radialGradient));
    } else if (style == Qt.ConicalGradientPattern) {
        var conicalGradient = new QConicalGradient(50, 50, 150);
        conicalGradient.setColorAt(0.0, new QColor(Qt.white));
        conicalGradient.setColorAt(0.2, new QColor(Qt.green));
        conicalGradient.setColorAt(1.0, new QColor(Qt.black));
        this.renderArea.setBrush(new QBrush(conicalGradient));
    } else if (style == Qt.TexturePattern) {
        this.renderArea.setBrush(new QBrush(new QPixmap("images/brick.png")));
    } else {
        this.renderArea.setBrush(new QBrush(new QColor(Qt.green), style));
    }
}

var win = new Window();
win.show();
QCoreApplication.exec();
