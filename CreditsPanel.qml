import QtQuick 2.8
import "style.js" as S

// The reserved developer credits + QR zone.
// Per game, set these in metadata.pegasus.txt (both optional):
//   x-qr:  C:/indybox/qr/verminian-trap.png   (absolute path, file:// or https:// URL)
//   x-url: itch.io/locomalito                 (short text shown under the QR / name)
// wide: true lays it out as a row (text left, QR right) for the grid sidebar.
Rectangle {
    id: panel

    property var fonts
    property real u: 1
    property var game: null
    property bool wide: false

    readonly property string qr: S.fileUrl(S.extra(game, "qr"))
    readonly property string url: S.extra(game, "url")
    readonly property string dev: S.upper(S.cleanDev(game ? game.developer : ""))
    readonly property bool hasDev: dev !== ""

    visible: hasDev || qr !== ""
    width: (wide ? 472 : 240) * u
    height: (wide ? Math.max(wideText.height, 104 * u) : col.height) + 44 * u
    radius: 15 * u
    color: Qt.rgba(0, 0, 0, 0.8)
    border.width: Math.max(1, Math.round(u))
    border.color: S.fg

    // ---- tall version (strip menu, attract screen) ----
    Column {
        id: col
        visible: !panel.wide
        x: 22 * panel.u
        y: 22 * panel.u
        width: panel.width - 44 * panel.u
        spacing: 10 * panel.u

        Text {
            width: parent.width
            text: "MADE BY"
            color: S.muted
            font.family: panel.fonts.pixel
            font.pixelSize: 28 * panel.u
            font.letterSpacing: 1.5 * panel.u
        }
        Text {
            width: parent.width
            text: panel.dev
            color: S.fg
            font.family: panel.fonts.display
            font.pixelSize: 38 * panel.u
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
        Rectangle {
            visible: panel.qr !== ""
            width: 136 * panel.u
            height: width
            color: "#ffffff"
            Image {
                anchors.fill: parent
                anchors.margins: 8 * panel.u
                source: panel.qr
                fillMode: Image.PreserveAspectFit
                smooth: false
                asynchronous: true
            }
        }
        Text {
            visible: panel.qr !== ""
            width: parent.width
            text: panel.url !== "" ? panel.url : "SCAN TO FIND IT"
            color: S.muted
            font.family: panel.url !== "" ? panel.fonts.text : panel.fonts.pixel
            font.pixelSize: (panel.url !== "" ? 20 : 26) * panel.u
            elide: Text.ElideRight
        }
    }

    // ---- wide version (grid sidebar): text on the left, QR on the right ----
    Column {
        id: wideText
        visible: panel.wide
        x: 22 * panel.u
        y: 22 * panel.u
        width: panel.width - 44 * panel.u - (panel.qr !== "" ? 126 * panel.u : 0)
        spacing: 8 * panel.u

        Text {
            width: parent.width
            text: "MADE BY"
            color: S.muted
            font.family: panel.fonts.pixel
            font.pixelSize: 28 * panel.u
            font.letterSpacing: 1.5 * panel.u
        }
        Text {
            width: parent.width
            text: panel.dev
            color: S.fg
            font.family: panel.fonts.display
            font.pixelSize: 44 * panel.u
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
        Text {
            visible: panel.url !== ""
            width: parent.width
            text: panel.url
            color: S.muted
            font.family: panel.fonts.text
            font.pixelSize: 22 * panel.u
            elide: Text.ElideRight
        }
    }
    Rectangle {
        visible: panel.wide && panel.qr !== ""
        width: 104 * panel.u
        height: width
        x: panel.width - width - 22 * panel.u
        y: (panel.height - height) / 2
        color: "#ffffff"
        Image {
            anchors.fill: parent
            anchors.margins: 6 * panel.u
            source: panel.qr
            fillMode: Image.PreserveAspectFit
            smooth: false
            asynchronous: true
        }
    }
}
