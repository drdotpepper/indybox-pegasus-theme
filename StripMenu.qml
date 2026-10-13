import QtQuick 2.8
import "config.js" as Config
import "style.js" as S

// Game menu: header, big hero for the selected game, a strip of tiles,
// and the developer credits/QR zone. Driven entirely by stick directions
// and one confirm button (keys are handled in theme.qml).
Item {
    id: menu

    property var fonts
    property real u: 1

    property alias index: list.currentIndex
    readonly property int count: api.allGames.count
    readonly property var game: count > 0 ? api.allGames.get(list.currentIndex) : null
    property bool launching: false

    // dx/dy come from the stick; the strip is one row, so any direction steps along it
    function move(dx, dy) {
        if (count < 1) return;
        var step = dx !== 0 ? dx : dy;
        list.currentIndex = (list.currentIndex + step + count) % count;
    }

    function launchCurrent() {
        if (!game || launching) return;
        api.memory.set("gameIndex", list.currentIndex);
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
    Rectangle { anchors.fill: parent; color: S.bg }
    Image {
        anchors.fill: parent
        source: menu.game && menu.game.assets
                ? (menu.game.assets.background || menu.game.assets.screenshot || menu.game.assets.titlescreen || "")
                : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.62) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.90) }
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
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 96 * menu.u
        y: 30 * menu.u
        spacing: 18 * menu.u

        Pill {
            u: menu.u
            family: menu.fonts.pixel
            fontSize: 38
            filled: true
            tone: S.accent
            text: "FREE PLAY"
        }
        Pill {
            u: menu.u
            family: menu.fonts.pixel
            fontSize: 38
            text: "@" + S.upper(Config.venueName)
        }
    }

    // ---- hero (left): developer, title, chips, blurb ----
    Item {
        id: hero
        x: 96 * menu.u
        y: 170 * menu.u
        width: 880 * menu.u
        height: 500 * menu.u
        visible: menu.game !== null

        Text {
            id: devLine
            width: parent.width
            height: 44 * menu.u
            text: menu.game && menu.game.developer ? ("BY " + S.upper(S.cleanDev(menu.game.developer))) : ""
            color: S.accent
            font.family: menu.fonts.pixel
            font.pixelSize: 42 * menu.u
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
        }
        Text {
            id: title
            y: 56 * menu.u
            width: parent.width
            height: 240 * menu.u
            text: S.upper(menu.game ? menu.game.title : "")
            color: S.fg
            font.family: menu.fonts.display
            font.italic: true
            font.pixelSize: 136 * menu.u
            lineHeight: 0.98
            wrapMode: Text.WordWrap
            fontSizeMode: Text.Fit
            minimumPixelSize: 56 * menu.u
            maximumLineCount: 3
            elide: Text.ElideRight
            verticalAlignment: Text.AlignTop
        }
        Row {
            id: chips
            y: title.y + title.contentHeight + 30 * menu.u
            spacing: 14 * menu.u
            Pill {
                u: menu.u
                family: menu.fonts.pixel
                fontSize: 32
                text: S.playersLabel(menu.game ? menu.game.players : 1)
            }
            Pill {
                visible: menu.game && menu.game.genre ? true : false
                u: menu.u
                family: menu.fonts.pixel
                fontSize: 32
                text: S.upper(menu.game ? menu.game.genre : "")
            }
        }
        Text {
            y: chips.y + chips.height + 28 * menu.u
            width: parent.width
            height: 120 * menu.u
            text: menu.game ? (menu.game.summary || menu.game.description || "") : ""
            color: S.fg
            font.family: menu.fonts.text
            font.pixelSize: 28 * menu.u
            lineHeight: 1.3
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }
    }

    // ---- hero (right): big preview plate ----
    Rectangle {
        id: plate
        x: 1024 * menu.u
        y: 170 * menu.u
        width: 800 * menu.u
        height: 450 * menu.u
        visible: menu.game !== null
        color: S.plate
        border.width: Math.max(1, Math.round(menu.u))
        border.color: S.line

        Image {
            id: plateArt
            anchors.fill: parent
            anchors.margins: plate.border.width
            source: menu.game && menu.game.assets
                    ? (menu.game.assets.screenshot || menu.game.assets.titlescreen || menu.game.assets.background || menu.game.assets.boxFront || "")
                    : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            clip: true
        }
        Text {
            visible: plateArt.status !== Image.Ready
            anchors.centerIn: parent
            width: parent.width - 80 * menu.u
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: S.upper(menu.game ? menu.game.title : "")
            color: S.line
            font.family: menu.fonts.display
            font.pixelSize: 110 * menu.u
        }
    }

    // ---- tile strip ----
    ListView {
        id: list
        x: 0
        y: 718 * menu.u
        width: 1540 * menu.u
        height: 260 * menu.u
        orientation: ListView.Horizontal
        model: api.allGames
        clip: true
        interactive: false
        leftMargin: 96 * menu.u
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 96 * menu.u
        preferredHighlightEnd: width - 96 * menu.u - 320 * menu.u
        highlightMoveDuration: 180
        delegate: GameTile {
            game: modelData
            selected: ListView.isCurrentItem
            fonts: menu.fonts
            u: menu.u
        }
    }

    // ---- credits / QR zone ----
    CreditsPanel {
        anchors.right: parent.right
        anchors.rightMargin: 96 * menu.u
        y: 960 * menu.u - height
        fonts: menu.fonts
        u: menu.u
        game: menu.game
    }

    // ---- footer hints ----
    Text {
        x: 96 * menu.u
        y: 1004 * menu.u
        text: "MOVE THE STICK TO CHOOSE   -   PRESS A BUTTON TO PLAY"
        color: S.muted
        font.family: menu.fonts.pixel
        font.pixelSize: 32 * menu.u
        font.letterSpacing: 1.5 * menu.u
    }
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 96 * menu.u
        y: 1004 * menu.u
        visible: menu.count > 0
        text: (list.currentIndex + 1) + " / " + menu.count
        color: S.muted
        font.family: menu.fonts.pixel
        font.pixelSize: 32 * menu.u
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
