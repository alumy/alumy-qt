INCLUDEPATH += $$PWD/include
DEPENDPATH += $$PWD/include

HEADERS += \
    $$PWD/include/alumy.h \
    $$PWD/include/alumy/errno.h \
    $$PWD/include/alumy/singleton.h \
    $$PWD/include/alumy/net.h \
    $$PWD/include/alumy/net/slip.h

SOURCES += \
    $$PWD/mem/mem.c \
    $$PWD/net/slip.cpp \
    $$PWD/string/strlcpy.c \
    $$PWD/xyzmodem/ymodem.c \
    $$PWD/errno.c \
    $$PWD/crc/crc16.c \
    $$PWD/crc/crc32.c \
    $$PWD/crc/mb_crc16.c \
    $$PWD/log.c \
    $$PWD/protobuf-c/protobuf-c.c \
    $$PWD/libcsv/libcsv.c
