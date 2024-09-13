#include "alumy/net/host_slip_remote.h"
#include "alumy/mod_log.h"

AL_BEGIN_NAMESPACE

host_slip_remote::host_slip_remote(uint8_t addr) :
    m_addr(addr)
{

}

uint8_t host_slip_remote::addr()
{
    return m_addr;
}

void host_slip_remote::set_addr(uint8_t addr)
{
    m_addr = addr;
}

void host_slip_remote::set_dbg(bool dbg)
{
    m_dbg = dbg;
}

uint8_t host_slip_remote::init()
{
    return m_init;
}

void host_slip_remote::set_init(uint8_t init)
{
    m_init = init;
}

bool host_slip_remote::connected()
{
    return m_connected;
}

void host_slip_remote::set_connected(bool connected)
{
    m_connected = connected;
}

bool host_slip_remote::link_up()
{
    return m_link_up;
}

void host_slip_remote::set_link_up(bool up)
{
    m_link_up = up;
}

bool host_slip_remote::link_dn()
{
    return m_link_dn;
}

void host_slip_remote::set_link_dn(bool dn)
{
    m_link_dn = dn;
}

uint32_t host_slip_remote::hbt_tick()
{
    return m_hbt_tick;
}

void host_slip_remote::set_hbt_tick(uint32_t tick)
{
    m_hbt_tick = tick;
}

int16_t host_slip_remote::recv_seq()
{
    return m_recv_seq;
}

void host_slip_remote::set_recv_seq(int16_t seq)
{
    m_recv_seq = seq;
}

int16_t host_slip_remote::curr_seq()
{
    return m_curr_seq;
}

void host_slip_remote::set_curr_seq(int16_t seq)
{
    m_curr_seq = seq;
}

uint8_t host_slip_remote::send_seq()
{
    return m_send_seq;
}

void host_slip_remote::set_send_seq(uint8_t seq)
{
    m_send_seq = seq;
}

void host_slip_remote::send_seq_inc()
{
    m_send_seq++;
}

const al_version_t *host_slip_remote::version()
{
    return &m_version;
}

void host_slip_remote::set_version(const al_version_t *version)
{
    memcpy(&m_version, version, sizeof(m_version));
}

AL_END_NAMESPACE
