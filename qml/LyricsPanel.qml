import QtQuick
import QtQuick.Dialogs
Item {
    id: root
    property int position: 0
    property int duration: 0
    property string lrcSource: ""
    property string songTitle: ""
    property string artist: ""
    property bool shown: false

    // —— 内部状态 ——
    property bool expanded: false
    property string bgImage: "file:///D:/steam/steamapps/workshop/content/431960/3805734164/preview.jpg"         // 自定义背景图片
    property int activeIndex: -1
    property color highlightColor: "#ff5fae"
    property int normalWidth: 440

    width: normalWidth
    height: 460
    onLrcSourceChanged: reloadLyrics()
    onShownChanged: {
        if (shown)
            reloadLyrics()
        else
            expanded = false
    }
    Component.onCompleted: reloadLyrics()

    onPositionChanged: updateActive()
    onHeightChanged: scheduleScroll()
    onExpandedChanged: scheduleScroll()

    Connections {
        target: lyricModel
        function onCountChanged() {
            root.activeIndex = -1
            root.updateActive()
            root.scheduleScroll()
        }
        function onLoadedChanged() {
            root.activeIndex = -1
            root.updateActive()
            root.scheduleScroll()
        }
    }

    Timer {
        id: scrollTimer
        interval: 70
        repeat: false
        onTriggered: root.scrollToActive()
    }

    function reloadLyrics() {
        lyricModel.loadFile(root.lrcSource)
        root.activeIndex = -1
        updateActive()
        scheduleScroll()
    }

    function updateActive() {
        if (lyricModel.count <= 0) {
            if (root.activeIndex !== -1)
                root.activeIndex = -1
            return
        }
        var idx = lyricModel.indexAt(Math.max(0, root.position))
        if (idx === root.activeIndex)
            return
        root.activeIndex = idx
        if (idx >= 0) {
            root.highlightColor = Qt.hsla(Math.random(), 0.86, 0.62, 1.0)
            scheduleScroll()
        }
    }

    function scheduleScroll() {
        scrollTimer.restart()
    }

    function scrollToActive() {
        if (root.activeIndex < 0 || lyricColumn.children.length === 0)
            return
        var item = lyricColumn.children[root.activeIndex]
        if (!item)
            return
        var target = item.y + item.height / 2 - lyricFlick.height / 2
        var maxY = Math.max(0, lyricFlick.contentHeight - lyricFlick.height)
        followAnim.to = Math.max(0, Math.min(maxY, target))
        followAnim.restart()
    }
    //
    function formatTime(ms) {
        if (ms <= 0)
            return "00:00"
        var total = Math.floor(ms / 1000)
        var m = Math.floor(total / 60)
        var s = total % 60
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }

    // ======================= 面板本体 =======================
    Rectangle {
        id: panelRoot
        anchors.fill: parent
        radius: 18
        clip: true
        color: "transparent"
        border.width: 5
        border.color: "skyblue"

        opacity: root.shown ? 1 : 0
        visible: opacity > 0.01
        x: root.shown ? 0 : 46

        Behavior on opacity { NumberAnimation { duration: 320 } }
        Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

        // 自定义背景图片
        AnimatedImage {
            id: bgImageItem
            anchors.fill: parent
            source: root.bgImage
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            opacity: 0.92
            playing: true
            visible: root.bgImage.length > 0 && status !== Image.Error
        }

        Rectangle {
            anchors.fill: parent
            visible: root.bgImage.length === 0
            color: "transparent"

            // gradient: Gradient {
            //     GradientStop { position: 0.0; color: "#1B2340" }
            //     GradientStop { position: 0.55; color: "#0E1224" }
            //     GradientStop { position: 1.0; color: "#05070F" }
            // }
        }

        // 让文字在任何背景上都清楚可读
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#B3000000" }
                GradientStop { position: 0.30; color: "#40000000" }
                GradientStop { position: 0.70; color: "#59000000" }
                GradientStop { position: 1.0; color: "#CC000000" }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        // ---------- 顶部标题栏 ----------
        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 56

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "♪ 歌词"
                    color: "#F2FFFFFF"
                    font.pixelSize: 17
                    font.bold: true
                }
                Text {
                    width: header.width - 230
                    text: root.songTitle.length > 0
                          ? root.songTitle + (root.artist.length > 0 ? "  -  " + root.artist : "")
                          : ""
                    color: "#99FFFFFF"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Rectangle {
                    width: 64
                    height: 28
                    radius: 14
                    color: bgBtnArea.containsMouse ? "#3DFFFFFF" : "#1AFFFFFF"
                    border.width: 1
                    border.color: "#4DFFFFFF"
                    Text {
                        anchors.centerIn: parent
                        text: "换背景"
                        color: "#E6FFFFFF"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: bgBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: bgDialog.open()
                    }
                }


                Rectangle {
                    width: 48
                    height: 28
                    radius: 14
                    visible: root.bgImage.length > 0
                    color: resetBtnArea.containsMouse ? "#3DFFFFFF" : "#1AFFFFFF"
                    border.width: 1
                    border.color: "#4DFFFFFF"
                    Text {
                        anchors.centerIn: parent
                        text: "默认"
                        color: "#E6FFFFFF"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: resetBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.bgImage = ""
                    }
                }

                Rectangle {
                    width: 60
                    height: 28
                    radius: 14
                    color: expandBtnArea.containsMouse ? "#3DFFFFFF" : "#1AFFFFFF"
                    border.width: 1
                    border.color: "#4DFFFFFF"
                    Text {
                        anchors.centerIn: parent
                        text: root.expanded ? "收起" : "放大"
                        color: "#E6FFFFFF"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: expandBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.expanded = !root.expanded
                    }
                }
            }
        }

        // ---------- 歌词列表 ----------
        Flickable {
            id: lyricFlick
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footer.top
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            clip: true
            contentWidth: width
            contentHeight: lyricColumn.height
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: lyricColumn
                width: lyricFlick.width
                spacing: root.expanded ? 20 : 12
                topPadding: lyricFlick.height / 2
                bottomPadding: lyricFlick.height / 2

                Repeater {
                    model: lyricModel

                    delegate: Item {
                        id: lineItem
                        readonly property bool isActive: index === root.activeIndex

                        width: lyricColumn.width
                        height: lineLabel.height + (root.expanded ? 16 : 10)

                        // 当前句的柔和光带
                        Rectangle {
                            anchors.centerIn: lineLabel
                            width: lineLabel.width + 44
                            height: lineLabel.height + 18
                            radius: height / 2
                            color: root.highlightColor
                            opacity: lineItem.isActive ? 0.14 : 0
                            visible: opacity > 0
                            z: -1
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }

                        Text {
                            id: lineLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - (root.expanded ? 140 : 60)
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            text: model.text
                            color: lineItem.isActive ? root.highlightColor : "#BFFFFFFF"
                            font.pixelSize: lineItem.isActive
                                            ? (root.expanded ? 30 : 19)
                                            : (root.expanded ? 21 : 15)
                            font.bold: lineItem.isActive
                            opacity: root.activeIndex < 0
                                     ? 0.85
                                     : (lineItem.isActive
                                        ? 1.0
                                        : Math.max(0.30, 0.78 - Math.abs(index - root.activeIndex) * 0.13))
                            Behavior on color { ColorAnimation { duration: 260 } }
                            Behavior on opacity { NumberAnimation { duration: 420 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.expanded = !root.expanded
                        }
                    }
                }
            }

            NumberAnimation {
                id: followAnim
                target: lyricFlick
                property: "contentY"
                duration: 420
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: placeholder
            anchors.centerIn: parent
            width: parent.width - 80
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            visible: lyricModel.count === 0
            color: "#99FFFFFF"
            font.pixelSize: 15
            text: {
                if (root.lrcSource.length === 0)
                    return "这首歌曲暂时没有歌词"
                if (!lyricModel.loaded)
                    return lyricModel.errorText.length > 0
                            ? "歌词加载失败\n" + lyricModel.errorText
                            : "这首歌暂时没有歌词"
                return "暂无歌词"
            }
        }

        // ---------- 底部 ----------
        Item {
            id: footer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 34

            // Text {
            //     anchors.left: parent.left
            //     anchors.leftMargin: 18
            //     anchors.verticalCenter: parent.verticalCenter
            //     text: root.expanded ? "点击歌词 还原" : "点击歌词 放大"
            //     color: "#66FFFFFF"
            //     font.pixelSize: 11
            // }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                text: formatTime(root.position) + " / " + formatTime(root.duration)
                color: "#66FFFFFF"
                font.pixelSize: 11
            }
        }
    }

    // ======================= 更换背景 =======================
    FileDialog {
        id: bgDialog
        title: "选择歌词栏背景图片"
        fileMode: FileDialog.OpenFile
        nameFilters: [
            "图片 (*.png *.jpg *.jpeg *.bmp *.webp *.gif)",
            "所有文件 (*)"
        ]
        onAccepted: root.bgImage = selectedFile
    }
}