import QtQuick
import "Playlist.js" as Playlist
import "Translations.js" as Translations
import org.kde.plasma.plasmoid

WallpaperItem {
    id: root
    function tr(message) {
        return Translations.text(message, (root.configuration.Language || "system"), Qt.locale().uiLanguages);
    }
    Slideshow {
        id: slideshow
        enabled: root.configuration.SlideshowEnabled || false
        images: root.configuration.SlideshowImages || "[]"
        intervalSeconds: root.configuration.SlideInterval || 300
        randomOrder: root.configuration.RandomOrder || false
        fallback: Playlist.localUrl(root.configuration.Image) || Qt.resolvedUrl("../images/demo.svg")
    }
    Glass {
        id: glass
        anchors.fill: parent
        wallpaper: slideshow.currentSource
        missingImageText: root.tr("Cannot read this image. Choose another wallpaper in settings.")
        chooseImageText: root.tr("Choose a local wallpaper in settings.")
        glassOpacity: root.configuration.GlassOpacity / 100
        tileSize: root.configuration.TileSize
        influenceRadius: root.configuration.InfluenceRadius
        refraction: root.configuration.Refraction / 100
        frost: root.configuration.Frost / 100
        idleStrength: root.configuration.IdleStrength / 100
        followDuration: root.configuration.FollowDuration
        motionEnabled: root.configuration.MotionEnabled
    }
}
