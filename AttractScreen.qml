import QtQuick 2.8
import "config.js" as Config
import "style.js" as S

// Idle screen: a bouncing "indybox@VENUE" tag, cycling "now showing" cards,
// the developer credits/QR zone, and a blinking prompt.
// Any input wakes it (handled in theme.qml).
Item {
    id: attract

    property var fonts
    property real u: 1
    property bool active: false

    readonly property int count: api.allGames.count
    property int showIndex: 0
    readonly property var showGame: count > 0 ? api.allGames.get(showIndex % count) : null

    property int colorIndex: 0
    readonly property color tone: S.bounceColors[colorIndex % S.bounceColors.length]

    // integer logo scale keeps the pixel art crisp (1x at 1080p, 2x at 4K)
    readonly property int k: Math.max(1, Math.floor(width / 1600))

    Rectangle { anchors.fill: parent; color: S.bg }

    // dimmed screenshot of whatever is "now showing"
    Image {
        anchors.fill: parent
        source: S.shot(attract.showGame)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: 0.2
    }

    // ---- bouncing marquee ----
    Item {
        id: marquee
        property real px: 300
        property real py: 260
        property real vx: 170 * attract.u
        property real vy: 125 * attract.u
        x: Math.round(px)
        y: Math.round(py)
        width: 424 * attract.k
        height: (156 + 22 + 80) * attract.k

        Image {
            source: "assets/indybox-logo-px.png"
            width: 424 * attract.k
            height: 156 * attract.k
            smooth: false
            mipmap: false
        }
        Pill {
            y: (156 + 22) * attract.k
            width: 424 * attract.k
            height: 80 * attract.k
            u: attract.k
            family: attract.fonts.pixel
            fontSize: 52
            tone: attract.tone
            text: "@" + S.upper(Config.venueName)
        }
    }

    Timer {
        id: tick
        interval: 16
        repeat: true
        running: attract.active
        property real last: 0
        onRunningChanged: if (running) last = Date.now()
        onTriggered: {
            var now = Date.now();
            var dt = Math.min(0.05, (now - last) / 1000);
            last = now;
            var m = marquee;
            m.px += m.vx * dt;
            m.py += m.vy * dt;
            var maxX = attract.width - m.width;
            // stay clear of the "push any button" strip along the bottom
            var maxY = attract.height - m.height - 190 * attract.u;
            var hit = false;
            if (m.px <= 0)         { m.px = 0;    m.vx =  Math.abs(m.vx); hit = true; }
            else if (m.px >= maxX) { m.px = maxX; m.vx = -Math.abs(m.vx); hit = true; }
            if (m.py <= 0)         { m.py = 0;    m.vy =  Math.abs(m.vy); hit = true; }
            else if (m.py >= maxY) { m.py = maxY; m.vy = -Math.abs(m.vy); hit = true; }
            if (hit) attract.colorIndex = (attract.colorIndex + 1) % S.bounceColors.length;
        }
    }

    // ---- now showing (top left) ----
    Column {
        visible: attract.showGame !== null
        x: 96 * attract.u
        y: 80 * attract.u
        width: 900 * attract.u
        spacing: 6 * attract.u

        Text {
            text: "NOW SHOWING"
            color: S.accent
            font.family: attract.fonts.pixel
            font.pixelSize: 36 * attract.u
            font.letterSpacing: 1.5 * attract.u
        }
        Text {
            width: parent.width
            text: S.upper(attract.showGame ? attract.showGame.title : "")
            color: S.fg
            font.family: attract.fonts.display
            font.italic: true
            font.pixelSize: 84 * attract.u
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: attract.showGame && attract.showGame.developer ? ("by " + S.cleanDev(attract.showGame.developer)) : ""
            color: S.muted
            font.family: attract.fonts.text
            font.pixelSize: 30 * attract.u
            elide: Text.ElideRight
        }
    }

    Timer {
        interval: Math.max(2, Config.cycleSeconds) * 1000
        repeat: true
        running: attract.active && attract.count > 1
        onTriggered: attract.showIndex = (attract.showIndex + 1) % attract.count
    }

    // ---- credits / QR zone (bottom right) ----
    CreditsPanel {
        anchors.right: parent.right
        anchors.rightMargin: 96 * attract.u
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60 * attract.u
        fonts: attract.fonts
        u: attract.u
        game: attract.showGame
    }

    // ---- blinking prompt ----
    Text {
        id: prompt
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 70 * attract.u
        text: "FREE PLAY  -  PUSH ANY BUTTON"
        color: S.fg
        font.family: attract.fonts.pixel
        font.pixelSize: 56 * attract.u
        font.letterSpacing: 2 * attract.u

        SequentialAnimation on opacity {
            running: attract.active
            loops: Animation.Infinite
            NumberAnimation { to: 0.15; duration: 650 }
            NumberAnimation { to: 1.0;  duration: 650 }
        }
    }
}
