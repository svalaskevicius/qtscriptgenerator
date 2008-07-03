TEMPLATE = app
TARGET = qsexec

DESTDIR = ../

QT = core script

win32:CONFIG+=console
mac:CONFIG-=app_bundle

SOURCES += main.cpp
