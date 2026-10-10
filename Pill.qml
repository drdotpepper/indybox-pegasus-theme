import QtQuick 2.8
import "style.js" as S

// The site's boxed button: 1px outline, 15px corners, pixel font.
// filled: true gives the orange "hover" state (fill + black text).
Rectangle {
    id: pill

    property string text: ""
    property bool filled: false
    property color tone: S.fg
    property string family: ""
    property real u: 1
    property real fontSize: 34

    radius: 15 * u
    color: filled ? tone : "transparent"
    border.width: Math.max(1, Math.round(u))
    border.color: tone

    implicitWidth: label.implicitWidth + 56 * u
    implicitHeight: label.implicitHeight + 22 * u

    Text {
        id: label
        anchors.centerIn: parent
        width: Math.min(implicitWidth, pill.width - 40 * pill.u)
        elide: Text.ElideRight
        text: pill.text
        color: pill.filled ? S.bg : pill.tone
        font.family: pill.family
        font.pixelSize: pill.fontSize * pill.u
        font.letterSpacing: 1.5 * pill.u
    }
}
