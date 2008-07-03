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

function Mouse(parent) {
    QGraphicsItem.call(this, parent);
    this.angle = 0;
    this.speed = 0;
    this.mouseEyeDirection = 0;

    var adjust = 0.5;
    this._boundingRect = new QRectF(-20 - adjust, -22 - adjust,
                                    40 + adjust, 83 + adjust);
    this.boundingRect = function() { return this._boundingRect; };

    this._shape = new QPainterPath();
    this._shape.addRect(-10, -20, 20, 40);
    this.shape = function() { return this._shape; }

    this._brush = new QBrush(Qt.SolidPattern);
    this._tail = new QPainterPath(new QPointF(0, 20));
    this._tail.cubicTo(-5, 22, -5, 22, 0, 25);
    this._tail.cubicTo(5, 27, 5, 32, 0, 30);
    this._tail.cubicTo(-5, 32, -5, 42, 0, 35);

    this._pupilRect1 = new QRectF(-8 + this.mouseEyeDirection, -17, 4, 4);
    this._pupilRect2 = new QRectF(4 + this.mouseEyeDirection, -17, 4, 4);

    this.color = new QColor(Math.random()*256, Math.random()*256,
                            Math.random()*256);
    this.rotate(Math.random()*360);

    var timer = new QTimer(this);
    timer.singleShot = false;
    timer.timeout.connect(this, function() { this.move(); });
    timer.start(1000 / 33);
}

Mouse.prototype = new QGraphicsItem();

Mouse.prototype.paint = function(painter, styleOptionGraphicsItem, widget) {
    // Body
    painter.setBrush(new QBrush(this.color));
    painter.drawEllipse(-10, -20, 20, 40);

    // Eyes
    this._brush.setColor(Qt.white);
    painter.setBrush(this._brush);
    painter.drawEllipse(-10, -17, 8, 8);
    painter.drawEllipse(2, -17, 8, 8);

    // Nose
    this._brush.setColor(Qt.black);
    painter.setBrush(this._brush);
    painter.drawEllipse(-2, -22, 4, 4);

    // Pupils
    painter.drawEllipse(this._pupilRect1);
    painter.drawEllipse(this._pupilRect2);

    // Ears
    //    if (this.scene().collidingItems(this).length == 0) FIXME: const QGraphicsItem*
    if (this.scene().items(this.pos()).length == 1)
        this._brush.setColor(Qt.darkYellow);
    else
        this._brush.setColor(Qt.red);
    painter.setBrush(this._brush);

    painter.drawEllipse(-17, -12, 16, 16);
    painter.drawEllipse(1, -12, 16, 16);

    // Tail
    painter.setBrush(Qt.NoBrush);
    painter.drawPath(this._tail);
}

Mouse.prototype.move = function() {
    // Don't move too far away
    var lineToCenter = new QLineF(Mouse.origo, this.mapFromScene(0, 0));
    if (lineToCenter.length() > 150) {
        var angleToCenter = Math.acos(lineToCenter.dx()
                                      / lineToCenter.length());
        if (lineToCenter.dy() < 0)
            angleToCenter = Mouse.TWO_PI - angleToCenter;
        angleToCenter = Mouse.normalizeAngle((Math.PI - angleToCenter)
                                              + Math.PI / 2);

        if (angleToCenter < Math.PI && angleToCenter > Math.PI / 4) {
            // Rotate left
            this.angle += (this.angle < -Math.PI / 2) ? 0.25 : -0.25;
        } else if (angleToCenter >= Math.PI
                   && angleToCenter < (Math.PI + Math.PI / 2
                                       + Math.PI / 4)) {
            // Rotate right
            this.angle += (this.angle < Math.PI / 2) ? 0.25 : -0.25;
        }
    } else if (Math.sin(this.angle) < 0) {
        this.angle += 0.25;
    } else if (Math.sin(this.angle) > 0) {
        this.angle -= 0.25;
    }

    // Try not to crash with any other mice

    var polygon = new QPolygonF(
	[ this.mapToScene(0, 0),
	  this.mapToScene(-30, -50),
	  this.mapToScene(30, -50) ] );

    var dangerMice = this.scene().items(polygon);
    for (var i = 0; i < dangerMice.length; ++i) {
        var item = dangerMice[i];
        if (item == this)
            continue;

        var lineToMouse = new QLineF(Mouse.origo,
                                     this.mapFromItem(item, 0, 0));
        var angleToMouse = Math.acos(lineToMouse.dx()
                                     / lineToMouse.length());
        if (lineToMouse.dy() < 0)
            angleToMouse = Mouse.TWO_PI - angleToMouse;
        angleToMouse = Mouse.normalizeAngle((Math.PI - angleToMouse)
                                      + Math.PI / 2);

        if (angleToMouse >= 0 && angleToMouse < (Math.PI / 2)) {
            // Rotate right
            this.angle += 0.5;
        } else if (angleToMouse <= Mouse.TWO_PI
                   && angleToMouse > (Mouse.TWO_PI - Math.PI / 2)) {
            // Rotate left
            this.angle -= 0.5;
        }
    }

    // Add some random movement
    if (dangerMice.length < 1 && Math.random() < 0.1) {
        if (Math.random() > 0.5)
            this.angle += Math.random() / 5;
        else
            this.angle -= Math.random() / 5;
    }

    this.speed += (-50 + Math.random() * 100) / 100.0;

    var dx = Math.sin(this.angle) * 10;
    this.mouseEyeDirection = (Math.abs(dx / 5) < 1) ? 0 : dx / 5;

    this.rotate(dx);
    this.setPos(this.mapToParent(0, -(3 + Math.sin(this.speed) * 3)));
}

Mouse.normalizeAngle = function(angle) {
    while (angle < 0)
        angle += Mouse.TWO_PI;
    while (angle > Mouse.TWO_PI)
        angle -= Mouse.TWO_PI;
    return angle;
}

Mouse.TWO_PI = Math.PI * 2;
Mouse.origo = new QPointF(0, 0);



function CollidingMice(parent) {
    QWidget.call(this, parent);
    var scene = new QGraphicsScene(this);
    scene.setSceneRect(-300, -300, 600, 600);
    scene.itemIndexMethod = QGraphicsScene.NoIndex;

    for (var i = 0; i < CollidingMice.MOUSE_COUNT; ++i) {
        var mouse = new Mouse(this);
        mouse.setPos(Math.sin((i * 6.28) / CollidingMice.MOUSE_COUNT) * 200,
                     Math.cos((i * 6.28) / CollidingMice.MOUSE_COUNT) * 200);
        scene.addItem(mouse);
    }

    var view = new QGraphicsView(scene, this);
    view.setRenderHint(QPainter.Antialiasing);
    view.backgroundBrush = new QBrush(new QPixmap("images/cheese.png"));
    view.cacheMode = new QGraphicsView.CacheMode(QGraphicsView.CacheBackground);
    view.dragMode = QGraphicsView.ScrollHandDrag;
    view.viewportUpdateMode = QGraphicsView.FullViewportUpdate;

    var layout = new QGridLayout();
    layout.addWidget(view, 0, 0);
    this.setLayout(layout);

    this.setWindowTitle("Colliding Mice");
    this.resize(400, 300);
}

CollidingMice.prototype = new QWidget();

CollidingMice.MOUSE_COUNT = 7;



var collidingMice = new CollidingMice(null);
collidingMice.show();
QCoreApplication.exec();
