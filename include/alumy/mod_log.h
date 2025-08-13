#ifndef __AL_MOD_LOGGER_H
#define __AL_MOD_LOGGER_H 1

#include <QObject>
#include <QJsonObject>
#include "log4qt/log4qt.h"
#include "log4qt/logger.h"
#include "log4qt/ttcclayout.h"
#include "log4qt/varia/levelrangefilter.h"
#include "log4qt/rollingfileappender.h"
#include "alumy/cdefs.h"
#include "alumy/defs.h"
#include "alumy/singleton.h"

class log : public QObject
{
	Q_OBJECT

    AL_DECLARE_SINGLETON(log);

public:
    explicit log(QObject *parent = nullptr);
    ~log();

	void fatal(const char *pMessage);
	void fatal(const QString &rMessage);
	void fatal(const QJsonObject &message);
    void fatal(const QByteArray &msg);
	void error(const char *pMessage);
	void error(const QString &rMessage);
	void error(const QJsonObject &message);
    void error(const QByteArray &msg);
	void warn(const char *pMessage);
	void warn(const QString &rMessage);
	void warn(const QJsonObject &message);
    void warn(const QByteArray &msg);
	void info(const char *pMessage);
	void info(const QString &rMessage);
	void info(const QJsonObject &message);
    void info(const QByteArray &msg);
	void debug(const char *pMessage);
	void debug(const QString &rMessage);
	void debug(const QJsonObject &message);
    void debug(const QByteArray &msg);
	void trace(const char *pMessage);
	void trace(const QString &rMessage);
	void trace(const QJsonObject &message);
    void trace(const QByteArray &msg);

    void set_path(QString path);

private:
    QString bin(const QByteArray &msg);

private:
	Log4Qt::TTCCLayout *m_layout;
	Log4Qt::LevelRangeFilter *m_filter;
	Log4Qt::RollingFileAppender *m_appender;
};

#endif // __AL_MOD_LOGGER_H
