import QtQuick
import QtQuick.Shapes
import "../../config"
import "../osd" as Osd

// Full-window Shape overlay that renders custom panel backgrounds.
// Uses CurveRenderer for smooth anti-aliased arcs.
Shape {
    id: root

    required property Item panels
    required property Item bar
    required property Item osd  // Osd.Wrapper

    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    Osd.Background {
        osd: root.osd

        startX: root.width
        startY: (root.height - osd.contentHeight) / 2 - rounding
    }
}
