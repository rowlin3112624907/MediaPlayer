cmake\_minimum\_required(VERSION 3.16)



project(qml\_music VERSION 0.1 LANGUAGES CXX)



set(CMAKE\_AUTOMOC ON)

set(CMAKE\_CXX\_STANDARD\_REQUIRED ON)



find\_package(Qt6 6.2 COMPONENTS Quick REQUIRED Sql Multimedia)



qt\_add\_executable(appqml\_music

&#x20;   rsc/main.cpp

)



qt\_add\_qml\_module(appqml\_music

&#x20;   URI qml\_music

&#x20;   VERSION 1.0

&#x20;   QML\_FILES 

&#x20;    *qml/*main.qml

&#x20;    *qml/*PlayList.qml

&#x20;    *qml/*CoreWindow.qml

&#x20;    *qml/*BootAnimation.qml

&#x20;    QML\_FILES *qml/*Ai\_RowlinBootAnimation.qml

&#x20;    QML\_FILES

&#x20;    QML\_FILES *qml/*Flowing.qml

&#x20;    SOURCES

&#x20;    SOURCES myplaylist.h qml/myplaylist.cpp

&#x20;    QML\_FILES qml/PlayList_*Listmodel.qml

&#x20;    RESOURCES

&#x20;    assent/image/heart.png

&#x20;    assent/image/heart-break.png

&#x20;    assent/image/changenextsong.png

&#x20;    assent/image/changepresong.png

&#x20;    assent/image/exit.png

&#x20;    assent/image/nation\_1.png

&#x20;    assent/image/nation\_2.png

&#x20;    assent/image/demon.png

&#x20;    assent/image/paper\_plane.png

&#x20;    assent/image/clown.png

&#x20;    assent/image/handband.png

&#x20;    QML\_FILES qml/SongListview.qml

&#x20;    QML\_FILES qml/Mul\_media\_mp3.qml

&#x20;    QML\_FILES qml/LyricsPanel.qml

&#x20;    SOURCES lyricmodel.h qml/lyricmodel.cpp

&#x20;    # SOURCES

)



\# Qt for iOS sets MACOSX\_BUNDLE\_GUI\_IDENTIFIER automatically since Qt 6.1.

\# If you are developing for iOS or macOS you should consider setting an

\# explicit, fixed bundle identifier manually though.

set\_target\_properties(appqml\_music PROPERTIES

\#    MACOSX\_BUNDLE\_GUI\_IDENTIFIER com.example.appqml\_music

&#x20;   MACOSX\_BUNDLE\_BUNDLE\_VERSION ${PROJECT\_VERSION}

&#x20;   MACOSX\_BUNDLE\_SHORT\_VERSION\_STRING ${PROJECT\_VERSION\_MAJOR}.${PROJECT\_VERSION\_MINOR}

&#x20;   MACOSX\_BUNDLE TRUE

&#x20;   WIN32\_EXECUTABLE TRUE

)



target\_link\_libraries(appqml\_music

&#x20;   PRIVATE Qt6::Quick  Qt6::Sql Qt6::Multimedia)



include(GNUInstallDirs)

install(TARGETS appqml\_music

&#x20;   BUNDLE DESTINATION .

&#x20;   LIBRARY DESTINATION ${CMAKE\_INSTALL\_LIBDIR})



