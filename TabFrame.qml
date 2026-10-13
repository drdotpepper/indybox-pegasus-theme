import QtQuick 2.8

// Tile frame drawn as one outline: a rounded tab on the top-left that curves back
// ("return" corner) into the frame body, with a rounded window cut out for the picture.
// All sizes are in design units (1920x1080) and multiplied by u.
Item {
    id: frame

    property real u: 1
    property real tabW: 300
    property real tabH: 40
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

        // Outer outline, clockwise from the left edge of the tab. `g` pulls the line in
        // by half a stroke so a 1px outline lands on whole pixels and stays crisp.
        function outline(ctx, g) {
            var s = frame.u;
            var w = width - g, h = height - g;
            var l = g, t0 = g;
            var tw = Math.min(frame.tabW * s, w - 2 * frame.frameR * s);
            var th = frame.tabH * s + g;
            var tr = frame.tabR * s, rr = frame.returnR * s, R = frame.frameR * s;
            var PI = Math.PI;
            ctx.moveTo(l, t0 + tr);
            ctx.arc(l + tr, t0 + tr, tr, PI, 1.5 * PI, false);            // tab, top-left
            ctx.lineTo(l + tw - tr, t0);
            ctx.arc(l + tw - tr, t0 + tr, tr, 1.5 * PI, 0, false);        // tab, top-right
            ctx.lineTo(l + tw, th - rr);
            ctx.arc(l + tw + rr, th - rr, rr, PI, 0.5 * PI, true);        // return corner
            ctx.lineTo(w - R, th);
            ctx.arc(w - R, th + R, R, 1.5 * PI, 0, false);                // frame, top-right
            ctx.lineTo(w, h - R);
            ctx.arc(w - R, h - R, R, 0, 0.5 * PI, false);                 // frame, bottom-right
            ctx.lineTo(l + R, h);
            ctx.arc(l + R, h - R, R, 0.5 * PI, PI, false);                // frame, bottom-left
            ctx.lineTo(l, t0 + tr);
            ctx.closePath();
        }

        // Picture window, drawn the other way round so it punches a hole in the fill.
        function windowHole(ctx) {
            var s = frame.u;
            var x0 = frame.inset * s, y0 = frame.tabH * s + frame.inset * s;
            var x1 = width - frame.inset * s, y1 = height - frame.inset * s;
            var r = frame.windowR * s, PI = Math.PI;
            ctx.moveTo(x0 + r, y0);
            ctx.arc(x0 + r, y0 + r, r, 1.5 * PI, PI, true);
            ctx.lineTo(x0, y1 - r);
            ctx.arc(x0 + r, y1 - r, r, PI, 0.5 * PI, true);
            ctx.lineTo(x1 - r, y1);
            ctx.arc(x1 - r, y1 - r, r, 0.5 * PI, 0, true);
            ctx.lineTo(x1, y0 + r);
            ctx.arc(x1 - r, y0 + r, r, 0, 1.5 * PI, true);
            ctx.closePath();
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
                ctx.strokeStyle = frame.lineColor;
                ctx.beginPath();
                outline(ctx, lw / 2);
                ctx.stroke();
            }
        }
    }
}
