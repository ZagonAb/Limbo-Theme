import QtQuick 2.15

Rectangle {
    id: buttonRoot
    signal searchCancelled()

    property string buttonText: ""
    property var menuModel: []
    property string displayField: ""
    property bool isCollection: false
    property real horizontalPadding: 20
    property bool hasFocus: false
    property int buttonIndex: 0
    property bool isSearchButton: false
    property bool isSearchActive: false
    property real defaultWidth: buttonLabel.implicitWidth + (horizontalPadding * 2)
    property real expandedWidth: itemContainer.width * 0.3

    width: isSearchActive ? expandedWidth : defaultWidth
    height: itemContainer.height * 0.05
    radius: 5
    color: hasFocus ? "#6a6a6a" : "black"
    border.color: "#6a6a6a"
    border.width: 2

    Behavior on width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    FontLoader {
        id: fontLoader
        source: "assets/font/font.ttf"
    }

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    TextInput {
        id: searchInput
        anchors.centerIn: parent
        width: parent.width - (horizontalPadding * 2)
        color: hasFocus ? "black" : "#6a6a6a"
        text: isSearchActive ? "" : parent.buttonText
        font.pixelSize: Math.round(buttonRoot.height * 0.5)
        font.bold: true
        font.family: fontLoader.name
        visible: isSearchButton
        enabled: isSearchActive
        focus: isSearchActive
        maximumLength: 50

        Keys.onPressed: function(event) {
            if (!event.isAutoRepeat) {
                if (event.key === Qt.Key_Down) {
                    if (dropdownMenu.listView) {
                        dropdownMenu.listViewFocused = true
                        dropdownMenu.listView.forceActiveFocus()
                        dropdownMenu.listView.currentIndex = 0
                    }
                    event.accepted = true
                }
                else if (api.keys.isCancel(event)) {
                    if (searchInput.text.length > 0) {
                        searchInput.text = searchInput.text.substring(0, searchInput.text.length - 1)
                    } else {
                        var searchButton = null
                        for (var i = 0; i < topRowLeft.children.length; i++) {
                            if (topRowLeft.children[i].isSearchButton) {
                                searchButton = topRowLeft.children[i]
                                break
                            }
                        }
                        if (searchButton && searchButton.isSearchActive) {
                            searchButton.isSearchActive = false
                            searchProxyModel.filters[0].searchText = ""
                            dropdownMenu.listViewFocused = false
                            dropdownMenu.isOpen = false
                            dropdownMenu.closed()
                            root.topBarFocused = true
                            topItem.focus = true
                            searchCancelled()
                        }
                    }
                    event.accepted = true
                }
            }
        }

        property string placeholderText: "Search here..."

        Text {
            anchors.fill: parent
            text: searchInput.placeholderText
            color: "#4a4a4a"
            font: searchInput.font
            visible: isSearchActive && searchInput.text.length === 0
        }

        onTextChanged: {
            if (isSearchActive && text.length > 0) {
                updateSearchResults(text)
            }
        }
    }

    function deactivateSearch() {
        if (isSearchButton && isSearchActive) {
            isSearchActive = false;
            searchProxyModel.filters[0].searchText = "";
            dropdownMenu.listViewFocused = false;
            dropdownMenu.isOpen = false;
            dropdownMenu.closed();
            root.topBarFocused = true;
            topItem.focus = true;
        }
    }

    function activateSearch() {
        if (isSearchButton && isSearchActive) {
            searchInput.forceActiveFocus()
            searchInput.focus = true
        }
    }

    function backToSearch() {
        if (isSearchButton && isSearchActive) {
            searchInput.forceActiveFocus()
            searchInput.focus = true
        }
    }

    Text {
        id: buttonLabel
        anchors.centerIn: parent
        color: hasFocus ? "black" : "#6a6a6a"
        text: parent.buttonText
        font.pixelSize: Math.round(buttonRoot.height * 0.5)
        font.bold: true
        font.family: fontLoader.name
        visible: !isSearchButton || !isSearchActive

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    /*MouseArea {
     *       anchors.fill: parent
     *       onClicked: {
     *           if (dropdownMenu.isOpen && dropdownMenu.targetX === calculateMenuPosition()) {
     *               dropdownMenu.isOpen = false
} else {
    dropdownMenu.targetX = calculateMenuPosition()
    dropdownMenu.currentModel = menuModel
    dropdownMenu.displayField = displayField
    dropdownMenu.isCollectionModel = isCollection
    dropdownMenu.isOpen = true
}
}
}*/

    function calculateMenuPosition() {
        var globalPos = buttonRoot.mapToItem(null, 0, 0)
        var menuWidth = itemContainer.width * 0.30
        var windowWidth = itemContainer.width

        if (globalPos.x + menuWidth > windowWidth) {
            return windowWidth - menuWidth
        }

        return globalPos.x
    }

    function escapeRegExp(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    }

    function updateSearchResults(searchText) {
        if (isSearchButton) {
            var trimmedText = searchText.trim()

            if (trimmedText === "") {
                searchProxyModel.filters[0].searchText = ""
                return
            }

            var escapedText = escapeRegExp(trimmedText)
            searchProxyModel.filters[0].searchText = escapedText
        }
    }
}
