include($$PWD/3rd-party/log4qt/log4qt.pri)
include($$PWD/3rd-party/qpcpp_7.3.2/qpcpp.pri)
include($$PWD/reentrant/reentrant.pri)

QMAKE_CXXFLAGS +=

INCLUDEPATH += $$PWD/include \
    $$PWD/3rd-party/

DEPENDPATH += $$PWD/include \
    $$PWD/3rd-party/log4qt/

HEADERS += \
    $$PWD/include/alumy.h \
    $$PWD/include/alumy/ascii.h \
    $$PWD/include/alumy/bit.h \
    $$PWD/include/alumy/bug.h \
    $$PWD/include/alumy/byteswap.h \
    $$PWD/include/alumy/check.h \
    $$PWD/include/alumy/errno.h \
    $$PWD/include/alumy/net/host_slip_remote.h \
    $$PWD/include/alumy/singleton.h \
    $$PWD/include/alumy/net.h \
    $$PWD/include/alumy/net/slip.h \
    $$PWD/include/alumy/net/host_slip.h \
    $$PWD/include/alumy/mod_log.h \
    $$PWD/include/alumy/sleep.h \
    $$PWD/include/alumy/audio/wav_file.h

SOURCES += \
    $$PWD/ascii.c \
    $$PWD/mem/mem.c \
    $$PWD/net/host_slip.cpp \
    $$PWD/net/slip.cpp \
    $$PWD/net/host_slip_remote.cpp \
    $$PWD/sleep.cpp \
    $$PWD/string/strlcpy.c \
    $$PWD/xyzmodem/ymodem.c \
    $$PWD/errno.c \
    $$PWD/crc/crc16.c \
    $$PWD/crc/crc32.c \
    $$PWD/crc/mb_crc16.c \
    $$PWD/log.c \
    $$PWD/protobuf-c/protobuf-c.c \
    $$PWD/libcsv/libcsv.c \
    $$PWD/version.c \
    $$PWD/mod_log.cpp \
    $$PWD/audio/wav_file.cpp
