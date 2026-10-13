import QtQuick 2.8

// Tile frame drawn as one outline: a rounded tab on the top-left that curves back
// ("return" corner) into the frame body, with a rounded window cut out for the picture.
// All sizes are in design units (1920x1080) and multiplied by u.
Item {
    id: frame

    property real u: 1
    property real tabW: 300
    property real tabH: 40
    property real px: 4          // size of one "pixel" in the corner steps
    property real tabR: 14       // tab top corner radius
    property real returnR: 10    // concave corner where the tab meets the frame top
    property real frameR: 20     // frame body corner radius
    property real inset: 8       // frame thickness around the picture window
    property real windowR: 12    // picture window corner radius
    property color fillColor: "#ff7a00"
    property color lineColor: "#ffffff"
    property real lineWidth: 0   // 0 = no outline

    onUChanged: canvas.requestPaint()
    onTabWChanged: canvas.requestPaint()
    onTabHChanged: canvas.requestPaint()
    onInsetChanged: canvas.requestPaint()
    onFillColorChanged: canvas.requestPaint()
    onLineColorChanged: canvas.requestPaint()
    onLineWidthChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        // Corners are built from square "pixels" (px design units each) instead of curves.
        // A corner is [cornerX, cornerY, inDirX, inDirY, outDirX, outDirY, steps].
        function poly(ctx, corners, p) {
            for (var i = 0; i < corners.length; i++) {
                var c = corners[i], k = c[6];
                var x = c[0] - c[2] * k * p, y = c[1] - c[3] * k * p;
                if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                for (var j = 0; j < k; j++) {
                    x += c[2] * p; y += c[3] * p; ctx.lineTo(x, y);
                    x += c[4] * p; y += c[5] * p; ctx.lineTo(x, y);
                }
            }
            ctx.closePath();
        }

        function pxSize() { return Math.max(1, Math.round(frame.px * frame.u)); }
        function steps(r) { return Math.max(1, Math.round(r / frame.px)); }

        // Outer outline, clockwise. `g` pulls the line in by half a stroke so a 1px
        // outline lands on whole pixels and stays crisp.
        function outline(ctx, g) {
            var p = pxSize();
            var w = width - g, h = height - g, l = g, t0 = g;
            var tw = Math.round(Math.min(frame.tabW * frame.u, w - 2 * frame.frameR * frame.u));
            var th = Math.round(frame.tabH * frame.u) + g;
            var kt = steps(frame.tabR), kr = steps(frame.returnR), kf = steps(frame.frameR);
            poly(ctx, [
                [l,      t0, 0, -1,  1, 0, kt],   // tab, top-left
                [l + tw, t0, 1,  0,  0, 1, kt],   // tab, top-right
                [l + tw, th, 0,  1,  1, 0, kr],   // return corner (concave)
                [w,      th, 1,  0,  0, 1, kf],   // frame, top-right
                [w,      h,  0,  1, -1, 0, kf],   // frame, bottom-right
                [l,      h, -1,  0,  0, -1, kf]   // frame, bottom-left
            ], p);
        }

        // Picture window, drawn the other way round so it punches a hole in the fill.
        function windowHole(ctx) {
            var p = pxSize(), s = frame.u;
            var x0 = Math.round(frame.inset * s), y0 = Math.round((frame.tabH + frame.inset) * s);
            var x1 = width - x0, y1 = height - x0;
            var k = steps(frame.windowR);
            poly(ctx, [
                [x0, y0, -1, 0,  0, 1, k],
                [x0, y1,  0, 1,  1, 0, k],
                [x1, y1,  1, 0,  0, -1, k],
                [x1, y0,  0, -1, -1, 0, k]
            ], p);
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            ctx.fillStyle = frame.fillColor;
            ctx.beginPath();
            outline(ctx, 0);
            windowHole(ctx);
            ctx.fill();

            if (frame.lineWidth > 0) {
                var lw = Math.max(1, Math.round(frame.lineWidth * frame.u));
                ctx.lineWidth = lw;
                ctx.lineJoin = "miter";
                ctx.strokeStyle = frame.lineColor;
                ctx.beginPath();
                outline(ctx, lw / 2);
                ctx.stroke();
            }
        }
    }
}
