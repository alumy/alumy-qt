#ifndef __AL_AUDIO_WAV_FILE_H
#define __AL_AUDIO_WAV_FILE_H 1

#include <QIODevice>
#include <QAudioFormat>
#include "sndfile.h"

class wav_file : public QIODevice
{
public:
    wav_file(QObject *parent=nullptr);
    ~wav_file();

    bool snd_open(QString fileName);
    void snd_close();
    QAudioFormat format();

    qint64 readData(char *data, qint64 len) override;
    qint64 writeData(const char * data, qint64 len) override;
    qint64 bytesAvailable() const override;

private:
    qint64 read_all();
    int32_t cell_size();

private:
    SNDFILE *m_sndfile = nullptr;
    SF_INFO m_info;
    QString m_fileName;
    QByteArray m_pcmData;
    qint64 m_read_pos = 0;
};

#endif // WAVFILE_H
