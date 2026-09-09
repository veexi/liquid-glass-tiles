import QtQuick

Item {
    id: root
    property url source
    property size sourceSize
    property int duration: 500
    property int activeIndex: -1
    property int pendingIndex: 0
    property real blend: 0
    readonly property var activeImage: activeIndex === 0 ? first : second
    readonly property var pendingImage: pendingIndex === 0 ? first : second
    readonly property int status: pendingImage.status
    readonly property bool transitioning: fade.running

    function request() {
        if (fade.running) {
            fade.stop();
            commit();
        }
        pendingIndex = activeIndex === 0 ? 1 : 0;
        blend = 0;
        pendingImage.source = source;
        ready();
    }
    function ready() {
        if (pendingImage.status !== Image.Ready) return;
        if (activeIndex < 0 || duration === 0) commit();
        else if (!fade.running) fade.start();
    }
    function commit() {
        activeIndex = pendingIndex;
        blend = 1;
        // Release the old texture once it is no longer visible.
        var oldImage = activeIndex === 0 ? second : first;
        oldImage.source = "";
    }
    onSourceChanged: request()
    Image {
        id: first
        anchors.fill: parent
        asynchronous: true
        autoTransform: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: root.sourceSize
        z: root.pendingIndex === 0 ? 1 : 0
        opacity: root.activeIndex === 0 ? 1 : (root.pendingIndex === 0 ? root.blend : 0)
        onStatusChanged: { if (root.pendingIndex === 0) root.ready(); }
    }
    Image {
        id: second
        anchors.fill: parent
        asynchronous: true
        autoTransform: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: root.sourceSize
        z: root.pendingIndex === 1 ? 1 : 0
        opacity: root.activeIndex === 1 ? 1 : (root.pendingIndex === 1 ? root.blend : 0)
        onStatusChanged: { if (root.pendingIndex === 1) root.ready(); }
    }
    NumberAnimation {
        id: fade
        target: root
        property: "blend"
        from: 0; to: 1
        duration: root.duration
        easing.type: Easing.InOutQuad
        onFinished: root.commit()
    }
}
