import QtQuick 2.8
import "config.js" as Config
import "style.js" as S

// Grid menu: a grid of game tiles on the left, details for the selected game
// (title, blurb, credits/QR) on the right. All four stick directions move
// around the grid; one confirm button plays.
Item {
    id: menu

    property var fonts
    property real u: 1

    property alias index: grid.currentIndex
    readonly property int count: api.allGames.count
    readonly property var game: count > 0 ? api.allGames.get(grid.currentIndex) : null
    property bool launching: false

    // left/right step through the games (wrapping across rows);
    // up/down jump a whole row and wrap top <-> bottom
    function move(dx, dy) {
        if (count < 1) return;
        var i = grid.currentIndex;
        var cols = grid.columns;
        if (dx !== 0) {
            i = (i + dx + count) % count;
        } else if (dy !== 0) {
            var lastRowStart = Math.floor((count - 1) / cols) * cols;
            var next = i + dy * cols;
            if (next >= count) {
                // below the last full row: partial row -> last game, last row -> wrap to top
                i = (Math.floor(i / cols) * cols === lastRowStart) ? (i % cols) : (count - 1);
            } else if (next < 0) {
                i = Math.min(count - 1, lastRowStart + (i % cols));
            } else {
                i = next;
            }
        }
        grid.currentIndex = i;
    }

    function launchCurrent() {
        if (!game || launching) return;
        api.memory.set("gameIndex", grid.currentIndex);
        launching = true;
        launchGuard.restart();
        game.launch();
    }

    // if a launch fails, don't leave the cabinet stuck on the loading card
    Timer {
        id: launchGuard
        interval: 12000
        onTriggered: menu.launching = false
    }

    // ---- backdrop: selected game's art, dimmed like the website's taproom photo ----
    Rectangle { anchors.fill: parent; color: S.navy }
    Image {
        anchors.fill: parent
        source: menu.game && menu.game.assets
                ? (menu.game.assets.background || menu.game.assets.screenshot || menu.game.assets.titlescreen || "")
                : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {   // heavy dim: the art is only a faint tint behind the navy
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(6 / 255, 9 / 255, 13 / 255, 0.94) }
            GradientStop { position: 1.0; color: Qt.rgba(6 / 255, 9 / 255, 13 / 255, 0.97) }
        }
    }

    // ---- header: black strip with rounded return corners ----
    Rectangle {
        x: 0
        y: -30 * menu.u
        width: parent.width
        height: 150 * menu.u
        radius: 22 * menu.u
        color: S.bg
    }
    Image {
        x: 96 * menu.u
        y: 21 * menu.u
        width: 212 * menu.u
        height: 78 * menu.u
        source: "assets/indybox-logo-px.png"
        smooth: false
        mipmap: false
    }
    Text {
        x: 342 * menu.u
        y: 10 * menu.u
        height: 100 * menu.u
        verticalAlignment: Text.AlignVCenter
        text: "@" + S.upper(Config.venueName)
        color: S.fg
        font.family: menu.fonts.pixel
        font.pixelSize: 74 * menu.u
        font.letterSpacing: 1.5 * menu.u
    }

    // ---- the grid ----
    GridView {
        id: grid
        x: 86 * menu.u
        y: 174 * menu.u
        width: 1182 * menu.u          // two columns
        height: 818 * menu.u          // two rows
        cellWidth: 591 * menu.u
        cellHeight: 409 * menu.u
        readonly property int columns: Math.max(1, Math.floor(width / cellWidth))
        readonly property int visibleRows: Math.max(1, Math.floor(height / cellHeight + 0.01))
        property int topRow: 0
        model: api.allGames
        clip: true
        interactive: false
        // we scroll by whole rows ourselves so rows always sit flush with the top edge
        highlightFollowsCurrentItem: false
        Behavior on contentY { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        onCurrentIndexChanged: {
            var row = Math.floor(currentIndex / columns);
            if (row < topRow) topRow = row;
            else if (row >= topRow + visibleRows) topRow = row - visibleRows + 1;
            contentY = originY + topRow * cellHeight;
        }
        delegate: GridTile {
            game: modelData
            selected: GridView.isCurrentItem
            fonts: menu.fonts
            u: menu.u
        }
    }

    // ---- detail sidebar ----
    Rectangle {
        id: side
        x: 1280 * menu.u
        y: 170 * menu.u
        width: 544 * menu.u
        height: 826 * menu.u
        radius: 15 * menu.u
        color: Qt.rgba(0, 0, 0, 0.75)
        border.width: Math.max(1, Math.round(menu.u))
        border.color: S.line
        visible: menu.game !== null

        Text {
            x: 36 * menu.u
            y: 32 * menu.u
            width: 472 * menu.u
            height: 44 * menu.u
            text: menu.game && menu.game.developer ? ("BY " + S.upper(S.cleanDev(menu.game.developer))) : ""
            color: S.accent
            font.family: menu.fonts.pixel
            font.pixelSize: 40 * menu.u
            font.letterSpacing: 1.5 * menu.u
            elide: Text.ElideRight
        }
        Text {   // hard shadow, like the website headline
            x: title.x + 5 * menu.u
            y: title.y + 5 * menu.u
            width: title.width
            height: title.height
            text: title.text
            color: S.bg
            font: title.font
            lineHeight: title.lineHeight
            wrapMode: title.wrapMode
            fontSizeMode: title.fontSizeMode
            minimumPixelSize: title.minimumPixelSize
            maximumLineCount: title.maximumLineCount
            elide: title.elide
            verticalAlignment: title.verticalAlignment
        }
        Text {
            id: title
            x: 36 * menu.u
            y: 104 * menu.u
            width: 492 * menu.u
            height: 220 * menu.u
            text: S.upper(menu.game ? menu.game.title : "")
            color: S.fg
            font.family: menu.fonts.display
            font.italic: true
            font.pixelSize: 112 * menu.u
            font.letterSpacing: 1.2 * menu.u
            lineHeight: 0.98
            wrapMode: Text.WordWrap
            fontSizeMode: Text.Fit
            minimumPixelSize: 48 * menu.u
            maximumLineCount: 3
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        Row {
            id: chips
            x: 36 * menu.u
            y: title.y + title.height + 16 * menu.u
            spacing: 14 * menu.u
            Pill {
                width: 176 * menu.u
                u: menu.u
                family: menu.fonts.pixel
                fontSize: 30
                text: S.playersLabel(menu.game ? menu.game.players : 1)
            }
            Pill {
                visible: menu.game && menu.game.genre ? true : false
                width: 282 * menu.u
                u: menu.u
                family: menu.fonts.pixel
                fontSize: 30
                text: S.upper(menu.game ? menu.game.genre : "")
            }
        }
        Text {
            x: 36 * menu.u
            y: chips.y + chips.height + 28 * menu.u
            width: 472 * menu.u
            height: 150 * menu.u
            text: menu.game ? (menu.game.summary || menu.game.description || "") : ""
            color: S.fg
            font.family: menu.fonts.text
            font.pixelSize: 26 * menu.u
            lineHeight: 1.55
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        CreditsPanel {
            x: 36 * menu.u
            y: parent.height - height - 36 * menu.u
            wide: true
            fonts: menu.fonts
            u: menu.u
            game: menu.game
        }
    }

    // ---- footer hints ----
    Text {
        x: 96 * menu.u
        y: 1018 * menu.u
        text: "MOVE THE STICK TO CHOOSE   -   PRESS A BUTTON TO PLAY"
        color: S.muted
        font.family: menu.fonts.pixel
        font.pixelSize: 30 * menu.u
        font.letterSpacing: 1.5 * menu.u
    }
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 96 * menu.u
        y: 1018 * menu.u
        visible: menu.count > 0
        text: (grid.currentIndex + 1) + " / " + menu.count
        color: S.muted
        font.family: menu.fonts.pixel
        font.pixelSize: 30 * menu.u
        font.letterSpacing: 1.5 * menu.u
    }

    // ---- nothing found ----
    Column {
        visible: menu.count === 0
        anchors.centerIn: parent
        spacing: 16 * menu.u
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "NO GAMES FOUND"
            color: S.accent
            font.family: menu.fonts.display
            font.pixelSize: 96 * menu.u
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Add the games folder in Pegasus settings, or check metadata.pegasus.txt"
            color: S.muted
            font.family: menu.fonts.text
            font.pixelSize: 28 * menu.u
        }
    }

    // ---- launching card ----
    Rectangle {
        anchors.fill: parent
        visible: menu.launching
        color: S.bg
        Column {
            anchors.centerIn: parent
            spacing: 14 * menu.u
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: S.upper(menu.game ? menu.game.title : "")
                color: S.fg
                font.family: menu.fonts.display
                font.italic: true
                font.pixelSize: 110 * menu.u
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "LOADING..."
                color: S.accent
                font.family: menu.fonts.pixel
                font.pixelSize: 52 * menu.u
                font.letterSpacing: 2 * menu.u
            }
        }
    }
}
