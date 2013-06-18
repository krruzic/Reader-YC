APP_NAME = TartStart

CONFIG += qt warn_on cascades10
# MOBILITY += sensors

INCLUDEPATH += ../src ../../Python-3.2.2/Include
# DEPENDPATH += ../src ../../Python-3.2.2/Include

device {
    LIBS += -L../../libs/arm
    QMAKE_LFLAGS += -Wl,-rpath-link,../../libs/arm
}

simulator {
    LIBS += -L../../libs/x86
    QMAKE_LFLAGS += -Wl,-rpath-link,../../libs/x86
}

# The Momentics "cheat" wizard suggested this but having it in makes it
# think it needs to be built from source, so commented out.
# PRE_TARGETDEPS += libpython3.2m.so

LIBS += -lpython3.2m -lbbdata -lbbplatform -lQtLocationSubset \
    -lbbsystem -lscreen -lbbcascadespickers -lbbcascadesadvertisement

include(config.pri)
