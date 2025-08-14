#include <QApplication>
#include <QWidget>
#include <alumy.h>  // This should now work with log4qt dependencies resolved

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    alumy::slog::instance()->info("Test message from alumy log system");

    QWidget window;
    window.resize(320, 240);
    window.setWindowTitle("Test FetchContent with Alumy");
    window.show();

    return app.exec();
}
