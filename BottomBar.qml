import QtQuick 2.15
import "component"

Rectangle {
    id: buttonRoot
    property string buttonText: ""
    property string triggerText: ""
    property string iconSource: ""
    property bool isPressed: false
    property real horizontalPadding: 20

    signal clicked()
    signal triggerClicked()

    width: buttonContent.width + (horizontalPadding * 2)
    //height: 40
    height: itemContainer.height * 0.06
    radius: 5
    color: "transparent"
    border.color: "#6a6a6a"
    border.width: 2

    FontLoader {
        id: fontLoader
        source: "assets/font/font.ttf"
    }

    Row {
        id: buttonContent
        anchors.centerIn: parent
        spacing: 10

        Rectangle {
            id: triggerRect
            width: triggerText.length > 0 ? 70 : 0
            //height: 30
            height: itemContainer.height * 0.04
            visible: triggerText.length > 0
            radius: 5
            color: isPressed ? "#6a6a6a" : "transparent"
            border.color: "#6a6a6a"
            border.width: 2

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: triggerText
                font.pixelSize: Math.round(buttonRoot.height * 0.4)
                font.bold: true
                font.family: fontLoader.name
                color: isPressed ? "black" : "#6a6a6a"
            }
        }

        Image {
            id: icon
            visible: iconSource !== ""
            source: iconSource
            width: 30
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }

        Text {
            id: buttonLabel
            anchors.verticalCenter: parent.verticalCenter
            text: buttonRoot.buttonText
            font.pixelSize: Math.round(buttonRoot.height * 0.4)
            font.family: fontLoader.name
            font.bold: true
            color: "#6a6a6a"
        }
    }
}
