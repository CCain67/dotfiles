pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../config"

// Default audio sink volume/mute. PwObjectTracker is required — without it the
// node's `audio` block is never bound and volume reads back as 0.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink?.ready ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    readonly property string icon: {
        if (muted || volume <= 0)
            return "volume_off";
        if (volume < 0.5)
            return "volume_down";
        return "volume_up";
    }

    function setVolume(value: real): void {
        if (!sink?.audio)
            return;
        sink.audio.volume = Math.max(0, Math.min(Config.services.maxVolume, value));
    }

    function increase(): void {
        setVolume(volume + Config.services.audioIncrement);
    }

    function decrease(): void {
        setVolume(volume - Config.services.audioIncrement);
    }

    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    PwObjectTracker {
        objects: [root.sink]
    }
}
