import QtQuick 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: dropdownRoot

    signal closed()
    signal backToDropdownmenuTriggered()
    signal backToSearchInput()

    property bool gridViewFocused: false
    property real containerWidth: 0
    property real containerHeight: 0
    property var currentModel: []
    property string displayField: ""
    property bool isOpen: false
    property real targetX: 0
    property int topMargin: 0
    property bool isCollectionModel: false
    property bool listViewFocused: false
    property var currentCollectionGames: []
    property alias listView: listView
    visible: false
    width: containerWidth * 1.0
    height: containerHeight * 0.75
    color: "transparent"
    border.color: "transparent"
    border.width: 2
    radius: 0

    FontLoader {
        id: fontLoader
        source: "assets/font/font.ttf"
    }

    Row {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            id: leftPanel
            width: parent.width * 0.25
            height: parent.height
            color: "transparent"

            ListView {
                id: listView
                anchors {
                    fill: parent
                    margins: 5
                }
                model: dropdownRoot.currentModel
                clip: true
                focus: dropdownRoot.listViewFocused
                currentIndex: dropdownRoot.listViewFocused ? 0 : -1
                highlightMoveDuration: 0
                highlightMoveVelocity: -1

                highlight: Rectangle {
                    color: "#3f3f3f"
                    radius: 5
                    visible: true
                }

                delegate: Item {
                    width: listView.width
                    height: 40

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 10
                                rightMargin: 10
                            }
                            spacing: 10

                            Item {
                                width: dropdownRoot.width * 0.02
                                height: dropdownRoot.height * 0.10
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    id: itemIcon
                                    anchors.fill: parent
                                    source: dropdownRoot.isCollectionModel ?
                                    "assets/systems/" + modelData.shortName + ".png" :
                                    "assets/systems/" + getShortNameForGame(modelData) + "-content.png"
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true

                                    onStatusChanged: {
                                        if (status === Image.Error) {
                                            source = dropdownRoot.isCollectionModel ?
                                            "assets/systems/default.png" :
                                            "assets/systems/default-content.png"
                                        }
                                    }
                                }

                                ColorOverlay {
                                    anchors.fill: parent
                                    source: itemIcon
                                    color: dropdownRoot.listViewFocused && listView.currentIndex === index ? "#ffffff" : "#6a6a6a"
                                    cached: true
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - itemIcon.width - parent.spacing
                                text: `${model.favorite ? "★" : ""} ${dropdownRoot.getDisplayText(modelData)}`
                                color: dropdownRoot.listViewFocused && listView.currentIndex === index ? "#ffffff" : "#6a6a6a"
                                font.pixelSize: Math.round(dropdownRoot.height * 0.03)
                                font.bold: true
                                font.family: fontLoader.name
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    currentIndex = 0
                }

                onCurrentIndexChanged: {
                    if (dropdownRoot.isCollectionModel && currentIndex >= 0) {
                        const selectedCollection = dropdownRoot.currentModel.get(currentIndex)
                        gameGrid.model = selectedCollection.games
                    }
                }

                Keys.onPressed: function(event) {
                    if (!event.isAutoRepeat) {
                        if (event.key === Qt.Key_Up) {
                            if (currentIndex > 0) {
                                currentIndex--
                            } else {
                                var searchButton = null
                                for (var i = 0; i < topRowLeft.children.length; i++) {
                                    if (topRowLeft.children[i].isSearchButton) {
                                        searchButton = topRowLeft.children[i]
                                        break
                                    }
                                }
                                if (searchButton && searchButton.isSearchActive) {
                                    dropdownRoot.listViewFocused = false
                                    searchButton.activateSearch()
                                }
                            }
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Down) {
                            if (currentIndex < count - 1) {
                                currentIndex++
                            }
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Right && dropdownRoot.isCollectionModel) {
                            dropdownRoot.listViewFocused = false
                            dropdownRoot.gridViewFocused = true
                            gameGrid.forceActiveFocus()
                            event.accepted = true
                        }
                        else if (api.keys.isAccept(event)) {
                            event.accepted = true;
                            var selectedGame = listView.model.get(listView.currentIndex);
                            var collectionName = getNameCollecForGame(selectedGame);
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

                        }
                        else if (api.keys.isCancel(event)) {
                            var searchButton = null;
                            for (var i = 0; i < topRowLeft.children.length; i++) {
                                if (topRowLeft.children[i].isSearchButton) {
                                    searchButton = topRowLeft.children[i];
                                    break;
                                }
                            }

                            // Modificación principal: Si estamos en búsqueda, volver al campo de búsqueda en lugar de cerrar
                            if (searchButton && searchButton.isSearchActive) {
                                dropdownRoot.listViewFocused = false
                                searchButton.activateSearch()
                                dropdownRoot.backToSearchInput()
                                event.accepted = true
                            } else {
                                // Comportamiento original para los demás casos
                                if (searchButton && searchButton.isSearchActive) {
                                    searchButton.isSearchActive = false;
                                }
                                dropdownRoot.listViewFocused = false
                                dropdownRoot.gridViewFocused = false
                                dropdownRoot.isOpen = false
                                dropdownRoot.closed()
                                backToDropdownmenuTriggered()
                                event.accepted = true
                            }
                        }
                        else if (api.keys.isDetails(event)) {
                            event.accepted = true;
                            var selectedGame = listView.model.get(listView.currentIndex);
                            var collectionName = getNameCollecForGame(selectedGame);
                            for (var i = 0; i < api.collections.count; ++i) {
                                var collection = api.collections.get(i);
                                if (collection.name === collectionName) {
                                    for (var j = 0; j < collection.games.count; ++j) {
                                        var game = collection.games.get(j);
                                        if (game.title === selectedGame.title) {
                                            game.favorite = !game.favorite;
                                            break;
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }

                onActiveFocusChanged: {
                    if (activeFocus) {
                        currentIndex = 0
                    }
                }
            }
        }

        Rectangle {
            id: rightPanel
            width: parent.width * 0.70
            height: parent.height
            color: "transparent"
            visible: dropdownRoot.isCollectionModel

            GridView {
                id: gameGrid
                anchors.fill: parent
                cellWidth: 250
                cellHeight: 40
                clip: true

                property int currentRow: 0
                property int currentCol: 0
                property int columnsCount: Math.floor(width / cellWidth)

                highlight: Rectangle {
                    color: "#3f3f3f"
                    radius: 5
                    visible: dropdownRoot.gridViewFocused
                }

                highlightMoveDuration: 0
                highlightFollowsCurrentItem: true

                delegate: Rectangle {
                    width: gameGrid.cellWidth - 10
                    height: gameGrid.cellHeight - 5
                    color: "transparent"
                    border.color: "#3f3f3f"
                    border.width: 1
                    radius: 5

                    Text {

                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                            leftMargin: 10
                            rightMargin: 10
                        }

                        text: `${model.favorite ? "★" : ""} ${model.title}`
                        color: dropdownRoot.gridViewFocused && gameGrid.currentIndex === index ? "#ffffff" : "#6a6a6a"
                        font.pixelSize: 14
                        font.family: fontLoader.name
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width - 20
                    }
                }

                Keys.onPressed: function(event) {
                    if (!event.isAutoRepeat) {
                        if (event.key === Qt.Key_Left) {
                            if (currentCol > 0) {
                                currentIndex--
                                currentCol--
                            } else {
                                dropdownRoot.gridViewFocused = false
                                dropdownRoot.listViewFocused = true
                                listView.forceActiveFocus()
                            }
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Right) {
                            if (currentCol < columnsCount - 1 && currentIndex < count - 1) {
                                currentIndex++
                                currentCol++
                            }
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Up) {
                            if (currentIndex >= columnsCount) {
                                currentIndex -= columnsCount
                                currentRow--
                            }
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Down) {
                            if (currentIndex + columnsCount < count) {
                                currentIndex += columnsCount
                                currentRow++
                            }
                            event.accepted = true
                        }
                        else if (api.keys.isAccept(event)) {
                            event.accepted = true;
                            var selectedGame = gameGrid.model.get(gameGrid.currentIndex);
                            var collectionName = getNameCollecForGame(selectedGame);
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
                        }
                        else if (api.keys.isCancel(event)) {
                            dropdownRoot.gridViewFocused = false
                            dropdownRoot.listViewFocused = true
                            listView.forceActiveFocus()
                            backToDropdownmenuTriggered()
                            event.accepted = true
                        }
                        else if (api.keys.isDetails(event)) {
                            event.accepted = true;
                            var selectedGame = gameGrid.model.get(gameGrid.currentIndex);
                            var collectionName = getNameCollecForGame(selectedGame);
                            for (var i = 0; i < api.collections.count; ++i) {
                                var collection = api.collections.get(i);
                                if (collection.name === collectionName) {
                                    for (var j = 0; j < collection.games.count; ++j) {
                                        var game = collection.games.get(j);
                                        if (game.title === selectedGame.title) {
                                            game.favorite = !game.favorite;
                                            break;
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }

                onActiveFocusChanged: {
                    if (activeFocus) {
                        currentIndex = 0
                        currentRow = 0
                        currentCol = 0
                    }
                }
            }
        }
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

    function getDisplayText(item) {
        if (!item) return ""
            if (!displayField) return item.toString()
                return item[displayField] || ""
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

    states: State {
        name: "open"
        when: dropdownRoot.isOpen
        PropertyChanges {
            target: dropdownRoot
            visible: true
            opacity: 1
            listViewFocused: true
        }
        StateChangeScript {
            script: {
                if (dropdownRoot.isCollectionModel && dropdownRoot.currentModel.count > 0) {
                    const firstCollection = dropdownRoot.currentModel.get(0)
                    gameGrid.model = firstCollection.games
                }
            }
        }
    }

    transitions: Transition {
        from: ""
        to: "open"
        reversible: true

        SequentialAnimation {
            PropertyAction {
                property: "visible"
            }
            NumberAnimation {
                property: "opacity"
                duration: 200
            }
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
            GradientStop { position: 0.0; color: "black" }
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
            GradientStop { position: 1.0; color: "black" }
        }
    }
}
