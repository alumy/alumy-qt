#ifndef __ALUMYCONFIG_DFT_H
#define __ALUMYCONFIG_DFT_H 1

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __BYTE_ORDER
#define __BYTE_ORDER		__LITTLE_ENDIAN
#endif

/* Verbose log */
#ifndef AL_LOG
#define AL_LOG                  1
#endif

#ifndef AL_DRV_RTC_LOG
#define AL_DRV_RTC_LOG          0
#endif

#ifndef AL_LOG_FS
#define AL_LOG_FS               0
#endif

#ifndef AL_LOG_COLOR
#define AL_LOG_COLOR            1
#endif

#ifndef AL_DYNAMIC_CRC_TABLE
#define AL_DYNAMIC_CRC_TABLE	0
#endif

#ifndef AL_CONFIG_HW_WATCHDOG
#define AL_CONFIG_HW_WATCHDOG		0		/* Hardware watchdog */
#endif

#ifndef AL_CONFIG_WATCHDOG
#define AL_CONFIG_WATCHDOG			0		/* Maybe a software watchdog */
#endif

#ifndef AL_WATCHDOG_RESET
#define AL_WATCHDOG_RESET()			(void)(0)
#endif

#ifdef __cplusplus
}
#endif

#endif

