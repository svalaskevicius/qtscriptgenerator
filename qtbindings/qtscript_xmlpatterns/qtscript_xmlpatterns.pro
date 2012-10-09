TARGET = qtscript_xmlpatterns
include(../qtbindingsbase.pri)
QT -= gui
QT += xmlpatterns network
INCLUDEPATH += ./include/
include($$GENERATEDCPP/com_trolltech_qt_xmlpatterns/com_trolltech_qt_xmlpatterns.pri)
