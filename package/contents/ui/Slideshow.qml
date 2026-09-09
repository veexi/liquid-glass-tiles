import QtQuick
import "Playlist.js" as Playlist

Item {
    id: root
    visible: false
    property bool enabled: false
    property string images: "[]"
    property int intervalSeconds: 300
    property bool randomOrder: false
    property url fallback: ""
    property url currentSource: fallback
    readonly property var entries: Playlist.parse(images)
    property int index: -1
    property int attempts: 0
    property bool initialized: false
    readonly property bool loading: probe.status === Image.Loading

    function reset() {
        if (!initialized) return;
        clock.stop();
        retry.stop();
        probe.source = "";
        index = -1;
        attempts = 0;
        currentSource = fallback;
        if (enabled && entries.length) load(0);
    }
    function load(candidate) {
        index = candidate;
        // Clearing allows a one-image list to be retried after a file changes.
        probe.source = "";
        probe.source = entries[index];
    }
    function advance() {
        if (!enabled || entries.length < 2) return;
        attempts = 0;
        var step = randomOrder ? 1 + Math.floor(Math.random() * (entries.length - 1)) : 1;
        load((index + step) % entries.length);
    }
    function loaded() {
        if (probe.status === Image.Ready) {
            currentSource = probe.source;
            attempts = 0;
            if (enabled && entries.length > 1) clock.restart();
        } else if (probe.status === Image.Error) {
            attempts += 1;
            if (attempts < entries.length) {
                // Do not recurse through synchronous image errors.
                retry.restart();
            }
            // If every image fails, keep the last image and stop until settings change.
        }
    }
    onEnabledChanged: reset()
    onEntriesChanged: reset()
    onFallbackChanged: reset()
    onIntervalSecondsChanged: { if (clock.running) clock.restart(); }
    Component.onCompleted: { initialized = true; reset(); }
    Image {
        id: probe
        visible: false
        asynchronous: true
        autoTransform: true
        sourceSize: Qt.size(4096, 4096)
        onStatusChanged: root.loaded()
    }
    Timer {
        id: retry
        interval: 1
        onTriggered: { if (root.enabled && root.entries.length) root.load((root.index + 1) % root.entries.length); }
    }
    Timer {
        id: clock
        interval: Math.max(1, Math.min(86400, root.intervalSeconds)) * 1000
        onTriggered: root.advance()
    }
}
