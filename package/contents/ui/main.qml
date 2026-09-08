import QtQuick
import org.kde.plasma.plasmoid

WallpaperItem {
    id: root
    Glass {
        id: glass
        anchors.fill: parent
        wallpaper: root.configuration.Image || Qt.resolvedUrl("../images/demo.svg")
        missingImageText: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Cannot read this image. Choose another wallpaper in settings.")
        chooseImageText: i18nd("plasma_wallpaper_io.github.veexiwang.liquidglasstiles", "Choose a local wallpaper in settings.")
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
