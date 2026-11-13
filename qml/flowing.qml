import QtQuick
import QtQuick.Particles

Rectangle {
    id: root
    property alias source_2: img_2
    property alias source_1: img_1
    width: 1500
    height: 900
    z: -1
    color: "#000000"
    visible: true
    readonly property int cycleDuration: 20000
    readonly property int blackHoldDuration: 2000
    readonly property real cx: width / 2
    readonly property real cy: height / 2

    property real flowSpin: 230
    property real flowPull: 300
    property real emitScale: 1.0
    property real coreR: 96
    property real stageAngle: 0
    property real stageScale: 1.0
    property real wave
    property bool spitting: false
    property real spitSpeed: 0
    property string phase: "run"

    NumberAnimation on wave {
        from: 0
        to: 6.283185307
        duration: 3000
        loops: Animation.Infinite
    }

    function applyVortex(particles, dt) {
        var ccx = root.cx
        var ccy = root.cy
        var spin = root.flowSpin
        var pull = root.flowPull
        var rm = 760
        var spitting = root.spitting
        var spit = root.spitSpeed
        var waveValue = root.wave
        var wobA = Math.sin(waveValue)
        var wobB = Math.sin(waveValue * 0.7)
        var spinK = spin * (1 + 0.10 * wobA)
        var pullK = pull * (1 + 0.05 * wobB)
        for (var i = 0; i < particles.length; ++i) {
            var p = particles[i]
            var dx = p.x - ccx
            var dy = p.y - ccy
            var r = Math.sqrt(dx * dx + dy * dy)
            if (r < 0.5) {
                p.vx = spitting ? spit : 0
                p.vy = 0
                continue
            }
            var ux = dx / r
            var uy = dy / r
            if (spitting) {
                var q = p.x * 0.017 + p.y * 0.011
                var n = q - Math.floor(q)
                var s = spit * (0.25 + 1.00 * n)
                var t = spit * 0.55 * (0.30 + 0.70 * n)
                p.vx = ux * s - uy * t
                p.vy = uy * s + ux * t
                continue
            }
            var rn = r > rm ? 1 : r / rm
            // 方位/象限上的不均匀调制（只用乘加，不用三角函数和取整，避免逐粒子开销）
            var asymT = 1 + 0.26 * (uy * 0.8 + ux * 0.2) + 0.10 * (ux * uy * 4)
            var asymR = 1 + 0.20 * (ux * 0.6 - uy * 0.5) + 0.08 * (uy * uy - ux * ux) * 2
            var vt = spinK * (1.3 - 0.6 * rn) * asymT
            var vr = pullK * (0.3 + 0.7 * rn) * asymR
            p.vx = -uy * vt - ux * vr
            p.vy = ux * vt - uy * vr
        }
    }

    SequentialAnimation {
        id: eventAnim
        running: true
        loops: Animation.Infinite

        PauseAnimation { duration: 8240 }

        ScriptAction { script: root.phase = "ramp" }
        ParallelAnimation {
            NumberAnimation { target: root; property: "flowSpin"; from: 230; to: 560; duration: 3000; easing.type: Easing.InQuad }
            NumberAnimation { target: root; property: "flowPull"; from: 300; to: 520; duration: 3000; easing.type: Easing.InQuad }
            NumberAnimation { target: root; property: "stageAngle"; from: 0; to: 8; duration: 3000; easing.type: Easing.InOutSine }
            NumberAnimation { target: root; property: "stageScale"; from: 1.0; to: 1.025; duration: 3000; easing.type: Easing.InOutSine }
        }

        ScriptAction { script: root.phase = "suck" }
        ParallelAnimation {
            NumberAnimation { target: root; property: "flowSpin"; from: 560; to: 820; duration: 1400; easing.type: Easing.InQuad }
            NumberAnimation { target: root; property: "flowPull"; from: 520; to: 1150; duration: 1400; easing.type: Easing.InQuad }
            NumberAnimation { target: root; property: "emitScale"; from: 1.0; to: 0.0; duration: 900; easing.type: Easing.OutQuad }
            NumberAnimation { target: root; property: "coreR"; from: 96; to: 900; duration: 1400; easing.type: Easing.InQuad }
            NumberAnimation { target: root; property: "stageAngle"; from: 8; to: 30; duration: 1400; easing.type: Easing.InQuad }
            NumberAnimation { target: root; property: "stageScale"; from: 1.025; to: 1.07; duration: 1400; easing.type: Easing.InQuad }
        }

        ScriptAction { script: { root.phase = "black"; killAll.enabled = true } }
        PauseAnimation { duration: 2000 }


        ScriptAction {
            script: {
                root.phase = "spit"
                killAll.enabled = false
                root.coreR = 1
                root.stageAngle = 0
                root.stageScale = 1.0
                root.emitScale = 0.0
                root.spitting = true
                root.spitSpeed = 1100
                root.flowSpin = 80
                root.flowPull = 90
                mySystem.resume()
                mySystem_2.resume()
                spitEmitter.burst(200)
                spitEmitter2.burst(200)
            }
        }
        SequentialAnimation {
            PauseAnimation { duration: 180 }
            ScriptAction { script: { spitEmitter.burst(160); spitEmitter2.burst(160) } }
            PauseAnimation { duration: 180 }
            ScriptAction { script: { spitEmitter.burst(160); spitEmitter2.burst(160) } }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "spitSpeed"; from: 1100; to: 0; duration: 1400; easing.type: Easing.OutQuad }
        }
        ScriptAction { script: root.spitting = false }

        ScriptAction { script: { root.phase = "recover"; mySystem.resume(); mySystem_2.resume() } }
        ParallelAnimation {
            NumberAnimation { target: root; property: "emitScale"; from: 0.0; to: 1.0; duration: 3600; easing.type: Easing.InOutSine }
            NumberAnimation { target: root; property: "flowSpin"; from: 80; to: 230; duration: 3600; easing.type: Easing.InOutSine }
            NumberAnimation { target: root; property: "flowPull"; from: 90; to: 300; duration: 3600; easing.type: Easing.InOutSine }
            NumberAnimation { target: root; property: "coreR"; from: 1; to: 96; duration: 3600; easing.type: Easing.InOutSine }
        }
    }

    Item {
        id: stage
        anchors.fill: parent
        rotation: root.stageAngle
        scale: root.stageScale

        ParticleSystem { id: mySystem }
        ParticleSystem { id: mySystem_2 }

        Age {
            x: root.cx - root.coreR
            y: root.cy - root.coreR
            width: root.coreR * 2
            height: root.coreR * 2
            system: mySystem
        }
        Age {
            x: root.cx - root.coreR
            y: root.cy - root.coreR
            width: root.coreR * 2
            height: root.coreR * 2
            system: mySystem_2
        }
        Age {
            id: killAll
            x: 0
            y: 0
            width: root.width
            height: root.height
            system: mySystem
            enabled: false
        }
        Age {
            x: 0
            y: 0
            width: root.width
            height: root.height
            system: mySystem_2
            enabled: false
        }


        Repeater {
            model: 14
            Emitter {
                required property int index
                readonly property real th: Math.random() * 2 * Math.PI
                readonly property real radX: 620 + Math.random() * 140
                readonly property real radY: radX * 0.63
                readonly property real rateJ: 0.40 + Math.random() * 1.00
                readonly property real emitThresh: Math.random() * 0.85
                system: mySystem
                x: root.cx + Math.cos(th) * radX - width / 2
                y: root.cy + Math.sin(th) * radY - height / 2
                width: 26
                height: 26
                shape: EllipseShape { }
                enabled: root.emitScale > emitThresh
                emitRate: 26 * rateJ
                lifeSpan: 9000
                lifeSpanVariation: 1400
                size: 15
                sizeVariation: 2
                endSize: 5
                velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 0 }
            }
        }        Repeater {
            model: 6
            Emitter {
                required property int index

                readonly property real th: Math.random() * 2 * Math.PI
                readonly property real radX: 280 + Math.random() * 150
                readonly property real radY: radX * 0.63
                readonly property real rateJ: 0.40 + Math.random() * 1.00
                readonly property real emitThresh: Math.random() * 0.85
                system: mySystem
                x: root.cx + Math.cos(th) * radX - width / 2
                y: root.cy + Math.sin(th) * radY - height / 2
                width: 22
                height: 22
                shape: EllipseShape { }
                enabled: root.emitScale > emitThresh
                emitRate: 14 * rateJ
                lifeSpan: 5000
                lifeSpanVariation: 1400
                size: 12
                sizeVariation: 2
                endSize: 4
                velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 0 }
            }
        }        Repeater {
            model: 4
            Emitter {
                required property int index

                readonly property real th: Math.random() * 2 * Math.PI
                readonly property real radX: 120 + Math.random() * 110
                readonly property real radY: radX * 0.63
                readonly property real rateJ: 0.40 + Math.random() * 1.00
                readonly property real emitThresh: Math.random() * 0.85
                system: mySystem
                x: root.cx + Math.cos(th) * radX - width / 2
                y: root.cy + Math.sin(th) * radY - height / 2
                width: 18
                height: 18
                shape: EllipseShape { }
                enabled: root.emitScale > emitThresh
                emitRate: 11 * rateJ
                lifeSpan: 3500
                lifeSpanVariation: 1400
                size: 10
                sizeVariation: 2
                endSize: 3
                velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 0 }
            }
        }        Repeater {
            model: 14
            Emitter {
                required property int index

                readonly property real th: Math.random() * 2 * Math.PI
                readonly property real radX: 600 + Math.random() * 140
                readonly property real radY: radX * 0.63
                readonly property real rateJ: 0.40 + Math.random() * 1.00
                readonly property real emitThresh: Math.random() * 0.85
                system: mySystem_2
                x: root.cx + Math.cos(th) * radX - width / 2
                y: root.cy + Math.sin(th) * radY - height / 2
                width: 26
                height: 26
                shape: EllipseShape { }
                enabled: root.emitScale > emitThresh
                emitRate: 26 * rateJ
                lifeSpan: 9000
                lifeSpanVariation: 1400
                size: 15
                sizeVariation: 2
                endSize: 5
                velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 0 }
            }
        }        Repeater {
            model: 6
            Emitter {
                required property int index

                readonly property real th: Math.random() * 2 * Math.PI
                readonly property real radX: 270 + Math.random() * 150
                readonly property real radY: radX * 0.63
                readonly property real rateJ: 0.40 + Math.random() * 1.00
                readonly property real emitThresh: Math.random() * 0.85
                system: mySystem_2
                x: root.cx + Math.cos(th) * radX - width / 2
                y: root.cy + Math.sin(th) * radY - height / 2
                width: 22
                height: 22
                shape: EllipseShape { }
                enabled: root.emitScale > emitThresh
                emitRate: 14 * rateJ
                lifeSpan: 5000
                lifeSpanVariation: 1400
                size: 12
                sizeVariation: 2
                endSize: 4
                velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 0 }
            }
        }        Repeater {
            model: 4
            Emitter {
                required property int index
                readonly property real th: Math.random() * 2 * Math.PI
                readonly property real radX: 110 + Math.random() * 110
                readonly property real radY: radX * 0.63
                readonly property real rateJ: 0.40 + Math.random() * 1.00
                readonly property real emitThresh: Math.random() * 0.85
                system: mySystem_2
                x: root.cx + Math.cos(th) * radX - width / 2
                y: root.cy + Math.sin(th) * radY - height / 2
                width: 18
                height: 18
                shape: EllipseShape { }
                enabled: root.emitScale > emitThresh
                emitRate: 11 * rateJ
                lifeSpan: 3500
                lifeSpanVariation: 1400
                size: 10
                sizeVariation: 2
                endSize: 3
                velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 0 }
            }
        }
        Emitter {
            id: spitEmitter
            system: mySystem
            x: root.cx - width / 2
            y: root.cy - height / 2
            width: 36
            height: 36
            shape: EllipseShape { }
            emitRate: 0
            lifeSpan: 6000
            lifeSpanVariation: 900
            size: 16
            endSize: 2
            velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 0 }
        }
        Emitter {
            id: spitEmitter2
            system: mySystem_2
            x: root.cx - width / 2
            y: root.cy - height / 2
            width: 36
            height: 36
            shape: EllipseShape { }
            emitRate: 0
            lifeSpan: 3000
            lifeSpanVariation: 900
            size: 16
            endSize: 2
            velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 0 }
        }

        Affector {
            x: 0
            y: 0
            width: root.width
            height: root.height
            system: mySystem
            onAffectParticles: function(particles, dt) { root.applyVortex(particles, dt) }
        }
        Affector {
            x: 0
            y: 0
            width: root.width
            height: root.height
            system: mySystem_2
            onAffectParticles: function(particles, dt) { root.applyVortex(particles, dt) }
        }

        Turbulence {
            x: 0
            y: 0
            width: root.width
            height: root.height
            system: mySystem
            strength: 30
            enabled: true
        }
        Turbulence {
            x: 0
            y: 0
            width: root.width
            height: root.height
            system: mySystem_2
            strength: 30
            enabled: true
        }

        ImageParticle {
            id: img_1
            system: mySystem
            source: "qrc:///particleresources/glowdot.png"
            color: "#0000FF"
            entryEffect: ImageParticle.None
            SequentialAnimation on color {
                loops: Animation.Infinite
                ColorAnimation { duration: 2000; to: "#66FFFF"; easing.type: Easing.InOutSine }
                ColorAnimation { duration: 2000; to: "#CCFFCC" }
                ColorAnimation { duration: 2000; to: "#FFCCCC" }
                ColorAnimation { duration: 2000; to: "#CCFFCC"; easing.type: Easing.InOutSine }
                ColorAnimation { duration: 2000; to: "#66FFFF" }
                ColorAnimation { duration: 2000; to: "#0000FF" }
            }
        }
        ImageParticle {
            id: img_2
            system: mySystem_2
            source: "qrc:///particleresources/glowdot.png"
            color: "#CC0000"
            entryEffect: ImageParticle.None
            SequentialAnimation on color {
                loops: Animation.Infinite
                ColorAnimation { duration: 2000; to: "#FF9999" }
                ColorAnimation { duration: 2000; to: "#FFCCCC" }
                ColorAnimation { duration: 2000; to: "#FF00FF" }
                ColorAnimation { duration: 2000; to: "#FFCCCC" }
                ColorAnimation { duration: 2000; to: "#FF9999" }
                ColorAnimation { duration: 2000; to: "#CC0000" }
            }
        }
    }
}