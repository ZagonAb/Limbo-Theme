import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Particles 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtMultimedia 5.15
import QtQml.Models 2.15
import SortFilterProxyModel 0.2
import "component"

FocusScope {
    id: root
    property int currentGameIndex: 0
    property int currentTopButtonIndex: 0
    property bool topBarFocused: false

    signal backToGalleryTriggered()

    Item {
        id: collectionsItem

        SortFilterProxyModel {
            id: favoritesProxyModel
            sourceModel: api.allGames
            filters: ValueFilter { roleName: "favorite"; value: true }
        }

        SortFilterProxyModel {
            id: historyPlaying
            sourceModel: api.allGames
            filters: ExpressionFilter {
                expression: lastPlayed != null && lastPlayed.toString() !== "Invalid Date"
            }
            sorters: RoleSorter {
                roleName: "lastPlayed"
                sortOrder: Qt.DescendingOrder
            }
        }

        SortFilterProxyModel {
            id: history
            sourceModel: historyPlaying
            filters: IndexFilter {
                minimumIndex: 0
                maximumIndex: 50
            }
        }


        SortFilterProxyModel {
            id: gamesFiltered
            sourceModel: api.allGames
            sorters: RoleSorter { roleName: "title"; sortOrder: Qt.AscendingOrder; }
        }

        SortFilterProxyModel {
            id: searchProxyModel
            sourceModel: api.allGames
            filters: ExpressionFilter {
                id: searchFilter
                property string searchText: ""
                expression: {
                    if (searchText === "") return true;

                    var regex = new RegExp("^" + searchText + ".+", "i");
                    return regex.test(String(model.title));
                }
            }
            sorters: RoleSorter {
                roleName: "title"
                sortOrder: Qt.AscendingOrder
            }
        }

        ListModel {
            id: gameListModel

            function getRandomIndices(count) {
                var indices = [];
                for (var i = 0; i < count; ++i) {
                    indices.push(i);
                }
                indices.sort(function() { return 0.5 - Math.random() });
                return indices;
            }

            Component.onCompleted: {
                var maxGames = 10;
                var randomIndices = getRandomIndices(gamesFiltered.count);
                for (var j = 0; j < maxGames && j < randomIndices.length; ++j) {
                    var gameIndex = randomIndices[j];
                    var game = gamesFiltered.get(gameIndex);
                    gameListModel.append(game);
                }
            }
        }
    }

    Item {
        id: itemContainer
        width: parent.width
        height: parent.height

        Item {
            id: topItem
            width: parent.width
            height: parent.height * 0.1
            anchors.top: parent.top
            property real margins: itemContainer.width * 0.02
            property real spacing: itemContainer.width * 0.02
            property bool hasFocus: root.topBarFocused
            property int currentButtonIndex: 0
            focus: hasFocus

            Row {
                id: topRowLeft
                anchors {
                    left: parent.left
                    leftMargin: topItem.margins
                    verticalCenter: parent.verticalCenter
                }
                spacing: topItem.spacing

                MenuButton {
                    buttonText: "COLLECTIONS"
                    menuModel: api.collections
                    displayField: "shortName"
                    isCollection: true
                    buttonIndex: 0
                    hasFocus: topItem.hasFocus && topItem.currentButtonIndex === 0
                }

                MenuButton {
                    buttonText: "ALL GAMES"
                    menuModel: api.allGames
                    displayField: "title"
                    buttonIndex: 1
                    hasFocus: topItem.hasFocus && topItem.currentButtonIndex === 1
                }

                MenuButton {
                    buttonText: "SEARCH"
                    menuModel: searchProxyModel
                    displayField: "title"
                    buttonIndex: 2
                    isSearchButton: true
                    hasFocus: topItem.hasFocus && topItem.currentButtonIndex === 2
                }
            }

            Row {
                id: topRowRight
                anchors {
                    right: parent.right
                    rightMargin: topItem.margins
                    verticalCenter: parent.verticalCenter
                }
                spacing: topItem.spacing

                MenuButton {
                    buttonText: "RANDOM GAMES"
                    menuModel: gameListModel
                    displayField: "title"
                    buttonIndex: 3
                    hasFocus: topItem.hasFocus && topItem.currentButtonIndex === 3
                }

                MenuButton {
                    buttonText: "RESUME"
                    menuModel: history
                    displayField: "title"
                    buttonIndex: 4
                    hasFocus: topItem.hasFocus && topItem.currentButtonIndex === 4
                }

                MenuButton {
                    buttonText: "FAVORITES"
                    menuModel: favoritesProxyModel
                    displayField: "title"
                    buttonIndex: 5
                    hasFocus: topItem.hasFocus && topItem.currentButtonIndex === 5
                }
            }

            function getCurrentButton() {
                var buttons = []
                for(var i = 0; i < topRowLeft.children.length; i++) {
                    if(topRowLeft.children[i].buttonIndex !== undefined) {
                        buttons.push(topRowLeft.children[i])
                    }
                }
                for(var j = 0; j < topRowRight.children.length; j++) {
                    if(topRowRight.children[j].buttonIndex !== undefined) {
                        buttons.push(topRowRight.children[j])
                    }
                }
                return buttons[currentButtonIndex]
            }

            Keys.onPressed: function(event) {
                if (!event.isAutoRepeat) {
                    var searchButton = null
                    for (var i = 0; i < topRowLeft.children.length; i++) {
                        if (topRowLeft.children[i].isSearchButton) {
                            searchButton = topRowLeft.children[i]
                            break
                        }
                    }

                    if (searchButton && searchButton.isSearchActive) {
                        if (api.keys.isCancel(event)) {
                            searchButton.isSearchActive = false
                            searchButton.deactivateSearch()
                            event.accepted = true
                        }

                        else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
                            event.accepted = true
                            return
                        }
                    }

                    else {
                        if (event.key === Qt.Key_Left) {
                            if (currentButtonIndex > 0) {
                                currentButtonIndex--
                            }
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Right) {
                            if (currentButtonIndex < 5) {
                                currentButtonIndex++
                            }
                            event.accepted = true
                        }
                        else if (api.keys.isAccept(event)) {
                            var currentButton = getCurrentButton()
                            if (currentButton) {
                                if (currentButton.isSearchButton) {
                                    currentButton.isSearchActive = !currentButton.isSearchActive
                                    if (currentButton.isSearchActive) {
                                        dropdownMenu.targetX = currentButton.calculateMenuPosition()
                                        dropdownMenu.currentModel = currentButton.menuModel
                                        dropdownMenu.displayField = currentButton.displayField
                                        dropdownMenu.isOpen = true
                                        currentButton.activateSearch()
                                    } else {
                                        dropdownMenu.isOpen = false
                                    }
                                } else {
                                    dropdownMenu.targetX = currentButton.calculateMenuPosition()
                                    dropdownMenu.currentModel = currentButton.menuModel
                                    dropdownMenu.displayField = currentButton.displayField
                                    dropdownMenu.isCollectionModel = currentButton.isCollection
                                    dropdownMenu.isOpen = !dropdownMenu.isOpen
                                }
                            }
                            event.accepted = true
                        }
                        else if (api.keys.isCancel(event)) {
                            var currentButton = getCurrentButton()
                            if (dropdownMenu.isOpen) {
                                if (currentButton && currentButton.isSearchButton) {
                                    currentButton.isSearchActive = false
                                }
                                dropdownMenu.isOpen = false
                            } else {
                                root.topBarFocused = false
                                gameGallery.focus = true
                                gameGallery.hasFocus = true
                                root.backToGalleryTriggered()
                            }
                            event.accepted = true
                        }
                    }
                }
            }
        }

        DropdownMenu {
            id: dropdownMenu
            z: 1000
            anchors {
                top: topItem.bottom
                topMargin: 0
            }
            x: targetX
            containerWidth: itemContainer.width
            containerHeight: itemContainer.height

            onClosed: {
                root.topBarFocused = true
                topItem.focus = true
            }
        }

        GameGallery {
            id: gameGallery
            anchors.centerIn: parent

            onUpBarButtonsTriggered: {
                root.topBarFocused = true
                root.currentTopButtonIndex = 0
                topItem.focus = true
            }
        }

        Item {
            id: bottomItem
            width: parent.width
            height: parent.height * 0.1
            anchors.bottom: parent.bottom
            property real margins: itemContainer.width * 0.02
            property real spacing: itemContainer.width * 0.02

            Rectangle {
                anchors.fill: parent
                color: "black"

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: bottomItem.margins
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 20

                    BottomBar {
                        id: prevButton
                        buttonText: "PREVIOUS"
                        triggerText: "LB"
                    }

                    BottomBar {
                        id: nextButton
                        buttonText: "NEXT"
                        triggerText: "RB"
                    }

                    BottomBar {
                        id: upButton
                        buttonText: root.topBarFocused ? "HOME GALLERY" : "TOP BAR BUTTONS"
                        triggerText: root.topBarFocused ? "BACK" : "UP"
                    }
                }

                Row {
                    anchors {
                        right: parent.right
                        rightMargin: bottomItem.margins
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 20

                    BottomBar {
                        id: okButton
                        visible: root.topBarFocused &&
                        (!dropdownMenu.isOpen ||
                        (dropdownMenu.isOpen &&
                        (topItem.getCurrentButton().buttonText !== "COLLECTIONS" ||
                        (topItem.getCurrentButton().buttonText === "COLLECTIONS" && dropdownMenu.gridViewFocused))))
                        buttonText: "OK"
                        iconSource: "assets/icons/ok.svg"
                    }

                    BottomBar {
                        id: favoriteButton
                        visible: (dropdownMenu.isOpen &&
                        ((topItem.getCurrentButton().buttonText === "ALL GAMES" ||
                        topItem.getCurrentButton().buttonText === "RESUME" ||
                        topItem.getCurrentButton().buttonText === "FAVORITES") ||
                        (topItem.getCurrentButton().buttonText === "COLLECTIONS" &&
                        dropdownMenu.gridViewFocused)))
                        buttonText: "FAVORITE"
                        iconSource: "assets/icons/favorite.png"
                    }
                }
            }

            Connections {
                target: gameGallery

                function onPrevPageTriggered() {
                    prevButton.isPressed = true
                    pressTimer.restart()
                }

                function onNextPageTriggered() {
                    nextButton.isPressed = true
                    pressTimer.restart()
                }

                function onUpBarButtonsTriggered() {
                    upButton.isPressed = true
                    pressTimer.restart()
                }
            }

            Connections {
                target: root

                function onBackToGalleryTriggered() {
                    upButton.isPressed = true
                    pressTimer.restart()
                }
            }

            Connections {
                target: dropdownMenu

                function onBackToDropdownmenuTriggered() {
                    upButton.isPressed = true
                    pressTimer.restart()
                }
            }

            Connections {
                target: topRowLeft.children[2]
                function onSearchCancelled() {
                    upButton.isPressed = true
                    pressTimer.restart()
                }
            }

            Connections {
                target: dropdownMenu

                function onBackToSearchInput() {
                    var searchButton = null
                    for (var i = 0; i < topRowLeft.children.length; i++) {
                        if (topRowLeft.children[i].isSearchButton) {
                            searchButton = topRowLeft.children[i]
                            break
                        }
                    }

                    if (searchButton) {
                        searchButton.backToSearch()
                    }
                }
            }

            Timer {
                id: pressTimer
                interval: 150
                onTriggered: {
                    prevButton.isPressed = false
                    nextButton.isPressed = false
                    upButton.isPressed = false
                }
            }
        }

        Effects {
            id: visualEffects
            anchors.fill: parent
            noiseOpacity: 0.08
            flickerInterval: 100
            flickerIntensity: 0.2
            topGradientOpacity: 2
            bottomGradientOpacity: 0.9
            z: 1001
        }
    }
}
