#include <consoleappender.h>
#include <rollingfileappender.h>
#include <logger.h>
#include <ttcclayout.h>
#include <logmanager.h>
#include <varia/levelrangefilter.h>
#include <QJsonDocument>
#include <QMutex>
#include <QDir>
#include "alumy/mod_log.h"
#include "alumy/log.h"

using namespace Log4Qt;

log::log(QObject *parent):
	QObject(parent),
	m_layout(new TTCCLayout(this)),
	m_filter(new LevelRangeFilter(this)),
	m_appender(new RollingFileAppender(this))
{
	Logger::rootLogger()->setLevel(Level::ALL_INT);

	m_layout->setDateFormat(TTCCLayout::ISO8601);
	m_layout->setThreadPrinting(true);

	m_filter->setAcceptOnMatch(true);
	m_filter->setLevelMax(Level(Level::FATAL_INT));
	m_filter->setLevelMin(Level(Level::TRACE_INT));

	m_appender->setLayout(m_layout);
	m_appender->setAppendFile(true);
	m_appender->setBufferedIo(false);
	m_appender->setMaxBackupIndex(9);
    m_appender->setMaximumFileSize(1024 * 1024 * 2);
	m_appender->addFilter(m_filter);

	Logger::rootLogger()->addAppender(m_appender);

#if QT_NO_DEBUG
    Log4Qt::LogManager::setHandleQtMessages(true);
#endif
}

log::~log()
{

}

QString log::bin(const QByteArray &msg)
{
    QString text;

    const uint8_t *data = (const uint8_t *)msg.data();
    size_t len = msg.length();
    int32_t nline = len >> 4;
    int32_t remain = len & 0x0F;

    intptr_t addr = 0;
    const uint8_t *rp = (const uint8_t *)data;

    while (nline--) {
        char buf[128];
        hex_raw_fmt_line(buf, sizeof(buf), addr, rp + addr, AL_LOG_BIN_LINE_SIZE);
        addr += AL_LOG_BIN_LINE_SIZE;

        text.append(buf);
        text.append("\n");
    }

    if (remain > 0) {
        char buf[128];
        hex_raw_fmt_line(buf, sizeof(buf), addr, rp + addr, remain);

        text.append(buf);
        text.append("\n");
    }

    return text;
}

void log::fatal(const char *pMessage)
{
	Logger::rootLogger()->fatal(pMessage);
}

void log::fatal(const QString &rMessage)
{
	Logger::rootLogger()->fatal(rMessage);
}

void log::fatal(const QJsonObject &message)
{
	QJsonDocument d(message);
    Logger *logger = Logger::rootLogger();
    logger->fatal(d.toJson(QJsonDocument::Indented).constData());
}

void log::fatal(const QByteArray &msg)
{
    fatal(bin(msg));
}

void log::error(const char *pMessage)
{
	Logger::rootLogger()->error(pMessage);
}

void log::error(const QString &rMessage)
{
	Logger::rootLogger()->error(rMessage);
}

void log::error(const QJsonObject &message)
{
    QJsonDocument d(message);
    Logger *logger = Logger::rootLogger();
    logger->error(d.toJson(QJsonDocument::Indented).constData());
}

void log::error(const QByteArray &msg)
{
    error(bin(msg));
}

void log::warn(const char *pMessage)
{
	Logger::rootLogger()->warn(pMessage);
}

void log::warn(const QString &rMessage)
{
	Logger::rootLogger()->warn(rMessage);
}

void log::warn(const QJsonObject &message)
{
    QJsonDocument doc(message);
    Logger *logger = Logger::rootLogger();
    logger->warn(doc.toJson(QJsonDocument::Indented).constData());
}

void log::warn(const QByteArray &msg)
{
    warn(bin(msg));
}

void log::info(const char *pMessage)
{
	Logger::rootLogger()->info(pMessage);
}

void log::info(const QString &rMessage)
{
	Logger::rootLogger()->info(rMessage);
}

void log::info(const QJsonObject &message)
{
    QJsonDocument doc(message);
    Logger *logger = Logger::rootLogger();
    logger->info(doc.toJson(QJsonDocument::Indented).constData());
}

void log::info(const QByteArray &msg)
{
    info(bin(msg));
}

void log::debug(const char *pMessage)
{
	Logger::rootLogger()->debug(pMessage);
}

void log::debug(const QString &rMessage)
{
	Logger::rootLogger()->debug(rMessage);
}

void log::debug(const QJsonObject &message)
{
    QJsonDocument doc(message);
    Logger *logger = Logger::rootLogger();
    logger->debug(doc.toJson(QJsonDocument::Indented).constData());
}

void log::debug(const QByteArray &msg)
{
    debug(bin(msg));
}

void log::trace(const char *pMessage)
{
	Logger::rootLogger()->trace(pMessage);
}

void log::trace(const QString &rMessage)
{
	Logger::rootLogger()->trace(rMessage);
}

void log::trace(const QJsonObject &message)
{
    QJsonDocument doc(message);
    Logger *logger = Logger::rootLogger();
    logger->trace(doc.toJson(QJsonDocument::Indented).constData());
}

void log::trace(const QByteArray &msg)
{
    trace(bin(msg));
}

void log::set_path(QString path)
{
    m_appender->setFile(path);
    m_appender->activateOptions();
}
