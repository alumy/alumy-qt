#include <QApplication>
#include <QWidget>
#include <alumy.h>  // This should now work with log4qt dependencies resolved

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    // Initialize alumy
    alumy_init();
    
    // Create a simple test widget
    QWidget window;
    window.resize(320, 240);
    window.setWindowTitle("Test FetchContent with Alumy");
    window.show();

    // Cleanup
    alumy_cleanup();
    
    return app.exec();
}
