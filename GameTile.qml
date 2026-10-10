import QtQuick 2.8
import "style.js" as S

// One game tile. Selected = orange frame + orange title chip,
// the same fill-orange-on-focus treatment as the website's nav buttons.
// artW/artH set the picture size (design units), so the strip and grid share this.
Item {
    id: tile

    property var game: null
    property bool selected: false
    property var fonts
    property real u: 1
    property real artW: 288
    property real artH: 162

    width: (artW + 32) * u
    height: (20 + artH + 14 + 54) * u

    Rectangle {
        id: body
        x: 16 * tile.u
        y: 20 * tile.u
        width: tile.artW * tile.u
        height: tile.artH * tile.u
        color: S.plate
        border.width: tile.selected ? Math.round(5 * tile.u) : Math.max(1, Math.round(tile.u))
        border.color: tile.selected ? S.accent : S.line
        scale: tile.selected ? 1.05 : 1.0
        Behavior on scale { NumberAnimation { duration: 120 } }

        Image {
            id: art
            anchors.fill: parent
            anchors.margins: body.border.width
            source: S.shot(tile.game)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            clip: true
            opacity: tile.selected ? 1.0 : 0.72
        }
        Text {
            visible: art.status !== Image.Ready
            anchors.centerIn: parent
            width: parent.width - 28 * tile.u
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            text: S.upper(tile.game ? tile.game.title : "")
            color: S.fg
            font.family: tile.fonts.display
            font.pixelSize: 40 * tile.u
        }
    }

    Pill {
        x: 16 * tile.u
        y: (20 + tile.artH + 14) * tile.u
        width: tile.artW * tile.u
        height: 52 * tile.u
        u: tile.u
        family: tile.fonts.pixel
        fontSize: 30
        filled: tile.selected
        tone: tile.selected ? S.accent : S.muted
        text: S.upper(tile.game ? tile.game.title : "")
    }
}
