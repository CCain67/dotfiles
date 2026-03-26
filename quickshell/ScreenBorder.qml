import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    // Full-screen, below windows, above wallpaper
    anchors { left: true; right: true; top: true; bottom: true }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom
    color: "transparent"

    readonly property int barWidth: 8       // bar exclusive zone
    readonly property int leftThickness: 0  // left gap, tune to match other sides visually
    readonly property int thickness: 12   // top, right, bottom
    readonly property int rounding: 12

    // Full-screen colored rect, masked to show only the border frame
    Rectangle {
        anchors.fill: parent
        color: "#252423"

        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource: maskShape
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    // The mask defines the inner workspace area — everything outside becomes the border
    Item {
        id: maskShape
        anchors.fill: parent
        anchors.leftMargin: root.bar.implicitWidth
        layer.enabled: true
        visible: false

        Rectangle {
            x: root.barWidth + root.leftThickness
            y: root.thickness
            width: parent.width - root.barWidth - root.leftThickness - root.thickness
            height: parent.height - root.thickness * 2
            radius: root.rounding
        }
    }
}
