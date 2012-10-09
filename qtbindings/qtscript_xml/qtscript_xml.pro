TARGET = qtscript_xml
include(../qtbindingsbase.pri)
QT -= gui
QT += xml
INCLUDEPATH += ./include/
include($$GENERATEDCPP/com_trolltech_qt_xml/com_trolltech_qt_xml.pri)
