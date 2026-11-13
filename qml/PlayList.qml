import QtQuick
import QtQuick.Effects
import mymusicmodel 1.0

Component{
    Rectangle{
        id:rect
    width:200
    height: 50
    // opacity: 0.5
    color:"transparent"
    border.width: 0
    Image {
        anchors.left: parent.left
        width: 100
        height:parent.height
        source:model.img
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowColor: "#ffffff"
                        shadowBlur: 20
                    }

        onStatusChanged: {
                console.log("图片状态：", status, " 路径：", source)
                if (status === Image.Error) {
                    console.log("加载失败！")
                }
            }
    }
    Text {
        anchors.right: parent.right
        // anchors.centerIn:Center
        // horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        width: 100
        text: model.label

        color:'white'
    }
    MouseArea{
        anchors.fill: parent
        onClicked: {anim.start();
        playListModel.loadSongs(model.playlistId)
        }
    }
    ParallelAnimation{
        id:anim
    SequentialAnimation{
    ColorAnimation{
        target: rect
        property: "color"
        to:"red"
        duration: 1500
    }
    ColorAnimation{
        target: rect
        property: "color"
        to:"transparent"
        duration: 1500
    }
    }
    SequentialAnimation{
    NumberAnimation{
        target:rect
        property: "opacity"
        to:0
        duration: 1500
    }
    NumberAnimation{
        target:rect
        property: "opacity"
        to:1
        duration: 1500

    }
    }
    }
}
}
