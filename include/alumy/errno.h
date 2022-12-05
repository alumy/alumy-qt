#ifndef __AL_ERRNO_H
#define __AL_ERRNO_H 1

#include <errno.h>
#include "alumy/config.h"
#include "alumy/types.h"
#include "alumy/base.h"

__BEGIN_DECLS

void set_errno(int errnum);

__END_DECLS

#endif
