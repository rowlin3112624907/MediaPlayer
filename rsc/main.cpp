#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include"myplaylist.h"
#include"lyricmodel.h"
#include <QQmlContext>
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QSqlDatabase db= QSqlDatabase::addDatabase("******");//由于没有建库的函数和版权问题，使用者自己接入本地数据库
    db.setHostName("127.0.0.1");
    db.setPort(3306);
    db.setUserName("******");
    db.setPassword("******");
    db.setDatabaseName("******");
    if(!db.open()){
        qDebug()<<"数据库打开失败"<<db.lastError().text();
    }

    MyplayList *myList=new MyplayList();
    myList->setDb(db);
    qmlRegisterType<MyplayList>("mymusicmodel",1,0,"MyPlayList");
    LyricModel *lyricModel = new LyricModel(&app);

    // 必须在 engine.load() 之前注入，否则 SongListview 初始化时 playListModel 还不存在
    engine.rootContext()->setContextProperty("playListModel", myList);
    engine.rootContext()->setContextProperty("lyricModel", lyricModel);

    const QUrl url(QStringLiteral("qrc:/qml_music/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
