var button = new QPushButton();

var off = new QState();
off.assignProperty(button, "text", "Off");

var on = new QState();
on.assignProperty(button, "text", "On");

off.addTransition(button, "clicked()", on);
on.addTransition(button, "clicked()", off);

var machine = new QStateMachine();
machine.addState(off);
machine.addState(on);
machine.initialState = off;

machine.start();
button.resize(100, 100);
button.show();

QCoreApplication.exec();
