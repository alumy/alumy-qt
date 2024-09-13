#ifndef HOST_SLIP_H
#define HOST_SLIP_H

#include <QObject>
#include <QVector>
#include <QByteArray>
#include <QElapsedTimer>
#include <QMutex>
#include "alumy/net/slip.h"
#include "alumy/net/host_slip_remote.h"
#include "alumy/defs.h"

AL_BEGIN_NAMESPACE

class host_slip : public QThread
{
    Q_OBJECT

public:
#define INIT_HOST_SLIP_HEADER(slip, ptr, daddr, cmd)		do {	\
    (ptr)->sh_saddr = (slip)->addr();                               \
    (ptr)->sh_daddr = (daddr);										\
    (ptr)->sh_cmd = (cmd);											\
} while(0)

public:
    enum {
        CMD_UNKNOWN = 0,
        CMD_ACK,
        CMD_RESET,
        CMD_INIT,
        CMD_HBT,
        CMD_USER,
    };

    enum {
        ADDR_BOARDCAST = 255,
    };

    enum {
        RTX_MAX_COUNT = 1024
    };

    typedef int_t (host_slip::*parse_fp)(QByteArray data);

public:
    typedef struct header {
        uint8_t sh_saddr;
        uint8_t sh_daddr;
        uint8_t sh_cmd;
        uint8_t sh_seq;
    } __packed header_t;

    typedef struct end {
        uint16_t crc;
    } __packed end_t;

    typedef struct report_init {
        uint8_t saddr;
        uint8_t daddr;
        uint8_t type;
        uint8_t seq;
        uint16_t major;
        uint16_t minor;
        uint16_t revision;
        uint16_t build;
        char git_hash[8];
        uint16_t crc;
    } __packed report_init_t;

    typedef struct reset {
        uint8_t saddr;
        uint8_t daddr;
        uint8_t type;
        uint8_t seq;
        uint16_t crc;
    } __packed reset_t;

    typedef struct heartbeat {
        uint8_t saddr;
        uint8_t daddr;
        uint8_t type;
        uint8_t seq;
        uint16_t crc;
    } __packed heartbeat_t;

    typedef struct ack {
        uint8_t saddr;
        uint8_t daddr;
        uint8_t cmd;
        uint8_t seq;
        uint8_t ack;
        uint16_t crc;
    } __packed ack_t;

private:
    typedef struct send_item {
        uint32_t tick;
        int_t retries;
        int_t rtx;
        QByteArray data;

        friend bool operator==(const struct send_item &a, const struct send_item  &b)
        {
            const header_t *ha = (const header_t *)a.data.data();
            const header_t *hb = (const header_t *)b.data.data();

            if(a.data.length() < (ssize_t)sizeof(header_t) ||
               b.data.length() < (ssize_t)sizeof(header_t)) {
                return false;
            }

            return ((ha->sh_saddr == hb->sh_saddr) && (ha->sh_daddr == hb->sh_daddr));
        }
    } send_item_t;

public:
    explicit host_slip(QString path, int32_t baud, QSerialPort::DataBits data_bits,
                       QSerialPort::StopBits stop_bits, QSerialPort::Parity parity,
                       uint8_t addr, QVector<host_slip_remote> remote, al_version_t version,
                       int_t processor = -1, uint32_t hbt_timeout = 3000, uint32_t hbt_period = 500,
                       uint32_t rtx_timeout = 200, size_t recv_size = 4096);
     ~host_slip();

    uint8_t addr();

    int_t send_add(QByteArray data, int_t retries);
    int_t send_add(const void *data, size_t len, int_t retries);
    int_t send_add_tail(QByteArray data, int_t retries);
    int_t send_add_tail(const void *data, size_t len, int_t retries);
    int_t ack(uint8_t daddr, uint8_t ack, uint8_t seq);
    int_t ack(QByteArray data, uint8_t __ack);
    int_t report_init(uint8_t daddr);
    int_t report_reset(uint8_t daddr);
    int_t send_hbt(uint8_t daddr);

    host_slip_remote *remote(uint8_t addr);
    const al_version_t *remote_version(uint8_t addr);
    bool remote_is_init(uint8_t addr);

    void set_dbg(bool dbg);

signals:
    void remote_init(uint8_t addr);
    void connected(uint8_t addr);
    void disconnect(uint8_t addr);
    void link_up(uint8_t addr);
    void link_dn(uint8_t addr);
    void parse_do(QByteArray data);
    void send_add_sig(QByteArray data, int_t retries);
    void send_add_tail_sig(QByteArray data, int_t retries);

private slots:
    void recv_data(QByteArray data);
    int_t __send_add(QByteArray data, int_t retries);
    int_t __send_add_tail(QByteArray data, int_t retries);

private:
    int_t send_item_index(QList<send_item_t> *ls, uint8_t addr, uint8_t seq);

    bool has_rtx(const send_item_t &item);

    int_t parse(QByteArray data);
    int_t parse_heartbeat(QByteArray data);
    int_t parse_report_init(QByteArray data);
    int_t parse_reset(QByteArray data);
    int_t parse_ack(QByteArray data);
    int __parse_do(QByteArray data);
    int_t check(QByteArray data);
    int_t update_seq(QByteArray *data);
    void set_link_dn(uint8_t saddr);
    void set_link_up(uint8_t saddr);

    void recv_routine();
    void reset_routine();
    void send_hbt_routine();
    void send_routine();
    void check_hbt();

    void debug(QString ident, const QByteArray &data);
    void warn(QString ident, const QByteArray &data);

    void run();

private:
    slip *m_slip;
    int_t m_processor;
    QMutex m_recv_mutex;
    QList<QByteArray> m_recv_ls;
    QVector<host_slip_remote> m_remote;
    QList<send_item_t> m_send_ls;
    QList<send_item_t> m_wait_ack_ls;
    QList<send_item_t> m_rtx_ls;

    bool m_dbg = false;
    uint8_t m_addr;
    al_version_t m_version;

    uint32_t m_hbt_tick = 0;
    uint32_t m_hbt_timeout;
    uint32_t m_hbt_period;
    uint32_t m_rtx_timeout;

    uint32_t m_init_tick = 0;
    const uint32_t m_init_timeout = 100;

    QElapsedTimer *m_elapsed_timer;
    QMutex m_mutex;
};

AL_END_NAMESPACE

#endif // HOST_SLIP_H
