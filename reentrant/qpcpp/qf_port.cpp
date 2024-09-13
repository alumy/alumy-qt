//============================================================================
// QP/C++ Real-Time Embedded Framework (RTEF)
// Copyright (C) 2005 Quantum Leaps, LLC <state-machine.com>.
//
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-QL-commercial
//
// This software is dual-licensed under the terms of the open source GNU
// General Public License version 3 (or any later version), or alternatively,
// under the terms of one of the closed source Quantum Leaps commercial
// licenses.
//
// The terms of the open source GNU General Public License version 3
// can be found at: <www.gnu.org/licenses/gpl-3.0>
//
// The terms of the closed source Quantum Leaps commercial licenses
// can be found at: <www.state-machine.com/licensing>
//
// Redistributions in source code must retain this top-level comment block.
// Plagiarizing this software to sidestep the license obligations is illegal.
//
// Contact information:
// <www.state-machine.com/licensing>
// <info@state-machine.com>
//============================================================================
//! @date Last updated on: 2023-11-30
//! @version Last updated for: @ref qpc_7_3_1
//!
//! @file
//! @brief QF/C++ port to POSIX (multithreaded with P-threads)

// expose features from the 2008 POSIX standard (IEEE Standard 1003.1-2008)
#define _POSIX_C_SOURCE 200809L

#define QP_IMPL             // this is QP implementation
#include "qp_port.hpp"      // QP port
#include "qp_pkg.hpp"       // QP package-scope interface
#include "qsafe.h"          // QP Functional Safety (FuSa) Subsystem
#ifdef Q_SPY                // QS software tracing enabled?
    #include "qs_port.hpp"  // QS port
    #include "qs_pkg.hpp"   // QS package-scope internal interface
#else
    #include "qs_dummy.hpp" // disable the QS software tracing
#endif // Q_SPY

#include <limits.h>         // for PTHREAD_STACK_MIN
#include <sys/mman.h>       // for mlockall()
#include <sys/ioctl.h>
#include <time.h>           // for clock_nanosleep()
#include <string.h>         // for memcpy() and memset()
#include <stdlib.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <signal.h>

namespace { // unnamed local namespace

Q_DEFINE_THIS_MODULE("qf_port")

} // unnamed local namespace

//============================================================================
namespace QP {
namespace QF {

// NOTE: initialize the critical section mutex as non-recursive,
// but check that nesting of critical sections never occurs
// (see QF::enterCriticalSection_()/QF::leaveCriticalSection_()
pthread_mutex_t critSectMutex_ = PTHREAD_MUTEX_INITIALIZER;
int_t critSectNest_;

//............................................................................
void enterCriticalSection_() {
    pthread_mutex_lock(&critSectMutex_);
    Q_ASSERT_INCRIT(100, critSectNest_ == 0); // NO nesting of crit.sect!
    ++critSectNest_;
}
//............................................................................
void leaveCriticalSection_() {
    Q_ASSERT_INCRIT(200, critSectNest_ == 1); // crit.sect. must ballace!
    if ((--critSectNest_) == 0) {
        pthread_mutex_unlock(&critSectMutex_);
    }
}

}
} // namespace QP

//============================================================================
// NOTE01:
// In Linux, the scheduler policy closest to real-time is the SCHED_FIFO
// policy, available only with superuser privileges. QF::run() attempts to set
// this policy as well as to maximize its priority, so that the ticking
// occurs in the most timely manner (as close to an interrupt as possible).
// However, setting the SCHED_FIFO policy might fail, most probably due to
// insufficient privileges.
//
// NOTE03:
// Any blocking system call, such as clock_nanosleep() system call can
// be interrupted by a signal, such as ^C from the keyboard. In this case this
// QF port breaks out of the event-loop and returns to main() that exits and
// terminates all spawned p-threads.
//
// NOTE04:
// According to the man pages (for pthread_attr_setschedpolicy) the only value
// supported in the Linux p-threads implementation is PTHREAD_SCOPE_SYSTEM,
// meaning that the threads contend for CPU time with all processes running on
// the machine. In particular, thread priorities are interpreted relative to
// the priorities of all other processes on the machine.
//
// This is good, because it seems that if we set the priorities high enough,
// no other process (or thread running within) can gain control over the CPU.
//
// However, QF limits the number of priority levels to QF_MAX_ACTIVE.
// Assuming that a QF application will be real-time, this port reserves the
// three highest p-thread priorities for the ISR-like threads (e.g., I/O),
// and the rest highest-priorities for the active objects.
//

