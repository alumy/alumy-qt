#include <QDebug>
#include "alumy/audio/wav_file.h"

wav_file::wav_file(QObject *parent) : QIODevice(parent)
{

}

wav_file::~wav_file()
{

}

qint64 wav_file::bytesAvailable() const
{
    qDebug() << "bytesAvailable" << m_pcmData.size() + QIODevice::bytesAvailable();

    return m_pcmData.size() + QIODevice::bytesAvailable();
}

bool wav_file::snd_open(QString fileName)
{
    m_info.channels = 0;
    m_info.format = 0;
    m_info.frames = 0;
    m_info.samplerate = 0;

    m_sndfile = sf_open(fileName.toLatin1().data(), SFM_READ, &m_info);

    if (m_sndfile == nullptr)
        return false;

    if (!this->open(QIODevice::ReadOnly)) {
        sf_close(m_sndfile);

        m_sndfile = nullptr;
        return false;
    }

    if (read_all() <= 0) {
        sf_close(m_sndfile);
        m_sndfile = nullptr;

        this->close();
        return false;
    }

    return true;
}

int32_t wav_file::cell_size()
{
    size_t size;

    switch(m_info.format & 0x0f)
    {
    case SF_FORMAT_PCM_U8:
        size = 1;
        break;

    case SF_FORMAT_PCM_S8:
        size = 1;
        break;

    case SF_FORMAT_PCM_16:
        size = 2;
        break;

    case SF_FORMAT_PCM_24:
        size = 3;
        break;

    case SF_FORMAT_PCM_32:
        size = 4;
        break;

    default:
        size = 1;
        break;
    }

    return size;
}

qint64 wav_file::read_all()
{
    if(m_sndfile == nullptr)
        return -1;

    size_t cell = cell_size();
    size_t size = m_info.channels * m_info.frames * cell;

    m_pcmData.resize(size);

    uint8_t *p = (uint8_t *)m_pcmData.data();

    qint64 total_count = m_info.channels * m_info.frames;
    qint64 read_count = 0;

    while (read_count < total_count) {
        int remain_count = total_count - read_count;
        int read_limit = qMin(remain_count, 1024);

        int n = sf_read_raw(m_sndfile, &p[read_count * cell], read_limit);
        if(n <= 0)
            return -1;

        read_count += n;
    }

    return size;
}

qint64 wav_file::readData(char *data, qint64 len)
{
    qDebug() << "read " << len << "total" << m_pcmData.size();

    qint64 total = 0;
    if (!m_pcmData.isEmpty()) {
        while (len - total > 0) {
            const qint64 chunk = qMin((m_pcmData.size() - m_read_pos), len - total);
            memcpy(data + total, m_pcmData.constData() + m_read_pos, chunk);
            m_read_pos = (m_read_pos + chunk) % m_pcmData.size();
            total += chunk;
        }
    }
    return total;
}

qint64 wav_file::writeData(const char * data, qint64 len)
{
    Q_UNUSED(data);
    Q_UNUSED(len);

    return 0;
}

QAudioFormat wav_file::format()
{
    QAudioFormat audioFormat;

    audioFormat.setCodec("audio/pcm");
    audioFormat.setByteOrder(QAudioFormat::LittleEndian);
    audioFormat.setSampleRate(m_info.samplerate);
    audioFormat.setChannelCount(m_info.channels);

    switch(m_info.format & 0x0f)
    {
    case SF_FORMAT_PCM_U8:
        audioFormat.setSampleSize(8);
        audioFormat.setSampleType(QAudioFormat::UnSignedInt);
        break;

    case SF_FORMAT_PCM_S8:
        audioFormat.setSampleSize(8);
        audioFormat.setSampleType(QAudioFormat::SignedInt);
        break;

    case SF_FORMAT_PCM_16:
        audioFormat.setSampleSize(16);
        audioFormat.setSampleType(QAudioFormat::SignedInt);
        break;

    case SF_FORMAT_PCM_24:
        audioFormat.setSampleSize(24);
        audioFormat.setSampleType(QAudioFormat::SignedInt);
        break;

    case SF_FORMAT_PCM_32:
        audioFormat.setSampleSize(32);
        audioFormat.setSampleType(QAudioFormat::SignedInt);
        break;

    default:
        audioFormat.setSampleSize(8);
        audioFormat.setSampleType(QAudioFormat::UnSignedInt);
        break;
    }

    return audioFormat;
}

void wav_file::snd_close()
{
    sf_close(m_sndfile);
    this->close();

    m_sndfile = nullptr;
    m_read_pos = 0;
}
