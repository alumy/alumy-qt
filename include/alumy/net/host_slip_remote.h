#ifndef HOST_SLIP_REMOTE_H
#define HOST_SLIP_REMOTE_H

#include <QObject>
#include <QTime>
#include "alumy/version.h"
#include "alumy/defs.h"

AL_BEGIN_NAMESPACE

class host_slip_remote
{
public:
    enum {
        HOST_SLIP_REMOTE_INIT = 0,
        HOST_SLIP_REMOTE_OK,
    };

    enum {
        HOST_SLIP_RECV_SEQ_COUNT = 96
    };

public:
    explicit host_slip_remote(uint8_t addr = 0);

    void set_dbg(bool dbg);

    uint8_t addr();
    void set_addr(uint8_t addr);

    uint8_t init();
    void set_init(uint8_t init);

    bool connected();
    void set_connected(bool connected);

    bool link_up();
    void set_link_up(bool up);

    bool link_dn();
    void set_link_dn(bool dn);

    uint32_t hbt_tick();
    void set_hbt_tick(uint32_t tick);

    uint8_t send_seq();
    void set_send_seq(uint8_t seq);
    void send_seq_inc();

    int16_t recv_seq();
    void set_recv_seq(int16_t seq);

    int16_t curr_seq();
    void set_curr_seq(int16_t seq);

    const al_version_t *version();
    void set_version(const al_version_t *version);

    friend bool operator==(const host_slip_remote &a, const host_slip_remote  &b)
    {
        return (a.m_addr == b.m_addr);
    }

    host_slip_remote& operator=(const host_slip_remote &a)
    {
        this->m_addr = a.m_addr;
        this->m_init = a.m_init;
        this->m_connected = a.m_connected;
        this->m_link_up = a.m_link_up;
        this->m_link_dn = a.m_link_dn;
        this->m_hbt_tick = a.m_hbt_tick;
        this->m_version = a.m_version;
        this->m_send_seq = a.m_send_seq;
        this->m_recv_seq = a.m_recv_seq;
        this->m_curr_seq = a.m_curr_seq;
        return *this;
      }

signals:

private:
    bool m_dbg;
    uint8_t m_addr;
    uint8_t m_init = HOST_SLIP_REMOTE_INIT;
    bool m_connected = false;
    bool m_link_up = false;
    bool m_link_dn = false;
    uint32_t m_hbt_tick = 0;
    uint8_t m_send_seq = 0;
    int16_t m_recv_seq = -1;
    int16_t m_curr_seq = -1;
    al_version_t m_version = AL_VERSION_INIT(0, 0, 0, 0, "");
};

AL_END_NAMESPACE

#endif // HOST_SLIP_REMOTE_H
