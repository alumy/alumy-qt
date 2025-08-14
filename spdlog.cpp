#include <cstdint>
#include <string>
#include <vector>
#include <mutex>
#include <chrono>
#include <QJsonDocument>
#include <QtGlobal>
#include <QDir>
#include <QFileInfo>
#include "alumy/spdlog.h"
#include "alumy/log.h"
#include <spdlog/spdlog.h>
#include <spdlog/async.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/sinks/rotating_file_sink.h>

namespace alumy {

static std::string to_std_string(const QString &s)
{
	return std::string(s.toUtf8().constData());
}

slog::slog(QObject *parent)
	: QObject(parent)
{
    static std::once_flag once_flag;

    std::call_once(once_flag, [](){
        spdlog::init_thread_pool(8192, 1);
        spdlog::flush_every(std::chrono::seconds(1));
    });

	rebuild_logger();
}

slog::~slog()
{
    m_logger->flush();
}

QString slog::bin(const QByteArray &msg)
{
	QString text;
    char buf[128];

	const uint8_t *data = (const uint8_t *)msg.data();
	size_t len = (size_t)msg.length();
	int32_t nline = (int32_t)(len >> 4);
	int32_t remain = (int32_t)(len & 0x0F);

	intptr_t addr = 0;
	const uint8_t *rp = (const uint8_t *)data;

	while (nline--) {
		hex_raw_fmt_line(buf, sizeof(buf), addr, rp + addr, AL_LOG_BIN_LINE_SIZE);
		addr += AL_LOG_BIN_LINE_SIZE;

		text.append(buf);
		text.append("\n");
	}

	if (remain > 0) {
		hex_raw_fmt_line(buf, sizeof(buf), addr, rp + addr, (size_t)remain);

		text.append(buf);
		text.append("\n");
	}

	return text;
}

void slog::rebuild_logger()
{
	try {
		std::vector<spdlog::sink_ptr> sinks;
		
		if (!m_path.isEmpty()) {
			auto file_sink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(
				to_std_string(m_path), m_file_size, m_file_count);
			sinks.push_back(file_sink);
		} else {
			sinks.push_back(std::make_shared<spdlog::sinks::stdout_color_sink_mt>());
		}

		m_logger = std::make_shared<spdlog::async_logger>(
			to_std_string(m_name), sinks.begin(), sinks.end(), spdlog::thread_pool(), spdlog::async_overflow_policy::block);
		m_logger->set_level(m_level);
		m_logger->set_pattern("[%Y-%m-%d %H:%M:%S.%e][%^%l%$][%t] %v");

		spdlog::register_or_replace(m_logger);
	} catch (const spdlog::spdlog_ex &e) {
		m_logger = spdlog::default_logger();
	}

    Q_ASSERT(m_logger);
}

void slog::fatal(const char *message)
{
    m_logger->critical(message);
}

void slog::fatal(const QString &message)
{
	fatal(message.toUtf8().constData());
}

void slog::fatal(const QJsonObject &message)
{
	QJsonDocument d(message);
	fatal(d.toJson(QJsonDocument::Indented).constData());
}

void slog::fatal(const QByteArray &data)
{
	fatal(bin(data));
}

void slog::error(const char *message)
{
    m_logger->error(message);
}

void slog::error(const QString &message)
{
	error(message.toUtf8().constData());
}

void slog::error(const QJsonObject &message)
{
	QJsonDocument d(message);
	error(d.toJson(QJsonDocument::Indented).constData());
}

void slog::error(const QByteArray &data)
{
	error(bin(data));
}

void slog::warn(const char *message)
{
    m_logger->warn(message);
}

void slog::warn(const QString &message)
{
	warn(message.toUtf8().constData());
}

void slog::warn(const QJsonObject &message)
{
	QJsonDocument d(message);
	warn(d.toJson(QJsonDocument::Indented).constData());
}

void slog::warn(const QByteArray &data)
{
	warn(bin(data));
}

void slog::info(const char *message)
{
    m_logger->info(message);
}

void slog::info(const QString &message)
{
	info(message.toUtf8().constData());
}

void slog::info(const QJsonObject &message)
{
	QJsonDocument d(message);
	info(d.toJson(QJsonDocument::Indented).constData());
}

void slog::info(const QByteArray &data)
{
	info(bin(data));
}

void slog::debug(const char *message)
{
    m_logger->debug(message);
}

void slog::debug(const QString &message)
{
	debug(message.toUtf8().constData());
}

void slog::debug(const QJsonObject &message)
{
	QJsonDocument d(message);
	debug(d.toJson(QJsonDocument::Indented).constData());
}

void slog::debug(const QByteArray &data)
{
	debug(bin(data));
}

void slog::trace(const char *message)
{
    m_logger->trace(message);
}

void slog::trace(const QString &message)
{
	trace(message.toUtf8().constData());
}

void slog::trace(const QJsonObject &message)
{
	QJsonDocument d(message);
	trace(d.toJson(QJsonDocument::Indented).constData());
}

void slog::trace(const QByteArray &data)
{
	trace(bin(data));
}

void slog::set_name(QString name)
{
	m_name = name;
	rebuild_logger();
}

void slog::set_path(QString path)
{
	if (!path.isEmpty()) {
		QFileInfo fileInfo(path);
		QDir dir = fileInfo.dir();
		
		if (!dir.exists()) {
			dir.mkpath(".");
		}
	}
	
	m_path = path;
	rebuild_logger();
}

void slog::set_rotate(size_t file_size, int32_t file_count)
{
	m_file_size = file_size;
	m_file_count = file_count;
	rebuild_logger();
}


void slog::set_level(spdlog::level::level_enum level)
{
	m_level = level;
	rebuild_logger();
}

} // namespace alumy