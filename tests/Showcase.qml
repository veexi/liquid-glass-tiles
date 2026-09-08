import QtQuick
import QtQuick.Controls
import "../package/contents/ui"

ApplicationWindow {
    id: window
    width: 1280
    height: 800
    visible: true
    title: "Liquid Glass Tiles — showcase"
    Glass {
        id: glass
        objectName: "glass"
        anchors.fill: parent
        wallpaper: Qt.resolvedUrl("../package/contents/images/demo.svg")
        glassOpacity: 1
        frost: 0.6
        idleStrength: 0.025
        testPointer: true
        testPosition: Qt.point(440, 430)
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 170
        gradient: Gradient {
            GradientStop { position: 0; color: "#b0142230" }
            GradientStop { position: 1; color: "#00142230" }
        }
    }
    Column {
        anchors { left: parent.left; top: parent.top; margins: 42 }
        spacing: 7
        Text { text: "LIQUID GLASS TILES"; color: "#f7f6ed"; font.pixelSize: 38; font.weight: Font.DemiBold; font.letterSpacing: 2 }
        Text { text: "Frosted glass. Your wallpaper. KDE Plasma 6."; color: "#d9e6e4"; font.pixelSize: 17 }
    }
    Rectangle {
        x: glass.pointerX - 5
        y: glass.pointerY - 5
        width: 10
        height: 10
        radius: 5
        color: "white"
        border { width: 1; color: "#303c48" }
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 65
        color: "#df15232d"
        Text {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 42 }
            text: "Original visual concept: Gábor Molnár / DesignGabor  ·  Shared with permission"
            color: "#ecf1e9"
            font.pixelSize: 14
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 42 }
            text: "Linux implementation: veexiwang"
            color: "#b8cbc9"
            font.pixelSize: 12
        }
    }
}
