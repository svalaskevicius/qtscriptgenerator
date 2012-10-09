TARGET = qtscript_webkit
include(../qtbindingsbase.pri)
QT += network webkit
INCLUDEPATH += ./include/
include($$GENERATEDCPP/com_trolltech_qt_webkit/com_trolltech_qt_webkit.pri)
