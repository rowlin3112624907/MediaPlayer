import QtQuick

Item {
    width: 200
    height: 200
    // property alais radius: raduis
    property alias m_source: image_1.source
    property alias m_text: text_2.text
    property alias m_color: text_2.color
    Rectangle{
        anchors.fill: parent
        radius: 10
        color: "transparent"
        border.color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1.0)
        border.width: 3
         clip: true
        AnimatedImage {
            playing: true
            width: 200
            height: 150
            id: image_1
            //clip: true
           anchors.topMargin: 10
            source: "file"
            fillMode: Image.PreserveAspectFit
        }

        Rectangle{
            width: 200
            height: 50
            color: "transparent"
            anchors.top:image_1.bottom
            Text {
                id:text_2
                text: ""
                color: "#7F00FF"
                font.italic: true
                wrapMode: Text.WordWrap
            }
        }
    }

}
