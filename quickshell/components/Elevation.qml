import QtQuick
import QtQuick.Effects
import "../services"
import "../config"

// Shared drop shadow for every raised surface in the shell.
//
// Used as `layer.effect: Elevation { level: "medium" }`. The three levels are
// the ladder the eight shadow sites already formed by hand; centralising them
// means a flat theme kills every shadow from one binding rather than eight.
//
// Sites must also bind `layer.enabled: !Theme.flat` — an enabled layer with
// shadowEnabled false still costs an offscreen FBO per item for nothing.
MultiEffect {
    id: root

    // "low" | "medium" | "high"
    property string level: "medium"

    shadowEnabled: !Theme.flat
    blurMax: level === "low" ? Appearance.shadows.low
        : level === "high" ? Appearance.shadows.high
        : Appearance.shadows.medium
    shadowVerticalOffset: level === "low" ? 1 : level === "high" ? 4 : 2
    shadowColor: Qt.alpha(Colors.palette.m3shadow, level === "low" ? Appearance.shadows.alphaLow : Appearance.shadows.alpha)
}
