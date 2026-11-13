cmake_minimum_required(VERSION 3.21)

project(MediaPlayer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# QtQuick.Effects 的 MultiEffect 需要 Qt 6.5+；
# QuickControls2 提供 qml/Mul_media_mp3.qml 里用到的 Slider
find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2 Sql Multimedia)

qt_standard_project_setup()

qt_add_executable(appMediaPlayer
    rsc/main.cpp
    rsc/myplaylist.cpp
    rsc/lyricmodel.cpp
    myplaylist.h
    lyricmodel.h
)

# 头文件放在仓库根目录，源码在 rsc/，所以要补一个包含路径
target_include_directories(appMediaPlayer PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(appMediaPlayer PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
    Qt6::Multimedia
)

# 源码里有中文字符串，MSVC 需要显式按 UTF-8 解析，否则在某些系统区域设置下会乱码
if(MSVC)
    target_compile_options(appMediaPlayer PRIVATE /utf-8)
endif()

# ---------- QML 与图片资源 ----------
# QML 文件和图片都映射到 qrc:/qml_music/ 下（扁平结构），
# 这样 QML 里 `"./xxx.png"` 这样的相对路径可以直接用，
# main.cpp 里加载 `qrc:/qml_music/main.qml` 即可。
set(QML_SOURCES
    qml/main.qml
    qml/Ai_RowlinBootAnimation.qml
    qml/CoreWindow.qml
    qml/LyricsPanel.qml
    qml/Mul_media_mp3.qml
    qml/PlayList.qml
    qml/PlayList_Listmodel.qml
    qml/SongListview.qml
    qml/BootAnimation.qml
)

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/qml/Flowing.qml")
    list(APPEND QML_SOURCES qml/Flowing.qml)
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/qml/flowing.qml")
    # 兼容旧的小写文件名：QML 里用的是 `Flowing` 类型，用资源别名映射成 Flowing.qml，
    # 避免在大小写敏感的平台上加载失败（建议把文件重命名为 Flowing.qml）。
    list(APPEND QML_SOURCES qml/flowing.qml)
    set_source_files_properties(qml/flowing.qml PROPERTIES QT_RESOURCE_ALIAS Flowing.qml)
endif()

qt_add_resources(appMediaPlayer "qml"
    PREFIX "/qml_music"
    BASE "qml"
    FILES ${QML_SOURCES}
)

qt_add_resources(appMediaPlayer "images"
    PREFIX "/qml_music"
    BASE "assent/image"
    FILES
        assent/image/heart.png
        assent/image/heart-break.png
        assent/image/changenextsong.png
        assent/image/changepresong.png
        assent/image/exit.png
        assent/image/nation_1.png
        assent/image/nation_2.png
        assent/image/demon.png
        assent/image/paper_plane.png
        assent/image/clown.png
        assent/image/handband.png
)

include(GNUInstallDirs)
install(TARGETS appMediaPlayer
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
