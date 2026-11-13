import QtQuick 2.15
Rectangle{
    id:songrect
    signal playSong(string path)
    width: 1200
    height: 450
    //radius: 50
    color: 'transparent'
    border.color: Qt.rgba(Math.random(),Math.random(),Math.random(),Math.random())
    border.width: 5
ListView{
    id:songview
    width: songrect.width
    height: songrect.height
    // anchors.top: parent.top
    // anchors.topMargin: 50
    clip: true
    model: playListModel
    delegate:
        Rectangle{
        id:rect
        width: songview.width
        height: 50
        color: 'transparent'
        border.color: Qt.rgba(Math.random(),Math.random(),Math.random(),Math.random())
        radius: 50
        Text{
            id:text_1
            text: model.title
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "blue"
            font.pixelSize: 16
        }
        Text{
            id:text_2
            text: model.artist
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "red"
            font.pixelSize: 12
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (model.audiopath && model.audiopath.length > 0)
                    songrect.playSong(model.audiopath)

                playListModel.setCurrentpath(index)
            }
        }

    }
}
}
