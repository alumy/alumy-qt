#ifndef SLEEP_H
#define SLEEP_H

#include <QObject>
#include "alumy/config.h"
#include "alumy/base.h"
#include "alumy/types.h"

class sleep : public QObject
{
    Q_OBJECT
public:
    explicit sleep(QObject *parent = nullptr);

    static void msleep(int_t ms);

signals:

};

#endif // SLEEP_H
