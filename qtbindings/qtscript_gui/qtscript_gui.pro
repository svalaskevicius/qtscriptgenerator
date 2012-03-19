TARGET = qtscript_gui
include(../qtbindingsbase.pri)
SOURCES += $$GENERATEDCPP/com_trolltech_qt_gui/plugin.cpp
QT += widgets
include($$GENERATEDCPP/com_trolltech_qt_gui/com_trolltech_qt_gui.pri)
