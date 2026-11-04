import QtQuick 2.8
import "style.js" as S

// The site's boxed button: 1px outline, pixel font.
// filled: true gives the orange "hover" state (fill + black text).
Rectangle {
    id: pill

    property string text: ""
    property bool filled: false
    property color tone: S.fg
    property string family: ""
    property real u: 1
    property real fontSize: 34
    property bool outline: true

    radius: 0
    color: filled ? tone : "transparent"
    border.width: outline ? Math.max(1, Math.round(u)) : 0
    border.color: tone

    implicitWidth: label.implicitWidth + 56 * u
    implicitHeight: label.implicitHeight + 22 * u

    Text {
        id: label
        x: pill.outline ? (pill.width - width) / 2 : 0
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, pill.width - 40 * pill.u)
        elide: Text.ElideRight
        text: pill.text
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: 18 * pill.u
        color: pill.filled ? S.bg : pill.tone
        font.family: pill.family
        font.pixelSize: pill.fontSize * pill.u
        font.letterSpacing: 1.5 * pill.u
    }
}
