import QtQuick
// import"../common"
import "."
// import qml_music
Window {
    id:window
    width: 1500
    height: 900
    visible: true
    title: "自制music"
    color:"#000000"
    flags: Qt.FramelessWindowHint
    //开机动画
    Connections {
        target: pageLoader.item
        onBootFinished: {
            // pageLoader.active=false
            pageLoader.sourceComponent = mainPage
            //pageLoader.active=false
        }
    }
    // 通过loader来控制界面切换
    Loader{
        id: pageLoader
        anchors.fill:parent
        sourceComponent: bootPage
    }
    Rectangle{
        id:exit_btn
        width: 30
        height: 30
        x:1470
        y:0
        color:"transparent"
        Image {
            anchors.fill: parent
            source: "./exit.png"
            fillMode: Image.PreserveAspectFit
        }
        MouseArea{
            anchors.fill: parent
            onClicked: window.close()
        }
    }

    Component {
        id: bootPage
        Ai_RowlinBootAnimation{
            id:bootAnim
            // running:false
            onBootFinished: {
                pageLoader.sourceComponent = mainPage

            }
        }
    }

        Component {
            id: mainPage
            Item {
                id: mainRoot

                PlayList_Listmodel{
                    id:listview
                }

                Rectangle{
                    id:searchRect
                    x:700
                    y:0
                    height: 30
                    width: 150
                    color:'white'
                    radius: 80
                }
                Mul_media_mp3{
                    id:media_1
                    x:0
                    y:800
                    height: 100
                    width:1500
                }

                Flowing{
                    id:flow_1
                    anchors.fill: parent
                }


                Flickable{
                    id:fl_1
                    anchors.left:listview.right
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.top:parent.top
                    anchors.topMargin: 100
                    clip: true
                    height: 200
                    contentWidth: row_1.width
                    contentHeight: height
                    interactive: true


                    readonly property real playProgress: media_1.player.duration > 0
                            ? Math.max(0, Math.min(1, media_1.player.position / media_1.player.duration))
                            : 0

                    readonly property real autoX: Math.max(0, contentWidth - width) * playProgress

                    property bool followMusic: true

                    Binding {
                        target: fl_1
                        property: "contentX"
                        value: fl_1.autoX
                        when: fl_1.followMusic
                        restoreMode: Binding.RestoreNone
                    }

                    Behavior on contentX {
                        enabled: fl_1.followMusic
                        NumberAnimation { duration: 450; easing.type: Easing.Linear }
                    }

                    onMovementStarted: followMusic = false
                    onMovementEnded: resumeFollowTimer.restart()

                    Timer {
                        id: resumeFollowTimer
                        interval: 4000
                        repeat: false
                        onTriggered: fl_1.followMusic = true
                    }

                    Row{
                        id:row_1
                        spacing: 20
                        CoreWindow{
                            m_color: '#FF007F'
                            m_source: "file:///D:/steam/steamapps/workshop/content/431960/3640562722/preview.jpg"
                            m_text: "每日推荐|从【下一个天亮】听起"
                        }
                        CoreWindow{
                            m_color: '#00FFFF'
                            m_source: "file:///D:/steam/steamapps/workshop/content/431960/3711616212/preview.jpg"
                            m_text: "如果对于明天没有要求"
                        }
                        CoreWindow{
                            m_color: '#00FF00'
                            m_source: "file:///D:/steam/steamapps/workshop/content/431960/3146507587/preview.gif"
                            m_text: "闪动如蝴蝶在双颊那是眼泪吗"
                        }
                        CoreWindow{
                            m_color: '#FF0000'
                            m_source: "file:///D:/steam/steamapps/workshop/content/431960/3770637443/preview.jpg"
                            m_text: "我们都被困在这寂寞的夜晚"
                        }
                        CoreWindow{
                            m_color: '#FF8000'
                            m_source: "file:///D:/steam/steamapps/workshop/content/431960/3645016936/preview.jpg"
                            m_text: "我又泪流满面你不在我身边"
                        }
                        CoreWindow{
                            m_color: '#404040'
                            m_source: "file:///D:/steam/steamapps/workshop/content/431960/3768232937/preview.jpg"
                            m_text: "我想要看春天的雨漫"
                        }
                        CoreWindow{
                            m_color: '#FFFF00'
                            m_source: "file:///D:/steam/steamapps/workshop/content/431960/3447993434/preview.jpg"
                            m_text: "这些在冬里哑声呼喊"
                        }
                        CoreWindow{
                            m_source: "file:///D:/steam/steamapps/workshop/content/431960/3642578836/preview.jpg"
                            m_text: "日落不会再逃跑 逃跑的只有美好"
                        }
                    }
                }

                SongListview{
                    id: songList
                    x:200
                    anchors.top: fl_1.bottom
                    anchors.topMargin: 20
                    anchors.bottom: media_1.top
                    anchors.bottomMargin: 20
                    // 歌词栏出现时把歌曲列表收窄，给右侧歌词栏让位
                    width: Math.max(320, lyricsPanel.shown
                           ? (mainRoot.width - lyricsPanel.normalWidth - 20 - x - 20)
                           : (mainRoot.width - x - 20))
                    Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
                    onPlaySong: {
                        media_1.source= "file:///" + path
                        media_1.player.play()
                    }
                }


                LyricsPanel{
                    id: lyricsPanel
                    position: media_1.player.position
                    duration: media_1.player.duration
                    songTitle: playListModel.currentTitle
                    artist: playListModel.currentArtist
                    lrcSource: playListModel.currentLrcPath
                    shown: playListModel.currentTitle.length > 0
                    onShownChanged: if (!shown) expanded = false

                    x: expanded ? 0 : (mainRoot.width - normalWidth - 20)
                    y: expanded ? 0 : (fl_1.y + fl_1.height + 20)
                    width: expanded ? mainRoot.width : normalWidth
                    height: expanded ? media_1.y : (media_1.y - 20 - y)
                    z: expanded ? 100 : 10

                    Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
                    Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
                }
                // Rectangle{
                //     id:exit_btn
                //     width: 30
                //     height: 30
                //     x:1470
                //     y:0
                //     color:"transparent"
                //     Image {
                //         anchors.fill: parent
                //         source: "./exit.png"
                //         fillMode: Image.PreserveAspectFit
                //     }
                //     MouseArea{
                //         anchors.fill: parent
                //         onClicked: window.close()
                //     }
                // }
            }
        }

}
