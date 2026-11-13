import QtQuick 2.15
import QtQuick.Window

Rectangle {
    property bool running: false
    id: root
    signal bootFinished()
    width: 1500
    height: 900
    anchors.fill: parent
    color: "#04050a"

    property var glyphData: [
        [
            [["M", 30, 50], ["L", 30, 250]],
            [["M", 30, 50], ["Q", 116, 42, 156, 90], ["Q", 186, 132, 154, 162], ["Q", 120, 180, 30, 174]],
            [["M", 138, 166], ["Q", 170, 208, 204, 250]]
        ],
        [
            [["E", 278, 178, 62, 72, -Math.PI / 2, -Math.PI * 2]]
        ],
        [
            [["M", 386, 106], ["L", 418, 244], ["L", 460, 128], ["L", 502, 244], ["L", 534, 106]]
        ],
        [
            [["M", 574, 250], ["L", 574, 44]]
        ],
        [
            [["M", 614, 250], ["L", 614, 106]],
            [["D", 614, 86, 6]]
        ],
        [
            [["M", 654, 250], ["L", 654, 106], ["Q", 654, 96, 690, 96], ["Q", 760, 96, 760, 148], ["L", 760, 250]]
        ]
    ]

    property var strokes: []
    property real totalLen: 0
    property double appStartMs: 0
    property double cycleStartMs: 0
    property real hue: 0.55
    property real progress: 0
    property real wordAlpha: 1
    property real glowGain: 1
    property real penX: 0
    property real penY: 0
    property bool penVisible: false

    // ===== 性能优化用状态 =====
    property int tick: 0              // 16ms 逻辑节拍计数
    property string phase: ""         // draw / hold / fade / gap
    property bool fadePainted: false  // 淡出阶段是否已画过完整字形

    // 字形绘制区域的边界（字形坐标系，已包含笔画辉光与笔尖光晕）
    readonly property real gx0: -30
    readonly property real gy0: -10
    readonly property real gx1: 810
    readonly property real gy1: 305

    readonly property real drawDur: 4800
    readonly property real holdDur: 2400
    readonly property real fadeDur: 800
    readonly property real gapDur: 240
    readonly property real cycleDur: drawDur + holdDur + fadeDur + gapDur

    readonly property real sc: Math.min(width / 960, height / 440) * 0.9
    readonly property real ox: (width - 730 * sc) / 2 - 30 * sc
    readonly property real oy: (height - 208 * sc) / 2 - 42 * sc

    Component.onCompleted: {
        buildStrokes()
        appStartMs = Date.now()
        cycleStartMs = appStartMs
        bgCanvas.requestPaint()
    }
    onWidthChanged: bgCanvas.requestPaint()
    onHeightChanged: bgCanvas.requestPaint()

    // 逻辑时序（16ms 一拍）；真正的 Canvas 重绘按阶段降频，避免整屏每帧重绘
    Timer {
        id: animTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: root.advance()
    }

    function advance() {
        var now = Date.now()
        var e = now - cycleStartMs
        if (e >= cycleDur) {
            cycleStartMs = now
            e = 0
            fadePainted = false
        }
        hue = (0.55 + (now - appStartMs) * 0.000045) % 1
        var holdStart = drawDur
        var fadeStart = drawDur + holdDur
        var gapStart = fadeStart + fadeDur
        tick++

        var newPhase = ""
        var needPaint = false

        if (e < holdStart) {
            newPhase = "draw"
            var u = e / drawDur
            progress = easeInOut(u)
            wordAlpha = 1
            glowGain = 1 + 0.12 * Math.sin(u * Math.PI * 5)
            penVisible = true
            // 绘制阶段 ~30fps（每 2 拍重绘一次）
            if ((tick & 1) === 0 || progress >= 0.999)
                needPaint = true
        } else if (e < fadeStart) {
            newPhase = "hold"
            var h = (e - holdStart) / holdDur
            progress = 1
            wordAlpha = 1
            glowGain = 1.5 + 1.15 * Math.exp(-h * 8) + 0.22 * Math.sin(h * Math.PI * 4 - Math.PI / 2)
            penVisible = false
            // 停留阶段 ~15fps（每 4 拍重绘一次）
            if ((tick & 3) === 0)
                needPaint = true
        } else if (e < gapStart) {
            newPhase = "fade"
            var f = (e - fadeStart) / fadeDur
            progress = 1
            wordAlpha = Math.pow(1 - f, 1.8)
            penVisible = false
            // 淡出阶段字形不再变化，冻结 Canvas，仅靠 opacity 淡出
            if (!fadePainted) {
                fadePainted = true
                needPaint = true
            }
        } else {
            newPhase = "gap"
            progress = 0
            wordAlpha = 1
            glowGain = 1
            penVisible = false
            root.bootFinished()
            return
        }

        // 阶段切换时补一帧，避免停留/淡出起始帧缺失
        if (newPhase !== phase) {
            phase = newPhase
            needPaint = true
        }
        if (needPaint)
            canvas.requestPaint()
    }

    function easeInOut(t) {
        return -(Math.cos(Math.PI * t) - 1) / 2
    }

    function buildStrokes() {
        var out = []
        var acc = 0
        for (var g = 0; g < glyphData.length; ++g) {
            var letter = glyphData[g]
            for (var s = 0; s < letter.length; ++s) {
                var st = sampleStroke(letter[s])
                if (st.dot) {
                    st.acc = acc
                    acc += 26
                    out.push(st)
                    continue
                }
                if (st.len < 0.5)
                    continue
                st.acc = acc
                acc += st.len
                out.push(st)
            }
        }
        strokes = out
        totalLen = acc
    }

    function sampleStroke(cmds) {
        if (cmds.length === 1 && cmds[0][0] === "D")
            return { dot: true, cx: cmds[0][1], cy: cmds[0][2], r: cmds[0][3], len: 26, fx: (cmds[0][1] - 30) / 730 }
        var pts = []
        var x = 0
        var y = 0
        for (var i = 0; i < cmds.length; ++i) {
            var c = cmds[i]
            if (c[0] === "M") {
                x = c[1]
                y = c[2]
                pts.push([x, y])
            } else if (c[0] === "L") {
                var lx = c[1]
                var ly = c[2]
                var ln = Math.max(2, Math.ceil(Math.hypot(lx - x, ly - y) / 2))
                for (var j = 1; j <= ln; ++j) {
                    var lu = j / ln
                    pts.push([x + (lx - x) * lu, y + (ly - y) * lu])
                }
                x = lx
                y = ly
            } else if (c[0] === "Q") {
                var qx = c[3]
                var qy = c[4]
                var qn = Math.max(8, Math.ceil((Math.hypot(c[1] - x, c[2] - y) + Math.hypot(qx - c[1], qy - c[2])) / 2))
                for (var k = 1; k <= qn; ++k) {
                    var qu = k / qn
                    var iu = 1 - qu
                    pts.push([iu * iu * x + 2 * iu * qu * c[1] + qu * qu * qx,
                              iu * iu * y + 2 * iu * qu * c[2] + qu * qu * qy])
                }
                x = qx
                y = qy
            } else if (c[0] === "E") {
                var ecx = c[1]
                var ecy = c[2]
                var erx = c[3]
                var ery = c[4]
                var ea0 = c[5]
                var esw = c[6]
                var en = Math.max(24, Math.ceil(Math.abs(esw) * Math.max(erx, ery) / 2))
                for (var m = 1; m <= en; ++m) {
                    var ea = ea0 + esw * (m / en)
                    pts.push([ecx + erx * Math.cos(ea), ecy + ery * Math.sin(ea)])
                }
                x = pts[pts.length - 1][0]
                y = pts[pts.length - 1][1]
            }
        }
        var cum = [0]
        var total = 0
        for (var p = 1; p < pts.length; ++p) {
            total += Math.hypot(pts[p][0] - pts[p - 1][0], pts[p][1] - pts[p - 1][1])
            cum.push(total)
        }
        var midX = (pts[0][0] + pts[pts.length - 1][0]) / 2
        return { dot: false, pts: pts, cum: cum, len: total, fx: Math.max(0, Math.min(1, (midX - 30) / 730)) }
    }

    function strokePath(ctx, st, amount) {
        var pts = st.pts
        var cum = st.cum
        var target = st.len * amount
        ctx.beginPath()
        ctx.moveTo(pts[0][0], pts[0][1])
        var i = 0
        while (i + 1 < pts.length && cum[i + 1] <= target) {
            ++i
            ctx.lineTo(pts[i][0], pts[i][1])
        }
        if (i + 1 < pts.length) {
            var seg = cum[i + 1] - cum[i]
            var u = seg > 0 ? (target - cum[i]) / seg : 0
            var ax = pts[i][0]
            var ay = pts[i][1]
            var bx = pts[i + 1][0]
            var by = pts[i + 1][1]
            penX = ax + (bx - ax) * u
            penY = ay + (by - ay) * u
            ctx.lineTo(penX, penY)
        } else {
            penX = pts[pts.length - 1][0]
            penY = pts[pts.length - 1][1]
        }
    }

    function paintDot(ctx, st, amount, hu, g) {
        var rad = st.r * (0.35 + 0.65 * amount)
        ctx.beginPath()
        ctx.moveTo(st.cx, st.cy)
        ctx.lineTo(st.cx + 0.01, st.cy)
        ctx.strokeStyle = Qt.hsla(hu, 0.95, 0.62, 0.16 * g)
        ctx.lineWidth = rad * 6
        ctx.stroke()
        ctx.strokeStyle = Qt.hsla(hu, 0.95, 0.68, 0.95)
        ctx.lineWidth = rad * 2
        ctx.stroke()
        ctx.strokeStyle = Qt.hsla(hu, 0.45, 0.96, 0.75)
        ctx.lineWidth = rad * 0.7
        ctx.stroke()
    }

    // 静态背景：只绘制一次（不再每 100ms 整屏重绘）
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            var cx = w / 2
            var cy = h / 2

            ctx.fillStyle = "#04050a"
            ctx.fillRect(0, 0, w, h)

            var amb = ctx.createRadialGradient(cx, cy, 0, cx, cy, Math.max(w, h) * 0.7)
            amb.addColorStop(0, Qt.hsla(root.hue, 0.55, 0.16, 1))
            amb.addColorStop(0.5, Qt.hsla((root.hue + 0.06) % 1, 0.55, 0.07, 1))
            amb.addColorStop(1, Qt.hsla((root.hue + 0.12) % 1, 0.5, 0.015, 1))
            ctx.fillStyle = amb
            ctx.fillRect(0, 0, w, h)

            var vig = ctx.createRadialGradient(cx, cy, Math.min(w, h) * 0.28, cx, cy, Math.max(w, h) * 0.8)
            vig.addColorStop(0, "rgba(0,0,0,0)")
            vig.addColorStop(1, "rgba(0,0,0,0.68)")
            ctx.fillStyle = vig
            ctx.fillRect(0, 0, w, h)

            // 字形背后的柔和辉光（原来每帧重绘，现在只画一次）
            var bx = root.ox + 400 * root.sc
            var by = root.oy + 150 * root.sc
            var br = 430 * root.sc
            var bloom = ctx.createRadialGradient(bx, by, 0, bx, by, br)
            bloom.addColorStop(0, Qt.hsla(root.hue, 0.8, 0.5, 0.085))
            bloom.addColorStop(0.45, Qt.hsla((root.hue + 0.1) % 1, 0.8, 0.45, 0.04))
            bloom.addColorStop(1, Qt.hsla(root.hue, 0.8, 0.4, 0))
            ctx.fillStyle = bloom
            ctx.fillRect(bx - br, by - br, br * 2, br * 2)
        }
    }

    // 动画字形：只覆盖字形区域（不是整屏），并按阶段降频重绘
    Canvas {
        id: canvas
        x: root.ox + root.gx0 * root.sc
        y: root.oy + root.gy0 * root.sc
        width: (root.gx1 - root.gx0) * root.sc
        height: (root.gy1 - root.gy0) * root.sc
        canvasSize: Qt.size(Math.round(width * 0.8), Math.round(height * 0.8))
        opacity: root.wordAlpha

        onPaint: {
            var cw = canvasSize.width
            var ch = canvasSize.height
            if (cw <= 0 || ch <= 0)
                return
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, cw, ch)

            if (root.strokes.length === 0)
                return

            var k = width > 0 ? cw / width : 1
            var done = root.progress * root.totalLen
            var g = root.glowGain
            var lw = 4.2

            ctx.save()
            ctx.scale(root.sc * k, root.sc * k)
            ctx.translate(-root.gx0, -root.gy0)
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var currentIsDot = false
            for (var s = 0; s < root.strokes.length; ++s) {
                var st = root.strokes[s]
                var amount = 0
                if (done >= st.acc + st.len)
                    amount = 1
                else if (done > st.acc)
                    amount = (done - st.acc) / st.len
                if (amount <= 0)
                    continue
                var hu = (root.hue + 0.3 * st.fx) % 1
                if (st.dot) {
                    paintDot(ctx, st, amount, hu, g)
                    currentIsDot = true
                    continue
                }
                currentIsDot = false
                strokePath(ctx, st, amount)
                ctx.strokeStyle = Qt.hsla(hu, 0.95, 0.62, 0.055 * g)
                ctx.lineWidth = lw * 7.5
                ctx.stroke()
                if (root.progress > 0.999) {
                    ctx.strokeStyle = Qt.hsla(hu, 0.95, 0.62, 0.12 * g)
                    ctx.lineWidth = lw * 3.2
                    ctx.stroke()
                }
                ctx.strokeStyle = Qt.hsla(hu, 0.95, 0.66, 0.95)
                ctx.lineWidth = lw
                ctx.stroke()
                ctx.strokeStyle = Qt.hsla(hu, 0.5, 0.96, 0.6)
                ctx.lineWidth = lw * 0.36
                ctx.stroke()
            }

            if (root.penVisible && !currentIsDot && root.progress > 0.001 && root.progress < 0.999) {
                var pHue = (root.hue + 0.1) % 1
                var halo = ctx.createRadialGradient(root.penX, root.penY, 0, root.penX, root.penY, 32)
                halo.addColorStop(0, "rgba(255,255,255,0.95)")
                halo.addColorStop(0.16, Qt.hsla(pHue, 1, 0.8, 0.8))
                halo.addColorStop(0.5, Qt.hsla(pHue, 1, 0.6, 0.24))
                halo.addColorStop(1, Qt.hsla(pHue, 1, 0.5, 0))
                ctx.fillStyle = halo
                ctx.beginPath()
                ctx.arc(root.penX, root.penY, 32, 0, Math.PI * 2)
                ctx.fill()
            }

            ctx.restore()
        }
    }
}