import QtQuick
import QtQuick.Shapes
import "../../config"
import "../launcher" as Launcher

// Full-window Shape overlay that renders custom panel backgrounds.
// Uses CurveRenderer for smooth anti-aliased arcs.
Shape {
    id: root

    required property Item panels
    required property Item bar
    required property Item launcher  // Launcher.Wrapper

    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    Launcher.Background {
        launcher: root.launcher

        startX: root.bar.implicitWidth
        startY: Config.border.thickness - rounding
    }
}
