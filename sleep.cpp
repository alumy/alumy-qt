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
    QElapsedTimer timer;
    
    timer.start();
    
    while (timer.elapsed() < ms) {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 50);
	QThread::msleep(10);
    }
}
