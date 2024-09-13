#ifndef __AL_SLIP_H
#define __AL_SLIP_H 1

#include <QObject>
#include <QThread>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QTimer>
#include <QByteArray>
#include <QMutex>
#include "alumy/defs.h"

AL_BEGIN_NAMESPACE

class slip : public QObject
{
    Q_OBJECT
public:
    enum {
      SLIP_RECV_NORMAL,
      SLIP_RECV_ESCAPE
    };

public:
    slip(QString name, int32_t baud, QSerialPort::DataBits dataBits,
         QSerialPort::StopBits stopBits, QSerialPort::Parity parity,
         size_t recvSize = 4096);
    ~slip();

    void setReadBufferSize(int64_t size);
    void flush();

private:
    size_t recvByte(int c);
    int32_t initSerialPort();

protected slots:
    int64_t sendData(const void *data, size_t len);
    int64_t sendData(QByteArray data);
    void recvData(void);

signals:
    void received(QByteArray data);
    int64_t write(QByteArray data);
    int64_t write(const void *data, size_t len);

private:
    QSerialPort *m_serialPort;
    QThread *m_thread;
    QMutex m_sendMutex;
    QString m_name;
    int32_t m_baud;
    QSerialPort::DataBits m_dataBits;
    QSerialPort::StopBits m_stopBits;
    QSerialPort::Parity m_parity;
    QByteArray m_recvData;
    int32_t m_recvState;
    int32_t m_recvLen;
    size_t m_recvSize;
};

AL_END_NAMESPACE

#endif // SLIP_H
