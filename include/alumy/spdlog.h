#ifndef __AL_SPDLOG_H
#define __AL_SPDLOG_H

#include <QObject>
#include <QByteArray>
#include <QJsonObject>
#include <QString>
#include <memory>
#include "alumy/singleton.h"
#include "alumy/log.h"
#include <spdlog/spdlog.h>
#include <spdlog/fmt/fmt.h>

template <>
struct fmt::formatter<QString> : fmt::formatter<std::string> {
    fmt::format_context::iterator format(const QString &s, fmt::format_context &ctx) const {
        return fmt::formatter<std::string>::format(s.toStdString(), ctx);
    }
};

template <>
struct fmt::formatter<QByteArray> : fmt::formatter<std::string> {
    fmt::format_context::iterator format(const QByteArray &s, fmt::format_context &ctx) const {
        return fmt::formatter<std::string>::format(s.toStdString(), ctx);
    }
};

namespace alumy {

class slog : public QObject
{
	Q_OBJECT

	AL_DECLARE_SINGLETON(slog);

public:
	explicit slog(QObject *parent = nullptr);
	~slog();

	void fatal(const char *message);
	void fatal(const QString &message);
	void fatal(const QJsonObject &message);
	void fatal(const QByteArray &data);

	void error(const char *message);
	void error(const QString &message);
	void error(const QJsonObject &message);
	void error(const QByteArray &data);

	void warn(const char *message);
	void warn(const QString &message);
	void warn(const QJsonObject &message);
	void warn(const QByteArray &data);

	void info(const char *message);
	void info(const QString &message);
	void info(const QJsonObject &message);
	void info(const QByteArray &data);

	void debug(const char *message);
	void debug(const QString &message);
	void debug(const QJsonObject &message);
	void debug(const QByteArray &data);

	void trace(const char *message);
	void trace(const QString &message);
	void trace(const QJsonObject &message);
	void trace(const QByteArray &data);

	template<typename... Args>
	void fatal(const char *fmt, Args&&... args) {
		m_logger->critical(fmt, std::forward<Args>(args)...);
	}

	template<typename... Args>
	void error(const char *fmt, Args&&... args) {
		m_logger->error(fmt, std::forward<Args>(args)...);
	}

	template<typename... Args>
	void warn(const char *fmt, Args&&... args) {
		m_logger->warn(fmt, std::forward<Args>(args)...);
	}

	template<typename... Args>
	void info(const char *fmt, Args&&... args) {
		m_logger->info(fmt, std::forward<Args>(args)...);
	}

	template<typename... Args>
	void debug(const char *fmt, Args&&... args) {
		m_logger->debug(fmt, std::forward<Args>(args)...);
	}

	template<typename... Args>
	void trace(const char *fmt, Args&&... args) {
		m_logger->trace(fmt, std::forward<Args>(args)...);
	}

	void set_name(QString name);
	void set_path(QString path);
    void set_rotate(size_t file_size, int32_t file_count);
    void set_level(spdlog::level::level_enum level);

private:
	QString bin(const QByteArray &msg);
	void rebuild_logger();

private:
    std::shared_ptr<spdlog::logger> m_logger;
    QString m_name;
	QString m_path;
    size_t m_file_size = 2 * 1024 * 1024;
    int32_t m_file_count = 9;
    spdlog::level::level_enum m_level = spdlog::level::trace;
};

} // namespace alumy

#endif // __AL_SPDLOG_H
