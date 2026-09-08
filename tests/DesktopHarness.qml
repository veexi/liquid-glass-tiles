import QtQuick
import QtQuick.Controls
import "../package/contents/ui"

ApplicationWindow {
    width: 1280
    height: 800
    visible: true
    Glass {
        objectName: "glass"
        anchors.fill: parent
        wallpaper: initialWallpaper
    }
    // Plasma FolderView has a full-size hover-enabled MouseArea above wallpaper.
    MouseArea {
        objectName: "desktopOverlay"
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property int leftClicks: 0
        property int rightClicks: 0
        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) leftClicks++;
            if (mouse.button === Qt.RightButton) rightClicks++;
        }
    }
}
