#include <QEventLoop>
#include <QTimer>
#include "alumy/sleep.h"
#include "alumy/config.h"
#include "alumy/types.h"

sleep::sleep(QObject *parent) : QObject(parent)
{

}

void sleep::msleep(int_t ms)
{
    QEventLoop loop;

    QTimer::singleShot(ms, &loop, SLOT(quit()));
    loop.exec();
}
