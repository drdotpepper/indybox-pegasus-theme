import QtQuick 2.8
import "config.js" as Config

// Indybox theme for Pegasus.
//   menu    - GridMenu or StripMenu (set Config.layout). Stick moves, accept plays.
//   attract - after Config.idleSeconds with no input; any input wakes it
FocusScope {
    id: root
    focus: true

    property real u: Math.min(width / 1920, height / 1080)
    property string mode: "menu"
    property int idle: 0

    FontLoader { id: antonFont;  source: "assets/fonts/Anton-Regular.ttf" }
    FontLoader { id: jerseyFont; source: "assets/fonts/Jersey10-Regular.ttf" }
    FontLoader { id: interFont;  source: "assets/fonts/Inter-Variable.ttf" }

    readonly property var fontSet: ({
        display: antonFont.name  !== "" ? antonFont.name  : "Impact",
        pixel:   jerseyFont.name !== "" ? jerseyFont.name : "Courier New",
        text:    interFont.name  !== "" ? interFont.name  : "Segoe UI"
    })

    function wake() {
        mode = "menu";
        idle = 0;
    }
    function sleepNow() {
        mode = "attract";
    }

    Loader {
        id: menuLoader
        anchors.fill: parent
        visible: root.mode === "menu"
        source: Config.layout === "strip" ? "StripMenu.qml" : "GridMenu.qml"
        onLoaded: {
            item.fonts = Qt.binding(function () { return root.fontSet; });
            item.u = Qt.binding(function () { return root.u; });
            var saved = api.memory.get("gameIndex");
            if (typeof saved === "number" && saved >= 0 && saved < api.allGames.count)
                item.index = saved;
        }
    }
    readonly property var menu: menuLoader.item
    readonly property bool launching: menu ? menu.launching : false

    AttractScreen {
        id: attract
        anchors.fill: parent
        visible: root.mode === "attract"
        active: root.mode === "attract"
        fonts: root.fontSet
        u: root.u
    }

    // idle watchdog
    Timer {
        interval: 1000
        repeat: true
        running: root.mode === "menu"
        onTriggered: {
            root.idle += 1;
            if (root.idle >= Config.idleSeconds && !root.launching)
                root.sleepNow();
        }
    }

    Keys.onPressed: {
        root.idle = 0;

        // Cancel (Esc) is left alone on purpose: Pegasus uses it to open its own
        // menu/settings, so the theme must not swallow it.
        if (api.keys.isCancel(event)) {
            event.accepted = false;
            return;
        }

        // first press only wakes the cabinet; it must not also start a game
        if (root.mode === "attract") {
            if (!event.isAutoRepeat) root.wake();
            event.accepted = true;
            return;
        }
        if (!root.menu || root.launching) {
            event.accepted = true;
            return;
        }

        if (api.keys.isAccept(event)) {
            if (!event.isAutoRepeat) root.menu.launchCurrent();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            root.menu.move(-1, 0);
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            root.menu.move(1, 0);
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            root.menu.move(0, -1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            root.menu.move(0, 1);
            event.accepted = true;
        }
    }
}
