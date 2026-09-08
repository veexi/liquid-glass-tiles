import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../package/contents/ui"

ApplicationWindow {
    id: window
    width: 1280
    height: 800
    visible: true
    title: "Liquid Glass Tiles — preview"
    Glass {
        id: glass
        objectName: "glass"
        anchors.fill: parent
        wallpaper: initialWallpaper
        glassOpacity: opacitySlider.value
        tileSize: sizeSlider.value
        influenceRadius: radiusSlider.value
        refraction: bendSlider.value
        frost: frostSlider.value
        idleStrength: idleSlider.value
    }
    Rectangle {
        id: panel
        objectName: "panel"
        visible: !captureMode
        anchors { right: parent.right; top: parent.top; margins: 24 }
        width: 310
        height: settings.implicitHeight + 40
        radius: 20
        color: "#f0182124"
        border.color: "#40555b"
        ColumnLayout {
            id: settings
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 20 }
            spacing: 8
            Label { text: "Liquid Glass Tiles"; font.pixelSize: 23; font.bold: true; color: "#f3f6ee" }
            Label { text: "Move your mouse across the wallpaper."; color: "#a8b8b8" }
            Button { text: "Choose image…"; Layout.fillWidth: true; onClicked: picker.open() }
            Label { text: "Glass opacity"; color: "#edf3ef" }
            Slider { id: opacitySlider; from: 0; to: 1; value: 1; Layout.fillWidth: true }
            Label { text: "Tile size"; color: "#edf3ef" }
            Slider { id: sizeSlider; from: 40; to: 240; value: 112; Layout.fillWidth: true }
            Label { text: "Mouse radius"; color: "#edf3ef" }
            Slider { id: radiusSlider; from: 80; to: 700; value: 310; Layout.fillWidth: true }
            Label { text: "Refraction"; color: "#edf3ef" }
            Slider { id: bendSlider; from: 0; to: 1; value: 0.65; Layout.fillWidth: true }
            Label { text: "Frost"; color: "#edf3ef" }
            Slider { id: frostSlider; from: 0; to: 1; value: 0.6; Layout.fillWidth: true }
            Label { text: "Glass away from cursor"; color: "#edf3ef" }
            Slider { id: idleSlider; from: 0; to: 1; value: 0.06; Layout.fillWidth: true }
            Label {
                text: "Original visual concept: Gábor Molnár\nDesignGabor · Shared with permission"
                color: "#d5dfd8"
                font.pixelSize: 11
            }
            Label { text: "F11 full screen · Tab settings · Esc quit"; color: "#a8b8b8"; font.pixelSize: 11 }
        }
    }
    FileDialog {
        id: picker
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp *.svg)"]
        onAccepted: glass.wallpaper = selectedFile
    }
    Shortcut { sequence: "F11"; onActivated: window.visibility = window.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen }
    Shortcut { sequence: "Tab"; onActivated: panel.visible = !panel.visible }
    Shortcut { sequence: "Escape"; onActivated: Qt.quit() }
}
