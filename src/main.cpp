#include "core/nodebase.h"
#include "core/nodeengine.h"
#include "core/edge.h"
#include "core/graphengine.h"
#include "neurons/neuronengine.h"
#include "neurons/current.h"
#include "neurons/passivecurrent.h"
#include "neurons/adaptationcurrent.h"
#include "io/fileio.h"

#ifndef NEURONIFY_NO_RETINA
#include "retina/retinaengine.h"
#include "retina/retinapainter.h"
#include "retina/receptivefield.h"
#include "retina/videosurface.h"
#endif

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QTextStream>

#include <QtGui>
#include <QtQml>

QQmlApplicationEngine *engine;

void app_init(int argc, char *argv[])
{
    qmlRegisterType<FileIO>("Neuronify", 1, 0, "FileIO");

    qmlRegisterType<NodeBase>("Neuronify", 1, 0, "NodeBase");
    qmlRegisterType<NodeEngine>("Neuronify", 1, 0, "NodeEngine");
    qmlRegisterType<Edge>("Neuronify", 1, 0, "Edge");
    qmlRegisterType<GraphEngine>("Neuronify", 1, 0, "GraphEngine");
    qmlRegisterType<NeuronEngine>("Neuronify", 1, 0, "NeuronEngine");
    qmlRegisterType<Current>("Neuronify", 1, 0, "Current");
    qmlRegisterType<PassiveCurrent>("Neuronify", 1, 0, "PassiveCurrent");
    qmlRegisterType<AdaptationCurrent>("Neuronify", 1, 0, "AdaptationCurrent");

#ifndef NEURONIFY_NO_RETINA
    qmlRegisterType<ReceptiveField>("Neuronify", 1, 0, "ReceptiveField");
    qmlRegisterType<RetinaEngine>("Neuronify", 1, 0, "RetinaEngine");
    qmlRegisterType<RetinaPainter>("Neuronify", 1, 0, "RetinaPainter");
    qmlRegisterType<VideoSurface>("Neuronify", 1, 0, "VideoSurface");
#endif

    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    engine->load(QUrl(QStringLiteral("qrc:///qml/main.qml")));
}

void app_exit() {
    delete engine;
}

#ifdef Q_OS_NACL
Q_GUI_MAIN(app_init, app_exit);
#else
int main(int argc, char **argv) {
    QGuiApplication app(argc, argv);
    app_init(argc, argv);
    app.exec();
    app_exit();
    return 0;
}
#endif
