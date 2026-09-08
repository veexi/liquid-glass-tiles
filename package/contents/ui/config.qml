import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    property var configDialog
    property var wallpaperConfiguration
    twinFormLayouts: parentLayout
    property alias formLayout: root
    property alias cfg_Image: imagePath.text
    property alias cfg_GlassOpacity: opacityControl.value
    property alias cfg_TileSize: sizeControl.value
    property alias cfg_InfluenceRadius: radiusControl.value
    property alias cfg_Refraction: refractionControl.value
    property alias cfg_Frost: frostControl.value
    property alias cfg_IdleStrength: idleControl.value
    property alias cfg_FollowDuration: followControl.value
    property alias cfg_MotionEnabled: motionControl.checked
    RowLayout {
        Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Wallpaper image:")
        TextField { id: imagePath; Layout.preferredWidth: 240; placeholderText: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Built-in demo, or choose a local image") }
        Button { text: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Choose…"); onClicked: picker.open() }
        Button { text: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Use demo"); onClicked: imagePath.text = "" }
    }
    SpinBox { id: opacityControl; Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Glass opacity (0 = transparent):"); from: 0; to: 100; editable: true }
    SpinBox { id: sizeControl; Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Tile size (px):"); from: 40; to: 240; editable: true }
    SpinBox { id: radiusControl; Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Mouse radius (px):"); from: 80; to: 700; editable: true }
    SpinBox { id: refractionControl; Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Refraction strength:"); from: 0; to: 100; editable: true }
    SpinBox { id: frostControl; Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Frost strength:"); from: 0; to: 100; editable: true }
    SpinBox { id: idleControl; Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Glass away from cursor:"); from: 0; to: 100; editable: true }
    SpinBox { id: followControl; Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Follow delay (ms, 0 = immediate):"); from: 0; to: 600; editable: true }
    CheckBox { id: motionControl; Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Mouse interaction:"); text: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Enabled") }
    Label { text: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "The effect fades when the pointer leaves the desktop. Zero opacity restores the original image."); wrapMode: Text.WordWrap; Layout.maximumWidth: 440 }
    Kirigami.Separator { Kirigami.FormData.isSection: true }
    Label { Kirigami.FormData.label: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Original visual concept"); text: "Gábor Molnár / DesignGabor"; font.bold: true }
    Label { text: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Shared with the original designer's permission.") }
    Label {
        text: "<a href=\"https://avely.me/designgabor\">" + i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Portfolio") + "</a> · <a href=\"https://x.com/DesignGabor\">X / DesignGabor</a> · <a href=\"https://my.spline.design/glassmorphcursortracking-2ef6d3790000fd1a4f81c92fb3ff5bf5/\">" + i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Original work") + "</a>"
        textFormat: Text.StyledText
        onLinkActivated: function(link) { Qt.openUrlExternally(link); }
    }
    FileDialog {
        id: picker
        title: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Choose wallpaper")
        nameFilters: [i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Images (*.png *.jpg *.jpeg *.webp *.bmp *.svg)")]
        onAccepted: imagePath.text = selectedFile.toString()
    }
}
