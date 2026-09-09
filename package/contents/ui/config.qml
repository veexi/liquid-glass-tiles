import QtQuick
import "Playlist.js" as Playlist
import "Translations.js" as Translations
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    function tr(message) {
        return Translations.text(message, root.cfg_Language, Qt.locale().uiLanguages);
    }
    property alias cfg_SlideshowEnabled: slideshowEnabled.checked
    property string cfg_SlideshowImages: "[]"
    property alias cfg_SlideInterval: intervalControl.value
    property alias cfg_RandomOrder: randomControl.checked
    readonly property var selectedImages: Playlist.parse(cfg_SlideshowImages)
    property string cfg_Language: "system"
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
    ComboBox {
        id: languageControl
        objectName: "languageControl"
        Kirigami.FormData.label: root.tr("Language:")
        model: [root.tr("Follow system"), "简体中文", "English"]
        readonly property var languageCodes: ["system", "zh_CN", "en"]
        currentIndex: Math.max(0, languageCodes.indexOf(root.cfg_Language))
        onActivated: root.cfg_Language = languageCodes[currentIndex]
    }
    RowLayout {
        Kirigami.FormData.label: root.tr("Wallpaper image:")
        TextField { id: imagePath; Layout.preferredWidth: 240; placeholderText: root.tr("Built-in demo, or choose a local image") }
        Button { text: root.tr("Choose…"); onClicked: picker.open() }
        Button { text: root.tr("Use demo"); onClicked: imagePath.text = "" }
    }
    CheckBox {
        id: slideshowEnabled
        Kirigami.FormData.label: root.tr("Slideshow:")
        text: root.tr("Enabled")
    }
    RowLayout {
        visible: slideshowEnabled.checked
        Button { text: root.tr("Add images…"); onClicked: slidesPicker.open() }
        Button { text: root.tr("Clear list"); enabled: root.selectedImages.length > 0; onClicked: root.cfg_SlideshowImages = "[]" }
        Label { text: root.tr("Selected images:") + " " + root.selectedImages.length }
    }
    ColumnLayout {
        visible: slideshowEnabled.checked
        Layout.maximumWidth: 500
        Repeater {
            model: root.selectedImages
            delegate: RowLayout {
                required property string modelData
                required property int index
                Label {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 350
                    text: decodeURIComponent(modelData.substring(modelData.lastIndexOf("/") + 1))
                    elide: Text.ElideMiddle
                }
                Button {
                    text: root.tr("Remove")
                    onClicked: {
                        var images = root.selectedImages.slice();
                        images.splice(index, 1);
                        root.cfg_SlideshowImages = JSON.stringify(images);
                    }
                }
            }
        }
    }
    SpinBox {
        id: intervalControl
        visible: slideshowEnabled.checked
        Kirigami.FormData.label: root.tr("Switch interval (seconds):")
        from: 1; to: 86400; value: 300; editable: true
    }
    CheckBox {
        id: randomControl
        visible: slideshowEnabled.checked
        Kirigami.FormData.label: root.tr("Playback order:")
        text: root.tr("Random (otherwise list order)")
    }
    Label {
        visible: slideshowEnabled.checked
        text: root.tr("Mix static image formats. Unreadable images are skipped. An empty list uses the single wallpaper.")
        wrapMode: Text.WordWrap
        Layout.maximumWidth: 440
    }
    SpinBox { id: opacityControl; Kirigami.FormData.label: root.tr("Glass opacity (0 = transparent):"); from: 0; to: 100; editable: true }
    SpinBox { id: sizeControl; Kirigami.FormData.label: root.tr("Tile size (px):"); from: 40; to: 240; editable: true }
    SpinBox { id: radiusControl; Kirigami.FormData.label: root.tr("Mouse radius (px):"); from: 80; to: 700; editable: true }
    SpinBox { id: refractionControl; Kirigami.FormData.label: root.tr("Refraction strength:"); from: 0; to: 100; editable: true }
    SpinBox { id: frostControl; Kirigami.FormData.label: root.tr("Frost strength:"); from: 0; to: 100; editable: true }
    SpinBox { id: idleControl; Kirigami.FormData.label: root.tr("Glass away from cursor:"); from: 0; to: 100; editable: true }
    SpinBox { id: followControl; Kirigami.FormData.label: root.tr("Follow delay (ms, 0 = immediate):"); from: 0; to: 600; editable: true }
    CheckBox { id: motionControl; Kirigami.FormData.label: root.tr("Mouse interaction:"); text: root.tr("Enabled") }
    Label { text: root.tr("The glass stays at the last position when the pointer leaves the desktop. Zero opacity restores the original image."); wrapMode: Text.WordWrap; Layout.maximumWidth: 440 }
    Kirigami.Separator { Kirigami.FormData.isSection: true }
    Label { Kirigami.FormData.label: root.tr("Original visual concept"); text: "Gábor Molnár / DesignGabor"; font.bold: true }
    Label { text: root.tr("Shared with the original designer's permission.") }
    Label {
        text: "<a href=\"https://avely.me/designgabor\">" + root.tr("Portfolio") + "</a> · <a href=\"https://x.com/DesignGabor\">X / DesignGabor</a> · <a href=\"https://my.spline.design/glassmorphcursortracking-2ef6d3790000fd1a4f81c92fb3ff5bf5/\">" + root.tr("Original work") + "</a>"
        textFormat: Text.StyledText
        onLinkActivated: function(link) { Qt.openUrlExternally(link); }
    }
    FileDialog {
        id: slidesPicker
        title: root.tr("Add slideshow images")
        fileMode: FileDialog.OpenFiles
        nameFilters: [root.tr("Images (*.png *.jpg *.jpeg *.webp *.bmp *.svg)"), root.tr("All files (*)")]
        onAccepted: {
            var images = root.selectedImages.slice();
            for (var i = 0; i < selectedFiles.length; ++i) {
                var url = selectedFiles[i].toString();
                if (images.indexOf(url) < 0) images.push(url);
            }
            root.cfg_SlideshowImages = JSON.stringify(images);
        }
    }
    FileDialog {
        id: picker
        title: root.tr("Choose wallpaper")
        nameFilters: [root.tr("Images (*.png *.jpg *.jpeg *.webp *.bmp *.svg)"), root.tr("All files (*)")]
        onAccepted: imagePath.text = selectedFile.toString()
    }
}
