TEMPLATE = lib
DEPENDPATH += .
INCLUDEPATH += .
DESTDIR = $$PWD/../plugins/script
QT += script
CONFIG += plugin debug_and_release build_all
GENERATEDCPP = $$PWD/../generated_cpp
TARGET=$$qtLibraryTarget($$TARGET)
