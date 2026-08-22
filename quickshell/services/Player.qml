pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Active MPRIS player. Prefers whichever player is actually playing, falling
// back to the first one that exists.
Singleton {
    id: root

    readonly property MprisPlayer active: {
        const all = Mpris.players.values;
        if (!all.length)
            return null;
        return all.find(p => p.isPlaying) ?? all[0];
    }

    readonly property bool hasPlayer: !!active
    readonly property bool isPlaying: active?.isPlaying ?? false
    readonly property string title: active?.trackTitle || "Nothing playing"
    readonly property string artist: active?.trackArtist || ""
    readonly property string album: active?.trackAlbum || ""
    readonly property string artUrl: active?.trackArtUrl || ""
    readonly property string identity: active?.identity || ""

    readonly property bool canSeek: active?.canSeek ?? false
    readonly property bool canGoNext: active?.canGoNext ?? false
    readonly property bool canGoPrevious: active?.canGoPrevious ?? false

    readonly property real length: (active?.lengthSupported ? active.length : 0) || 0

    // `position` only changes when the player reports it, so poll while playing
    // to keep the progress bar moving.
    property real position: 0
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0

    function formatTime(seconds: real): string {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00";
        const total = Math.floor(seconds);
        const mins = Math.floor(total / 60);
        const secs = total % 60;
        return `${mins}:${secs.toString().padStart(2, "0")}`;
    }

    function seekFraction(fraction: real): void {
        if (active && canSeek && length > 0)
            active.position = Math.max(0, Math.min(1, fraction)) * length;
    }

    function togglePlaying(): void {
        active?.togglePlaying();
    }

    function next(): void {
        if (canGoNext)
            active.next();
    }

    function previous(): void {
        if (canGoPrevious)
            active.previous();
    }

    function _sync(): void {
        root.position = (root.active?.positionSupported ? root.active.position : 0) || 0;
    }

    onActiveChanged: _sync()

    Timer {
        interval: 500
        running: root.isPlaying
        repeat: true
        onTriggered: root._sync()
    }
}
