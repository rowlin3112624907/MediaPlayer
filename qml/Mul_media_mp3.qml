import QtQuick 2.15
import QtMultimedia
import QtQuick.Controls
import mymusicmodel 1.0

Rectangle{
    property alias source: player.source
    property alias player: player
    id:madiuRect
    x:0
    y:800
    height: 100
    width:1500
    color:'transparent'
    border.color: "skyblue"
    radius: 80
    Connections{
        target: playListModel
        function onAudioPathChanged(path) {
            if(!path || path.length === 0)
                return
            var url = path.indexOf("file:///") === 0 ? path : "file:///" + path
            player.source = url
            player.play()
        }
    }


    MediaPlayer{
        id:player
        audioOutput:song_pst
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.EndOfMedia)
                Qt.callLater(function() { playListModel.nextsong() })
        }
    }
    AudioOutput{
        id:song_pst
        volume: 0.4
    }

    // 播放按钮（左侧）
    Rectangle{
        id:bnt_1
        width: 90
        height: 50
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color:'transparent'
        border.color: (player.playbackState===MediaPlayer.PlayingState)?"green":"red"
        Text{
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 16
            text: (player.playbackState===MediaPlayer.PlayingState)?"暂停":"播放"
        }
        MouseArea{
            anchors.fill: parent
            onClicked:{
                if(player.playbackState===MediaPlayer.PlayingState)
                    player.pause()
                else
                    player.play()
            }
        }
    }

    // 音量
    Rectangle{
        id:bnt_2
        width: 200
        height: 50
        anchors.left: bnt_1.right
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        color:'transparent'
        Text{
            id:volume_label
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            font.pixelSize: 14
            text: "音量"
        }
        Slider{
            id:song_pst_volume
            anchors.left: volume_label.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            from: 0
            to: 1
            stepSize: 0.01
            value: song_pst.volume
            onMoved: song_pst.volume = value
        }
    }
//进度条
    Rectangle{
        id:btn_3
        height: 50
        anchors.left: bnt_2.right
        anchors.leftMargin: 30
        anchors.right: parent.right
        anchors.rightMargin: 400
        anchors.verticalCenter: parent.verticalCenter
        color:'transparent'
        border.width: 1
        border.color: Qt.rgba(Math.random(),Math.random(),Math.random(),1)
        Slider{
            id:song_pst_position
            anchors.fill: parent
            anchors.margins: 10
            from: 0
            to: Math.max(player.duration, 1)
            value: player.position
            onMoved: player.setPosition(Math.round(value))

            background: Rectangle{
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 8
                radius: 4
                color: "#33FFFFFF"

                Rectangle{
                    width: song_pst_position.visualPosition * parent.width
                    height: parent.height
                    radius: 4
                    color: "#4FC3F7"
                }
            }
        }
    }
    //上一首
    Rectangle{
        id:changePreSong
        anchors.left: btn_3.right
        anchors.leftMargin: 10
        width: 36
        height: 36
        anchors.verticalCenter: parent.verticalCenter
        color:"transparent"
        Image {
            anchors.fill: parent
            source: "./changepresong.png"
            fillMode: Image.PreserveAspectFit
        }
        MouseArea{
            // MouseArea 不写 anchors.fill 就是 0x0，点不到的
            anchors.fill: parent
            onClicked: playListModel.presong()
        }
    }
    //下一首
    Rectangle{
        id:changenextSong
        anchors.left: changePreSong.right
        anchors.leftMargin: 10
        width: 36
        height: 36
        anchors.verticalCenter: parent.verticalCenter
        color:"transparent"
        Image {
            anchors.fill: parent
            source: "./changenextsong.png"
            fillMode: Image.PreserveAspectFit
        }
        MouseArea{
            anchors.fill: parent
            onClicked: playListModel.nextsong()
        }
    }

    Rectangle{
        id: view
        anchors.left: changenextSong.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        height: 40
        color:"transparent"
        Text{
            anchors.fill: parent
            color: "#CCFFFFFF"
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: playListModel.currentTitle.length > 0
                  ? "♪ " + playListModel.currentTitle + "  ——  " + playListModel.currentArtist
                  : "未播放"
        }
    }

    Connections{
        target: player
        function onPositionChanged(){
            if(!song_pst_position.pressed)
                song_pst_position.value = player.position
        }
        function onDurationChanged(){
            if(!song_pst_position.pressed)
                song_pst_position.value = player.position
        }
    }

    Connections{
        target: song_pst
        function onVolumeChanged(){
            if(!song_pst_volume.pressed)
                song_pst_volume.value = song_pst.volume
        }
    }
}
