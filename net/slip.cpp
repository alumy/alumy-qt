#include "alumy/net/slip.h"

#define SLIP_END     0xC0 /* 0300: start and end of every packet */
#define SLIP_ESC     0xDB /* 0333: escape start (one byte escaped data follows) */
#define SLIP_ESC_END 0xDC /* 0334: following escape: original byte is 0xC0 (END) */
#define SLIP_ESC_ESC 0xDD /* 0335: following escape: original byte is 0xDB (ESC) */

AL_BEGIN_NAMESPACE

slip::slip(QString name, int32_t baud, QSerialPort::DataBits dataBits,
           QSerialPort::StopBits stopBits, QSerialPort::Parity parity,
           size_t recvSize) :
    m_name(name),
    m_baud(baud),
    m_dataBits(dataBits),
    m_stopBits(stopBits),
    m_parity(parity),
    m_recvSize(recvSize)
{
    m_thread = new QThread();
    m_serialPort = new QSerialPort();

    connect(m_serialPort, &QSerialPort::readyRead, this, &slip::recvData);

    m_serialPort->moveToThread(m_thread);
    this->moveToThread(m_thread);
}

slip::~slip()
{
    m_thread->quit();
    m_thread->wait();

	delete m_thread;

    if (m_serialPort->isOpen()) {
        m_serialPort->close();
    }

    delete m_serialPort;
}

int32_t slip::openSerialPort()
{
    m_serialPort->setPortName(m_name);
    m_serialPort->setBaudRate(m_baud);
    m_serialPort->setParity(m_parity);
    m_serialPort->setDataBits(m_dataBits);
    m_serialPort->setStopBits(m_stopBits);
    m_serialPort->setFlowControl(QSerialPort::NoFlowControl);

    if(m_serialPort->open(QIODevice::ReadWrite)) {
        return -1;
    }

    return 0;
}

int32_t slip::start()
{
    if(openSerialPort() != 0) {
        return -1;
    }

    m_thread->start();

    return 0;
}

void slip::recvData()
{
    QByteArray data = m_serialPort->readAll();

    for(int32_t i = 0; i < data.length(); ++i) {
        if (recvByte(data[i]) > 0) {
            emit received(m_recvData);
        }
    }
}

size_t slip::recvByte(int c)
{
	size_t recv_len = 0;

	switch (m_recvState) {
	case SLIP_RECV_NORMAL:
		switch (c) {
		case SLIP_END:
			if (m_recvLen > 0) {
				recv_len = m_recvLen;

				m_recvLen = 0;

				return recv_len;
			}

			return 0;

		case SLIP_ESC:
			m_recvState = SLIP_RECV_ESCAPE;
			return 0;

		default:
			break;
		}

		break;

	case SLIP_RECV_ESCAPE:
		switch (c) {
		case SLIP_ESC_END:
			c = SLIP_END;
			break;
		case SLIP_ESC_ESC:
			c = SLIP_ESC;
			break;
		default:
			break;
		}

		m_recvState = SLIP_RECV_NORMAL;
		break;

	default:
		break;
	}

	if (m_recvLen <= (int32_t)m_recvSize) {
		m_recvData.append(c);
		m_recvLen++;
	}

	return 0;
}

int64_t slip::send(const void *data, size_t len)
{
    size_t i;
    int32_t c;

    if(!m_serialPort->isOpen()) {
        return -1;
    }

    m_serialPort->putChar(SLIP_END);

    for (i = 0; i < len; i++) {
        c = ((const uint8_t *)data)[i];

        switch (c) {
        case SLIP_END:
            /* need to escape this byte (0xC0 -> 0xDB, 0xDC) */
            m_serialPort->putChar(SLIP_ESC);
            m_serialPort->putChar(SLIP_ESC_END);
            break;
        case SLIP_ESC:
            /* need to escape this byte (0xDB -> 0xDB, 0xDD) */
            m_serialPort->putChar(SLIP_ESC);
            m_serialPort->putChar(SLIP_ESC_ESC);
            break;
        default:
            /* normal byte - no need for escaping */
            m_serialPort->putChar(c);
            break;
        }
    }

    /* End with packet delimiter. */
    m_serialPort->putChar(SLIP_END);

    m_serialPort->flush();

    return len;
}

int64_t slip::send(QByteArray data)
{
    return send(data.data(), data.length());
}

AL_END_NAMESPACE
