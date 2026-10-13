import QtQuick 2.8
import "style.js" as S

// One game tile for the grid: title on a tab above the screenshot.
// Selected = solid orange frame + orange tab with black text (like the site's
// hover buttons); unselected = dark panel, thin grey line, grey text.
// The title scales to fit its tab: short names come out big, long ones shrink.
Item {
    id: tile

    property var game: null
    property bool selected: false
    property var fonts
    property real u: 1

    readonly property real tileW: 572
    readonly property real tileH: 369
    readonly property real tabH: 40
    readonly property real inset: 8
    readonly property real tabW: selected ? 322 : 330
    readonly property real textW: tabW - (selected ? 32 : 38)    // room for the title
    readonly property real maxTextSize: selected ? 52 : 54

    width: tileW * u
    height: tileH * u

    // picture sits underneath; the frame drawn on top has a rounded window over it
    Image {
        id: art
        x: tile.inset * tile.u
        y: (tile.tabH + tile.inset) * tile.u
        width: (tile.tileW - 2 * tile.inset) * tile.u
        height: (tile.tileH - tile.tabH - 2 * tile.inset) * tile.u
        source: S.shot(tile.game)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        clip: true
        opacity: tile.selected ? 1.0 : 0.8
    }
    Text {   // no screenshot yet: show the title big, so the tile isn't an empty box
        visible: art.status !== Image.Ready
        x: art.x
        y: art.y
        width: art.width
        height: art.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
        text: S.upper(tile.game ? tile.game.title : "")
        color: S.line
        font.family: tile.fonts.display
        font.pixelSize: 60 * tile.u
        leftPadding: 24 * tile.u
        rightPadding: 24 * tile.u
    }

    TabFrame {
        anchors.fill: parent
        u: tile.u
        tabW: tile.tabW
        tabH: tile.tabH
        inset: tile.inset
        fillColor: tile.selected ? S.accent : Qt.rgba(8 / 255, 15 / 255, 22 / 255, 0.94)
        lineColor: S.panelLine
        lineWidth: tile.selected ? 0 : 3
    }

    Text {
        id: label
        x: (tile.tabW - tile.textW) / 2 * tile.u
        // every title shares one baseline, whatever size it ends up
        y: 34.5 * tile.u - baselineOffset
        width: tile.textW * tile.u
        horizontalAlignment: Text.AlignHCenter
        text: S.upper(tile.game ? tile.game.title : "")
        elide: Text.ElideRight
        color: tile.selected ? S.bg : S.muted
        font.family: tile.fonts.pixel
        font.pixelSize: tile.maxTextSize * tile.u
        font.letterSpacing: 1.5 * tile.u
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: 22 * tile.u
    }
}
