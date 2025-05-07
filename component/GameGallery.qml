import QtQuick 2.15
import QtGraphicalEffects 1.15
import SortFilterProxyModel 0.2
import "qrc:/qmlutils" as PegasusUtils

Item {
    id: galleryRoot
    property alias model: combinedModel
    property int currentGameIndex: 0
    property var game: ""
    property bool hasFocus: true
    property real horizontalPadding: 20

    signal prevPageTriggered()
    signal nextPageTriggered()
    signal upBarButtonsTriggered()

    width: parent.width * 0.9
    height: parent.height * 0.6
    opacity: hasFocus ? 1.0 : 0.10

    FontLoader {
        id: fontLoader
        source: "..//assets/font/font.ttf"
    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    SortFilterProxyModel {
        id: recentGames
        sourceModel: api.allGames
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
    }

    SortFilterProxyModel {
        id: allGames
        sourceModel: api.allGames
    }

    ListModel {
        id: combinedModel
        Component.onCompleted: updateModel()
    }

    function getNameCollecForGame(game) {
        if (game && game.collections && game.collections.count > 0) {
            var firstCollection = game.collections.get(0);
            for (var i = 0; i < api.collections.count; ++i) {
                var collection = api.collections.get(i);
                if (collection.name === firstCollection.name) {
                    return collection.name;
                }
            }
        }
        return "default";
    }

    function initializeGame() {
        if (combinedModel.count > 0) {
            game = combinedModel.get(0)
        }
    }

    function updateModel() {
        combinedModel.clear()
        var currentDate = new Date()
        var sevenDaysAgo = new Date(currentDate.getTime() - 7 * 24 * 60 * 60 * 1000)

        var recentFiltered = []
        for (var i = 0; i < recentGames.count; i++) {
            var game = recentGames.get(i)
            var lastPlayedDate = new Date(game.lastPlayed)
            var playTimeInMinutes = game.playTime / 60

            if (lastPlayedDate >= sevenDaysAgo && playTimeInMinutes > 1) {
                recentFiltered.push(game)
            }
        }

        var recentCount = Math.min(recentFiltered.length, 15)
        for (var j = 0; j < recentCount; j++) {
            combinedModel.append(recentFiltered[j])
        }

        if (combinedModel.count < 15) {
            var remainingSlots = 15 - combinedModel.count
            for (var k = 0; k < remainingSlots && k < allGames.count; k++) {
                var additionalGame = allGames.get(k)
                var isDuplicate = false

                for (var l = 0; l < combinedModel.count; l++) {
                    if (combinedModel.get(l).title === additionalGame.title) {
                        isDuplicate = true
                        break
                    }
                }

                if (!isDuplicate) {
                    combinedModel.append(additionalGame)
                }
            }
        }

        initializeGame()
    }

    Connections {
        target: api.allGames
        function onModelReset() {
            updateModel()
        }
        function onRowsInserted() {
            updateModel()
        }
        function onRowsRemoved() {
            updateModel()
        }
    }

    Item {
        id: gameItem
        width: parent.width
        height: parent.height * 0.95
        activeFocusOnTab: true
        focus: hasFocus
        property bool buttonsEnabled: true
        property int currentButtonIndex: 0

        Keys.onPressed: function(event) {
            if (!event.isAutoRepeat) {
                if (api.keys.isPrevPage(event)) {
                    if (currentGameIndex > 0) {
                        currentGameIndex--
                        gamesListView.currentIndex = currentGameIndex
                        galleryRoot.prevPageTriggered()
                    }
                    event.accepted = true
                }
                else if (api.keys.isNextPage(event)) {
                    if (currentGameIndex < gamesListView.model.count - 1) {
                        currentGameIndex++
                        gamesListView.currentIndex = currentGameIndex
                        galleryRoot.nextPageTriggered()
                    }
                    event.accepted = true
                }
                else if (api.keys.isCancel(event)) {
                    // Mantenemos el evento vacío para futura lógica
                    //event.accepted = true
                }
                else if (api.keys.isAccept(event)) {
                    event.accepted = true
                    var selectedGame = gamesListView.model.get(gamesListView.currentIndex);
                    var collectionName = getNameCollecForGame(selectedGame);

                    if (currentButtonIndex === 0) {
                        for (var i = 0; i < api.collections.count; ++i) {
                            var collection = api.collections.get(i);
                            if (collection.name === collectionName) {
                                for (var j = 0; j < collection.games.count; ++j) {
                                    var game = collection.games.get(j);
                                    if (game.title === selectedGame.title) {
                                        game.launch();
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                    } else if (currentButtonIndex === 1) {
                        for (var i = 0; i < api.collections.count; ++i) {
                            var collection = api.collections.get(i);
                            if (collection.name === collectionName) {
                                for (var j = 0; j < collection.games.count; ++j) {
                                    var currentGame = collection.games.get(j);
                                    if (currentGame.title === selectedGame.title) {
                                        currentGame.favorite = !currentGame.favorite;
                                        favoriteButton.isFavorite = currentGame.favorite;
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                    }
                }
                else if (event.key === Qt.Key_Left) {
                    if (currentButtonIndex > 0) {
                        currentButtonIndex--
                    }
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Right) {
                    if (currentButtonIndex < 1) {
                        currentButtonIndex++
                    }
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Up) {
                    event.accepted = true
                    galleryRoot.hasFocus = false
                    upBarButtonsTriggered()
                }
            }
        }

        ListView {
            id: gamesListView
            width: parent.width
            height: parent.height

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            interactive: false
            clip: true
            cacheBuffer: 0
            highlightMoveDuration: 0
            preferredHighlightBegin: 0
            preferredHighlightEnd: 0
            highlightRangeMode: ListView.StrictlyEnforceRange
            orientation: ListView.Horizontal
            model: combinedModel

            Component.onCompleted: {
                currentIndex = 0
                positionViewAtIndex(0, ListView.Beginning)
            }

            delegate: Item {
                width: gamesListView.width
                height: gamesListView.height

                opacity: ListView.isCurrentItem ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                function calculatePlayTimeText(includePrefix) {
                    let seconds = game.playTime || 0;
                    if (seconds === 0) return "";

                    let hours = Math.floor(seconds / 3600);
                    let minutes = Math.floor((seconds % 3600) / 60);
                    let remainingSeconds = seconds % 60;

                    let hoursStr = hours.toString().padStart(2, '0');
                    let minutesStr = minutes.toString().padStart(2, '0');
                    let secondsStr = remainingSeconds.toString().padStart(2, '0');

                    let playTime = hoursStr + ":" + minutesStr + ":" + secondsStr;
                    return includePrefix ? "Runtime: " + playTime : playTime;
                }

                function getShortNameForGame(game) {
                    if (game && game.collections && game.collections.count > 0) {
                        var firstCollection = game.collections.get(0);
                        for (var i = 0; i < api.collections.count; ++i) {
                            var collection = api.collections.get(i);
                            if (collection.name === firstCollection.name) {
                                return collection.shortName;
                            }
                        }
                    }
                    return "default";
                }

                function calculateLastPlayedText() {
                    if (!game || !game.lastPlayed) {
                        return "Played: Never"
                    }
                    let date = new Date(game.lastPlayed)
                    if (isNaN(date.getTime())) {
                        return "Played: Never"
                    }
                    let now = new Date()
                    let today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
                    let yesterday = new Date(today.getTime() - (1000 * 60 * 60 * 24))
                    if (date >= today) {
                        return "Played: Today"
                    } else if (date >= yesterday) {
                        return "Played: Yesterday"
                    } else {
                        return "Played: " + date.toLocaleDateString("en-GB")
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        Column {
                            width: parent.width * 0.5
                            spacing: 20

                            Item {
                                width: parent.width
                                height: gamesListView.height * 0.10

                                Text {
                                    text: game.title
                                    font.pixelSize: galleryRoot.width * 0.025
                                    color: "#6a6a6a"
                                    font.bold: true
                                    font.family: fontLoader.name
                                    elide: Text.ElideRight
                                    anchors.fill: parent
                                }
                            }

                            Row {
                                spacing: 10
                                height: 20

                                Text {
                                    text: game && game.rating ? "Rating: " + (game.rating * 100).toFixed(0) + "%" : "Rating: N/A"
                                    font.pixelSize: galleryRoot.width * 0.012
                                    color: "#6a6a6a"
                                    font.bold: true
                                    font.family: fontLoader.name
                                }

                                Text {
                                    text: "Players: " + (game.players || "1")
                                    font.pixelSize: galleryRoot.width * 0.012
                                    color: "#6a6a6a"
                                    font.bold: true
                                    font.family: fontLoader.name
                                }

                                Text {
                                    visible: game.lastPlayed && game.lastPlayed.toString() !== "Invalid Date"
                                    text: calculateLastPlayedText()
                                    font.pixelSize: galleryRoot.width * 0.012
                                    color: "#6a6a6a"
                                    font.bold: true
                                    font.family: fontLoader.name
                                }

                                Text {
                                    visible: game.playTime > 0
                                    text: "Runtime: " + calculatePlayTimeText(false)
                                    font.pixelSize: galleryRoot.width * 0.012
                                    color: "#6a6a6a"
                                    font.bold: true
                                    font.family: fontLoader.name
                                }

                                Text {
                                    text: "Coll.: " + getShortNameForGame(game)
                                    font.pixelSize: galleryRoot.width * 0.012
                                    color: "#6a6a6a"
                                    font.bold: true
                                    font.family: fontLoader.name
                                }
                            }

                            Item {
                                id: descriptionContainer
                                width: parent.width * 0.90
                                height: gamesListView.height * 0.50

                                Rectangle {
                                    id: mainRect
                                    anchors.fill: parent
                                    color: "black"

                                    function cleanDescription(text) {
                                        return text.replace(/\n\s*\n/g, '\n').trim();
                                    }

                                    PegasusUtils.AutoScroll {
                                        id: autoscroll
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                        }
                                        height: parent.height

                                        Text {
                                            id: descripText
                                            text: mainRect.cleanDescription(game.description)
                                            width: parent.width
                                            wrapMode: Text.Wrap
                                            font.pixelSize: galleryRoot.width * 0.013
                                            color: "#6a6a6a"
                                            font.bold: true
                                            font.family: fontLoader.name
                                        }
                                    }

                                    Rectangle {
                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            right: parent.right
                                        }
                                        height: 20
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: mainRect.color }
                                            GradientStop { position: 1.0; color: "transparent" }
                                        }
                                    }

                                    Rectangle {
                                        anchors {
                                            bottom: parent.bottom
                                            left: parent.left
                                            right: parent.right
                                        }
                                        height: 20
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "transparent" }
                                            GradientStop { position: 1.0; color: mainRect.color }
                                        }
                                    }
                                }
                            }
                        }

                        ImageWithEffects {
                            source: modelData.assets.screenshot
                            fillMode: Image.PreserveAspectFit
                            width: parent.width * 0.5
                            height: parent.height
                        }
                    }
                }
            }

            onCurrentIndexChanged: {
                game = gamesListView.model.get(gamesListView.currentIndex);
            }
        }

        Row {
            id: delegateButtons
            anchors {
                top: gamesListView.bottom
                left: parent.left
                topMargin: - parent.height * 0.1
                leftMargin: 20
            }
            spacing: 10

            Rectangle {
                width: launchText.implicitWidth + (horizontalPadding * 2)
                height: 40
                color: gameItem.buttonsEnabled && gameItem.currentButtonIndex === 0
                ? "#6a6a6a" : "transparent"
                radius: 5
                border.color: "#6a6a6a"
                border.width: 2

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    id: launchText
                    anchors.centerIn: parent
                    text: "LAUNCH"
                    font.pixelSize: Math.round(gameItem.height * 0.05)
                    font.bold: true
                    color: gameItem.buttonsEnabled && gameItem.currentButtonIndex === 0
                    ? "black" : "#6a6a6a"
                    font.family: fontLoader.name
                }
            }

            Rectangle {
                id: favoriteButton
                width: favoriteText.implicitWidth + (horizontalPadding * 2)
                height: 40
                color: gameItem.buttonsEnabled && gameItem.currentButtonIndex === 1
                ? "#6a6a6a" : "transparent"
                radius: 5
                border.color: "#6a6a6a"
                border.width: 2

                property bool isFavorite: false

                Component.onCompleted: {
                    updateFavoriteState();
                }

                Connections {
                    target: gamesListView
                    function onCurrentIndexChanged() {
                        favoriteButton.updateFavoriteState();
                    }
                }

                function updateFavoriteState() {
                    if (!game) return;
                    var collectionName = getNameCollecForGame(game);
                    for (var i = 0; i < api.collections.count; ++i) {
                        var collection = api.collections.get(i);
                        if (collection.name === collectionName) {
                            for (var j = 0; j < collection.games.count; ++j) {
                                var currentGame = collection.games.get(j);
                                if (currentGame.title === game.title) {
                                    isFavorite = currentGame.favorite;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    id: favoriteText
                    anchors.centerIn: parent
                    text: favoriteButton.isFavorite ? "FAVORITE -" : "FAVORITE +"
                    font.pixelSize: Math.round(gameItem.height * 0.05)
                    font.bold: true
                    color: gameItem.buttonsEnabled && gameItem.currentButtonIndex === 1
                    ? "black" : "#6a6a6a"
                    font.family: fontLoader.name
                }
            }
        }
    }

    Row {
        id: pageIndicators

        opacity: galleryRoot.hasFocus ? 1.0 : 0.15

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        anchors {
            top: gameItem.bottom
            topMargin: gameItem.height * 0.15
            horizontalCenter: parent.horizontalCenter
        }

        spacing: 8

        Repeater {
            model: gamesListView.model.count

            Rectangle {
                width: 12
                height: 12
                radius: width/2
                color: gamesListView.currentIndex === index ? "#6a6a6a" : "#3a3a3a"

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }
}
