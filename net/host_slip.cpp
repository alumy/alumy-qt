#include <QByteArray>
#include <QApplication>
#include "alumy/net/host_slip.h"
#include "alumy/mod_log.h"
#include "alumy/crc.h"
#include "alumy/byteswap.h"
#include "alumy/string.h"
#include "alumy/check.h"
#include "alumy/ascii.h"
#include "alumy/sleep.h"
#include "alumy/bug.h"
#include "alumy/spdlog.h"

AL_BEGIN_NAMESPACE

host_slip::host_slip(QString path, int32_t baud, QSerialPort::DataBits data_bits,
                     QSerialPort::StopBits stop_bits, QSerialPort::Parity parity,
                     uint8_t addr, QVector<host_slip_remote> remote, al_version_t version,
                     int_t processor, uint32_t hbt_timeout, uint32_t hbt_period, uint32_t rtx_timeout,
                     size_t recv_size) :
    m_processor(processor),
    m_remote(remote),
    m_addr(addr),
    m_version(version),
    m_hbt_timeout(hbt_timeout),
    m_hbt_period(hbt_period),
    m_rtx_timeout(rtx_timeout)
{
    m_elapsed_timer = new QElapsedTimer();
    m_elapsed_timer->start();

    m_slip = new slip(path, baud, data_bits, stop_bits, parity, recv_size);
    connect(m_slip, &slip::received, this, &host_slip::recv_data);

    connect(this, &host_slip::send_add_sig, this, &host_slip::__send_add);
    connect(this, &host_slip::send_add_tail_sig, this, &host_slip::__send_add_tail);
}

host_slip::~host_slip()
{
    delete m_slip;
    delete m_elapsed_timer;
}

uint8_t host_slip::addr()
{
    return m_addr;
}

void host_slip::recv_data(QByteArray data)
{
    QMutexLocker locker(&m_recv_mutex);

    m_recv_ls.append(data);
}

bool host_slip::has_rtx(const send_item_t &item)
{
    int_t rtx = 0;

    for(int_t i = 0; i < m_rtx_ls.count(); ++i) {
        send_item_t __item = m_rtx_ls.at(i);

        const header_t *__item_h = (const header_t *)__item.data.data();
        const header_t *item_h = (const header_t *)item.data.data();

        if((__item_h->sh_saddr == item_h->sh_saddr) && (__item_h->sh_daddr == item_h->sh_daddr)) {
            rtx++;

            if(rtx >= RTX_MAX_COUNT) {
                slog::instance()->debug("rtx, saddr = {}, daddr = {}", __item_h->sh_saddr, __item_h->sh_daddr);
                return true;
            }
        }
    }

    return false;
}

int_t host_slip::__send_add(QByteArray data, int_t retries)
{
    QMutexLocker locker(&m_mutex);

    send_item_t item;

    item.data = data;
    item.tick = 0;
    item.retries = retries;
    item.rtx = 0;

    if(has_rtx(item)) {
        warn("has rtx", item.data);
        errno = EEXIST;
        return -1;
    }

    m_send_ls.prepend(item);

    return 0;
}

int_t host_slip::send_add(QByteArray data, int_t retries)
{
    emit send_add_sig(data, retries);

    return 0;
}

int_t host_slip::send_add(const void *data, size_t len, int_t retries)
{
    return send_add(QByteArray((const char *)data, len), retries);
}

int_t host_slip::__send_add_tail(QByteArray data, int_t retries)
{
    QMutexLocker locker(&m_mutex);

    send_item_t item;

    item.tick = 0;
    item.retries = retries;
    item.data = data;
    item.rtx = 0;

    if(has_rtx(item)) {
        warn("has rtx", item.data);
        errno = EEXIST;
        return -1;
    }

    m_send_ls.append(item);

    return 0;
}

int_t host_slip::send_add_tail(QByteArray data, int_t retries)
{
    emit send_add_tail_sig(data, retries);

    return 0;
}

int_t host_slip::send_add_tail(const void *data, size_t len, int_t retries)
{
    return send_add_tail(QByteArray((const char *)data, len), retries);
}

int_t host_slip::send_item_index(QList<send_item_t> *ls, uint8_t addr, uint8_t seq)
{
    int_t cnt = ls->count();

    for(int_t i = 0; i < cnt; ++i) {
        send_item_t tmp = ls->at(i);

        const header_t *hdr = (const header_t *)tmp.data.data();

        if(hdr->sh_daddr == addr && hdr->sh_seq == seq) {
            return i;
        }
    }

    return -1;
}

int_t host_slip::ack(uint8_t daddr, uint8_t ack, uint8_t seq)
{
    ack_t payload;

    payload.saddr = m_addr;
    payload.daddr = daddr;
    payload.ack = ack;
    payload.cmd = CMD_ACK;
    payload.seq = seq;

    uint16_t crc = mb_get_crc16(&payload, sizeof(payload) - sizeof(uint16_t));
    payload.crc = al_htons(crc);

    return send_add(QByteArray((const char *)&payload, sizeof(payload)), 0);
}

int_t host_slip::ack(QByteArray data, uint8_t __ack)
{
    AL_CHECK_RET(data.length() > (int)sizeof(header_t), EINVAL, -1);

    const header_t *hdr = (const header_t *)data.data();

    return ack(hdr->sh_saddr, __ack, hdr->sh_seq);
}

int_t host_slip::report_init(uint8_t daddr)
{
    report_init_t payload;
    uint16_t crc;

    const char *git_hash = al_version_get_git_hash(&m_version);

    payload.saddr = m_addr;
    payload.daddr = daddr;
    payload.type = CMD_INIT;
    payload.major = al_version_get_major(&m_version);
    payload.minor = al_version_get_minor(&m_version);
    payload.revision = al_version_get_rev(&m_version);
    payload.build = al_version_get_build(&m_version);
    strlcpy(payload.git_hash, git_hash, sizeof(payload.git_hash));

    crc = mb_get_crc16(&payload, sizeof(payload) - sizeof(payload.crc));
    payload.crc = al_htons(crc);

    return send_add_tail(QByteArray((const char *)&payload, sizeof(payload)), 10);
}

int_t host_slip::report_reset(uint8_t daddr)
{
    reset_t payload;
    uint16_t crc;

    payload.saddr = m_addr;
    payload.daddr = daddr;
    payload.type = CMD_RESET;

    crc = mb_get_crc16(&payload, sizeof(payload) - sizeof(payload.crc));
    payload.crc = al_htons(crc);

    return send_add_tail(QByteArray((const char *)&payload, sizeof(payload)), 0);
}

int_t host_slip::send_hbt(uint8_t daddr)
{
    heartbeat_t payload;
    uint16_t crc;

    payload.saddr = m_addr;
    payload.daddr = daddr;
    payload.type = CMD_HBT;

    crc = mb_get_crc16(&payload, sizeof(payload) - sizeof(payload.crc));
    payload.crc = al_htons(crc);

    return send_add_tail(QByteArray((const char *)&payload, sizeof(payload)), 0);
}

int_t host_slip::parse_heartbeat(QByteArray data)
{
    const heartbeat_t *hbt = (const heartbeat_t *)data.data();

    ack(hbt->saddr, AL_ACK, hbt->seq);

    return 0;
}

int_t host_slip::parse_report_init(QByteArray data)
{
    QMutexLocker locker(&m_mutex);

    if(data.length() < (ssize_t)sizeof(report_init_t)) {
        return -1;
    }

    const report_init_t *payload = (const report_init_t *)data.data();

    ack(payload->saddr, AL_ACK, payload->seq);

    host_slip_remote *r = remote(payload->saddr);
    BUG_ON(r == nullptr);

    if(r->init() == host_slip_remote::HOST_SLIP_REMOTE_INIT) {
        al_version_t version;

        al_version_init(&version,
                        payload->major, payload->minor, payload->revision,
                        payload->build, payload->git_hash);

        r->set_version(&version);
        r->set_init(host_slip_remote::HOST_SLIP_REMOTE_OK);

        QString git_hash;

        if(strlen(payload->git_hash) > 0) {
            git_hash.sprintf("-%*.s", 7, payload->git_hash);
        }

        slog::instance()->info("remote init, addr = {}, version = {}.{}.{}.{}",
                                payload->saddr, payload->major, payload->minor,
                                payload->revision, payload->build, git_hash);

        emit remote_init(r->addr());
    }

    return 0;
}

int_t host_slip::parse_reset(QByteArray data)
{
    const reset_t *reset = (const reset_t *)data.data();

    /* send ack */
    ack(reset->saddr, AL_ACK, reset->seq);
    /* report init */
    report_init(reset->saddr);

    return 0;
}

int_t host_slip::parse_ack(QByteArray data)
{
    QMutexLocker locker(&m_mutex);

    if(data.length() < (ssize_t)sizeof(ack_t)) {
        return -1;
    }

    const ack_t *ack = (const ack_t *)data.data();

    if (ack->daddr == m_addr && ack->ack == AL_ACK) {
        uint32_t tick = m_elapsed_timer->elapsed();

        host_slip_remote *r = remote(ack->saddr);

        BUG_ON(r == nullptr);

        r->set_hbt_tick(tick);

        int_t idx = send_item_index(&m_wait_ack_ls, ack->saddr, ack->seq);
        if(idx >= 0) {
            m_wait_ack_ls.removeAt(idx);
            r->set_curr_seq(-1);
        }
    }

    return 0;
}

int_t host_slip::__parse_do(QByteArray data)
{
    static const parse_fp parse_tab[] = {
        [CMD_UNKNOWN] = nullptr,
        [CMD_ACK] = &host_slip::parse_ack,
        [CMD_RESET] = &host_slip::parse_reset,
        [CMD_INIT] = &host_slip::parse_report_init,
        [CMD_HBT] = &host_slip::parse_heartbeat,
        [CMD_USER] = nullptr,
    };

    const uint8_t *d = (const uint8_t *)data.data();
    const header_t *hdr = (const header_t *)d;

    if (hdr->sh_cmd < ARRAY_SIZE(parse_tab)) {
        if (parse_tab[hdr->sh_cmd] != NULL) {
            const parse_fp fp = parse_tab[hdr->sh_cmd];
            return (this->*fp)(data);
        }
    }

    return -1;
}

int_t host_slip::parse(QByteArray data)
{
    const uint8_t *d = (const uint8_t *)data.data();
    const header_t *hdr = (const header_t *)d;
    size_t len = data.length();

    UNUSED(len);

    if (check(data) != 0) {
        slog::instance()->warn("host slip check failed");
        slog::instance()->warn(data);
        return -1;
    }

    debug("rx", data);

    if (hdr->sh_daddr != m_addr && hdr->sh_daddr != ADDR_BOARDCAST) {
        return 0;
    }

    host_slip_remote *r = remote(hdr->sh_saddr);

    set_link_dn(hdr->sh_saddr);

    if (hdr->sh_cmd != CMD_ACK && hdr->sh_cmd != CMD_INIT && hdr->sh_cmd != CMD_RESET) {
        if (r && r->recv_seq() == hdr->sh_seq) {
            ack(hdr->sh_saddr, AL_ACK, hdr->sh_seq);
            slog::instance()->debug("remote {} seq {} exists", hdr->sh_saddr, hdr->sh_seq);
            return -1;
        }
    }

    if (hdr->sh_cmd != CMD_ACK && r) {
        r->set_recv_seq(hdr->sh_seq);
    }

    __parse_do(data);

    emit parse_do(data);

    return 0;
}

int_t host_slip::check(QByteArray data)
{
    size_t len = data.length();
    const uint8_t *d = (const uint8_t *)data.data();

    AL_CHECK_RET(len > 2, EINVAL, -1);

    uint16_t crc = al_split_read_two(&d[len - 2], false);

    return (crc - mb_get_crc16(d, len - sizeof(crc)));
}

void host_slip::set_link_up(uint8_t daddr)
{
    host_slip_remote *r = remote(daddr);

    if(r) {
        r->set_link_up(!r->link_up());
    }

    emit link_up(daddr);
}

void host_slip::set_link_dn(uint8_t daddr)
{
    host_slip_remote *r = remote(daddr);

    if(r) {
        r->set_link_dn(!r->link_up());
    }

    emit link_dn(daddr);
}

int_t host_slip::update_seq(QByteArray *data)
{
    uint8_t *d = (uint8_t *)data->data();
    header_t *hdr = (header_t *)d;
    uint16_t crc;
    off_t crc_off = data->length() - sizeof(crc);

    if(data->length() < (int)sizeof(crc)) {
        slog::instance()->debug(*data);
    }

    BUG_ON(data->length() < (int)sizeof(crc));

    if (hdr->sh_cmd != CMD_ACK) {
        host_slip_remote *r = remote(hdr->sh_daddr);
        BUG_ON(r == nullptr);

        hdr->sh_seq = r->send_seq();
        r->send_seq_inc();
    }

    crc = mb_get_crc16(d, crc_off);

    al_split_write_two(&d[crc_off], crc, false);

    return 0;
}

void host_slip::recv_routine()
{
    QMutexLocker locker(&m_recv_mutex);

    if(m_recv_ls.count() > 0) {
        parse(m_recv_ls.takeAt(0));
    }
}

void host_slip::reset_routine()
{
    int_t cnt = m_remote.count();

    uint32_t tick = m_elapsed_timer->elapsed();

    if(tick < m_init_tick + m_init_timeout) {
        return;
    }

    m_init_tick = tick;

    for(int_t i = 0; i < cnt; ++i) {
        host_slip_remote *remote = &m_remote[i];

        if(remote->addr() != m_addr) {
            if(remote->init() == host_slip_remote::HOST_SLIP_REMOTE_INIT) {
                report_reset(remote->addr());
            }
        }
    }
}

void host_slip::send_hbt_routine()
{
    int_t cnt = m_remote.count();

    uint32_t tick = m_elapsed_timer->elapsed();

    if(tick > m_hbt_tick + m_hbt_period) {
        m_hbt_tick = tick;

        for(int_t i = 0; i < cnt; ++i) {
            host_slip_remote *r = &m_remote[i];

            if(r->addr() != m_addr && r->connected()) {
                send_hbt(r->addr());
            }
        }
    }
}

void host_slip::check_hbt()
{
    QMutexLocker locker(&m_mutex);

    uint32_t tick = m_elapsed_timer->elapsed();
    uint32_t timeout = m_hbt_timeout;
    int_t cnt = m_remote.count();

    for(int_t i = 0; i < cnt; ++i) {
        host_slip_remote *remote = &m_remote[i];

        if(tick >= remote->hbt_tick() + timeout) {
            if(remote->connected()) {
                remote->set_connected(false);

                remote->set_init(host_slip_remote::HOST_SLIP_REMOTE_INIT);

                slog::instance()->warn("remote {} lost", remote->addr());

                emit disconnect(remote->addr());
            }
        } else {
            if(!remote->connected()) {
                remote->set_connected(true);

                slog::instance()->info("remote {} connected", remote->addr());

                emit connected(remote->addr());
            }
        }
    }
}

void host_slip::send_routine()
{
    uint8_t send_seq;

    QMutexLocker locker(&m_mutex);

    uint32_t tick = m_elapsed_timer->elapsed();

    for(int_t i = 0; i < m_send_ls.count(); ++i) {
        send_item_t send_item = m_send_ls.at(i);

        const header_t *hdr = (const header_t *)send_item.data.data();

        host_slip_remote *r = remote(hdr->sh_daddr);
        BUG_ON(r == nullptr);

        if(r->curr_seq() == -1 || hdr->sh_cmd == CMD_ACK) {
            m_send_ls.removeAt(0);

            send_item.tick = tick;
            send_item.retries--;

            send_seq = r->send_seq();

            update_seq(&send_item.data);

            debug("tx", send_item.data);

            set_link_up(hdr->sh_daddr);

            emit m_slip->write(send_item.data);

            hdr = (const header_t *)send_item.data.data();

            if(hdr->sh_cmd != CMD_ACK) {
                if(send_item.retries > 0) {
                    m_wait_ack_ls.append(send_item);
                    r->set_curr_seq(send_seq);
                }
            }
        }
    }

    for(int_t i = 0; i < m_rtx_ls.count(); ++i) {
        send_item_t send_item = m_rtx_ls.takeAt(i);

        const header_t *hdr = (const header_t *)send_item.data.data();

        host_slip_remote *r = remote(hdr->sh_daddr);
        BUG_ON(r == nullptr);

        if(send_item.rtx == 1) {
            warn("rtx", send_item.data);
        }

        send_item.tick = tick;
        send_item.retries--;

        set_link_up(hdr->sh_daddr);

        emit m_slip->write(send_item.data);

        if(send_item.retries > 0) {
            m_wait_ack_ls.append(send_item);
        } else {
            r->set_curr_seq(-1);
        }
    }

    for(int_t i = 0; i < m_wait_ack_ls.count(); ++i) {
        send_item_t send_item = m_wait_ack_ls.at(i);

        if(tick > send_item.tick + m_rtx_timeout) {
            m_wait_ack_ls.removeAt(i);

            send_item.rtx++;
            m_rtx_ls.append(send_item);
        }
    }
}

void host_slip::debug(QString ident, const QByteArray &data)
{
    const uint8_t *d = (const uint8_t *)data.data();
    const header_t *hdr = (const header_t *)d;

    if(!m_dbg) {
        return;
    }

    QString str = QString("%1, saddr = %2, daddr = %3, cmd = %4, seq = %5")
                    .arg(ident).arg(hdr->sh_saddr).arg(hdr->sh_daddr).arg(hdr->sh_cmd).arg(hdr->sh_seq);

    slog::instance()->debug(str);
}

void host_slip::warn(QString ident, const QByteArray &data)
{
    const uint8_t *d = (const uint8_t *)data.data();
    const header_t *hdr = (const header_t *)d;

    QString str = QString("%1, saddr = %2, daddr = %3, cmd = %4, seq = %5")
                    .arg(ident).arg(hdr->sh_saddr).arg(hdr->sh_daddr).arg(hdr->sh_cmd).arg(hdr->sh_seq);

    slog::instance()->warn(str);
}

void host_slip::run()
{
#if defined(__linux__)
    if(m_processor >= 0) {
        cpu_set_t mask;

        CPU_ZERO(&mask);
        CPU_SET(m_processor, &mask);

        if(pthread_setaffinity_np(pthread_self(), sizeof(mask), &mask) < 0) {
            slog::instance()->error("pthread_setaffinity_np failed @ {}:{}", __func__, __LINE__);
        }
    }
#endif

    for(;;) {
        recv_routine();
        reset_routine();
        send_hbt_routine();
        send_routine();
        check_hbt();

        sleep::msleep(1);
    }
}

host_slip_remote *host_slip::remote(uint8_t addr)
{
    int_t idx = m_remote.indexOf(host_slip_remote(addr));

    return (idx < 0) ? nullptr : &m_remote[idx];
}

const al_version_t *host_slip::remote_version(uint8_t addr)
{
    host_slip_remote *r = remote(addr);

    return r ? r->version() : nullptr;
}

bool host_slip::remote_is_init(uint8_t addr)
{
    host_slip_remote *r = remote(addr);

    return r ? (r->init() == host_slip_remote::HOST_SLIP_REMOTE_OK) : false;
}

void host_slip::set_dbg(bool dbg)
{
    m_dbg = dbg;

    for(int32_t i = 0; i < m_remote.count(); ++i) {
        m_remote[i].set_dbg(m_dbg);
    }
}

AL_END_NAMESPACE
