function createBox(parent) {
    var result = new QWidget();
    result.styleSheet = "background: #00f060";
    return result;
}

var scene = new QGraphicsScene();
scene.setSceneRect(0, 0, 400, 400);
scene.itemIndexMethod = QGraphicsScene.NoIndex;

box = scene.addWidget(createBox());

var machine = new QStateMachine();

var s1 = new QState(machine);
s1.assignProperty(box, "geometry", new QRect(-50, 50, 100, 100));
s1.assignProperty(box, "opacity", 1.0);

var s2 = new QState(machine);
s2.assignProperty(box, "geometry", new QRect(250, 200, 200, 150));
s2.assignProperty(box, "opacity", 0.2);

var timer = new QTimer();
timer.interval = 2000;
timer.singleShot = false;
timer.start();

var t1 = s1.addTransition(timer, "timeout()", s2);

var geometryAnim = new QPropertyAnimation(box, "geometry");
geometryAnim.easingCurve = new QEasingCurve(QEasingCurve.InOutElastic);
geometryAnim.duration = 1500;
t1.addAnimation(geometryAnim);

var opacityAnim = new QPropertyAnimation(box, "opacity");
opacityAnim.easingCurve = new QEasingCurve(QEasingCurve.InOutQuad);
opacityAnim.duration = 1500;
t1.addAnimation(opacityAnim);

var t2 = s2.addTransition(timer, "timeout()", s1);
t2.addAnimation(geometryAnim);
t2.addAnimation(opacityAnim);

machine.initialState = s1;
machine.start();

var view = new QGraphicsView(scene);
view.setRenderHint(QPainter.Antialiasing);
view.backgroundBrush = new QBrush(new QColor(0, 48, 32));
view.viewportUpdateMode = QGraphicsView.FullViewportUpdate;

view.resize(600, 410);
view.show();

QCoreApplication.exec();
