import QtQuick
import QtQuick.Shapes
Rectangle{
    color:"transparent"
    property var colors:['blue','red','green']
    width: 1000
    height: 500
    property bool line: false
    property bool black: false
    property color color_1: Qt.hsla(Math.random(),0.5,0.4,0.4)
    property color color_2: Qt.hsla(Math.random(),0.7,0.8,0.4)

    Canvas{
        property real lastx:canvas.width/2
        property real lasty:canvas.height/2
        property real hue: 0
        // property bool line: false
        // property bool black: false
        id:canvas
        anchors.fill: parent
        onWidthChanged: canvas.width = width
            onHeightChanged: canvas.height = height
        onPaint:{
            var ctx=canvas.getContext("2d")
            var grad=ctx.createLinearGradient(0,0,canvas.width,canvas.height)
            grad.addColorStop(0,color_1)
            grad.addColorStop(0,color_2)
            ctx.fillStyle=grad
            ctx.fillRect(0,0,canvas.width,canvas.height)
            if(black){
                ctx.fillStyle = Qt.rgba(0,0,0,0.08)
                ctx.fillRect(0,0,canvas.width,canvas.height)
                black = false
            }
            if(line){
                line=false
                ctx.save()
                ctx.translate(canvas.width*Math.random()/2,canvas.width*Math.random()/2)
                ctx.scale(0.9,0.9)
                ctx.translate(-canvas.width*Math.random()/2,-canvas.width*Math.random()/2)
                ctx.beginPath()
                ctx.lineWidth=ctx.lineWidth+Math.random()*10
                if(ctx.lineWidth>=10){
                    ctx.lineWidth=5}
                ctx.moveTo(lastx,lasty)
                lastx=canvas.width*Math.random()
                lasty=canvas.height*Math.random()
                //ctx.arc(0,0,Math.random()*10,0,2*Math.PI)
                ctx.bezierCurveTo(canvas.width*Math.random(),canvas.height*Math.random(),canvas.width*Math.random(),canvas.height*Math.random(),lastx,lasty)
                hue=hue+0.1*Math.random()
                if(hue>=1)
                    hue=hue%1
                ctx.strokeStyle=Qt.hsla(hue,0.5,0.5,1.0)
                ctx.stroke()
                ctx.restore()
                ctx.save()
                ctx.beginPath()
                // ctx.lineWidth=ctx.lineWidth+Math.random()*10
                // if(ctx.lineWidth>=10){
                //     ctx.lineWidth=5}
                ctx.moveTo(lastx,lasty)
                ctx.arc(lastx, lasty,Math.random()*100,0,2*Math.PI)
                ctx.strokeStyle="red"
                ctx.stroke()
                ctx.restore()
            }
        }
    }
    Timer{
        id:grad_t
        interval:100
        running: true
        repeat: true
        onTriggered: {
            color_1=Qt.hsla(Math.random(),Math.random(),Math.random(),Math.random())
            color_2=Qt.hsla(Math.random(),Math.random(),Math.random(),Math.random())
        }
    }

    Timer{
        id:line_t
        interval:500
        running:true
        repeat:true
        onTriggered:{
            line=true
            canvas.requestPaint()
        }
    }
    Timer{
        id:black_t
        interval:400
        running:true
        repeat:true
        onTriggered:{
            black=true
            canvas.requestPaint()
        }
    }
    Behavior on color_1{
        ColorAnimation {
            duration: 10
        }
    }
    Behavior on color_2{
        ColorAnimation {
            duration: 10
        }
    }
}
