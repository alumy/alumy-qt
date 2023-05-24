#include <QSerialPort>
#include <QSerialPortInfo>
#include <QDebug>
#include "alumy/usb/probe.h"

AL_BEGIN_NAMESPACE

usbProbe::usbProbe(QObject *parent) : QObject(parent)
{

}

QString usbProbe::probeSerialPort(QString desc)
{
    QString portName;

    foreach (const QSerialPortInfo &info, QSerialPortInfo::availablePorts()) {
        qDebug() << "Name : " << info.portName();
        qDebug() << "Description : " << info.description();
        qDebug() << "Manufacturer: " << info.manufacturer();
        qDebug() << "Serial Number: " << info.serialNumber();
        qDebug() << "System Location: " << info.systemLocation();

        if(desc == info.description()) {
#ifdef _WIN32 // Windows serial port implementation
            portName = info.portName();
#else // Mac/Linux serial port implementation
            portName = info.systemLocation();
#endif
        }
    }

    if(portName == "") {
        qDebug() << "can not find SerialPortName, please check serialPortDescription";
    }

    return portName;
}

AL_END_NAMESPACE
