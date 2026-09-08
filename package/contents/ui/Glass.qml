pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: glass
    clip: true
    property url wallpaper: ""
    property string missingImageText: "Cannot read this image. Choose another wallpaper in settings."
    property string chooseImageText: "Choose a local wallpaper in settings."
    readonly property bool localImage: wallpaper.toString().startsWith("file://") || wallpaper.toString().startsWith("/")
    property real glassOpacity: 1.0
    property real tileSize: 112
    property real influenceRadius: 310
    property real refraction: 0.65
    property real frost: 0.6
    property real idleStrength: 0.06
    property real followDuration: 0
    property bool motionEnabled: true
    // Used only by the deterministic preview capture, never by the wallpaper.
    property bool testPointer: false
    property point testPosition: Qt.point(width * 0.5, height * 0.5)
    readonly property bool imageFailed: backdrop.status === Image.Error
    readonly property bool imageReady: backdrop.status === Image.Ready
    readonly property point hoverPosition: hover.parent ? glass.mapFromItem(hover.parent, hover.point.position.x, hover.point.position.y) : Qt.point(0, 0)
    property real pointerX: testPointer ? testPosition.x : (hover.hovered ? hoverPosition.x : width / 2)
    property real pointerY: testPointer ? testPosition.y : (hover.hovered ? hoverPosition.y : height / 2)
    property real presence: (testPointer || hover.hovered) && motionEnabled ? 1 : 0
    Behavior on pointerX { enabled: glass.followDuration > 0; SmoothedAnimation { duration: glass.followDuration; velocity: -1 } }
    Behavior on pointerY { enabled: glass.followDuration > 0; SmoothedAnimation { duration: glass.followDuration; velocity: -1 } }
    Behavior on presence { NumberAnimation { duration: 420; easing.type: Easing.InOutQuad } }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#384859" }
            GradientStop { position: 0.5; color: "#758984" }
            GradientStop { position: 1; color: "#c2b79c" }
        }
    }
    Image {
        id: backdrop
        anchors.fill: parent
        source: glass.localImage ? glass.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        autoTransform: true
        sourceSize.width: Math.min(4096, Math.max(1, glass.width * Screen.devicePixelRatio))
        sourceSize.height: Math.min(4096, Math.max(1, glass.height * Screen.devicePixelRatio))
    }
    ShaderEffectSource {
        id: sharpTexture
        sourceItem: backdrop
        hideSource: true
        visible: false
        live: true
    }
    ShaderEffect {
        id: horizontalBlur
        width: glass.width
        height: glass.height
        visible: false
        property variant source: sharpTexture
        property vector2d resolution: Qt.vector2d(width, height)
        property vector2d direction: Qt.vector2d(1, 0)
        property real blurRadius: Math.pow(Math.max(0, Math.min(1, glass.frost)), 0.65) * 60
        fragmentShader: Qt.resolvedUrl("../shaders/blur.frag.qsb")
    }
    ShaderEffectSource {
        id: horizontalTexture
        sourceItem: horizontalBlur
        visible: false
        live: true
        textureSize: Qt.size(Math.max(1, Math.ceil(glass.width / 2)), Math.max(1, Math.ceil(glass.height / 2)))
    }
    ShaderEffect {
        id: verticalBlur
        width: glass.width
        height: glass.height
        visible: false
        property variant source: horizontalTexture
        property vector2d resolution: Qt.vector2d(width, height)
        property vector2d direction: Qt.vector2d(0, 1)
        property real blurRadius: horizontalBlur.blurRadius
        fragmentShader: Qt.resolvedUrl("../shaders/blur.frag.qsb")
    }
    ShaderEffectSource {
        id: frostedTexture
        sourceItem: verticalBlur
        visible: false
        live: true
        textureSize: horizontalTexture.textureSize
    }
    ShaderEffect {
        anchors.fill: parent
        visible: glass.imageReady
        property variant source: sharpTexture
        property variant blurredSource: frostedTexture
        property vector2d resolution: Qt.vector2d(glass.width, glass.height)
        property vector2d pointer: Qt.vector2d(glass.pointerX, glass.pointerY)
        property real tileSize: Math.max(40, Math.min(240, glass.tileSize))
        property real influenceRadius: Math.max(80, Math.min(700, glass.influenceRadius))
        property real glassOpacity: Math.max(0, Math.min(1, glass.glassOpacity))
        property real refraction: Math.max(0, Math.min(1, glass.refraction))
        property real frost: Math.max(0, Math.min(1, glass.frost))
        property real idleStrength: Math.max(0, Math.min(1, glass.idleStrength))
        property real presence: glass.presence
        fragmentShader: Qt.resolvedUrl("../shaders/glass.frag.qsb")
    }
    Item {
        id: mouseSurface
        // Observe before Plasma's event-listener overlay. No visual content,
        // button handler or exclusive grab: desktop interaction stays below.
        parent: glass.Window.window ? glass.Window.window.contentItem : glass
        anchors.fill: parent
        z: 1000000
        HoverHandler {
            id: hover
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            blocking: false
        }
    }
    Text {
        anchors.centerIn: parent
        visible: glass.imageFailed || !glass.localImage
        text: glass.imageFailed ? glass.missingImageText : glass.chooseImageText
        color: "white"
        style: Text.Outline
        styleColor: "#333333"
    }
}
