#ifndef PROBE_H
#define PROBE_H

#include <QObject>
#include "alumy/defs.h"

AL_BEGIN_NAMESPACE

class usbProbe : public QObject
{
    Q_OBJECT
public:
    explicit usbProbe(QObject *parent = nullptr);

    static QString probeSerialPort(QString desc);

signals:

};

AL_END_NAMESPACE

#endif // PROBE_H
