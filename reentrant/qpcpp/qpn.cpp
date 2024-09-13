#include <iostream>
#include <cstdlib>   // for exit()
#include <QDebug>
#include "qpcpp.hpp"

using namespace std;
using namespace QP;

extern "C" Q_NORETURN Q_onError(char const * const file, int_t const line) {
    qDebug() << "Assertion failed in " << file << " line " << line;
    exit(-1);
}
