import QtQuick
import QtQuick.Shapes
import "../../components"
import "../../config"
import "../../services"

// ShapePath for the launcher panel background.
// Mirrors osd/Background.qml but grows rightward from the bar (left) edge:
//   - top-left and bottom-left corners are concave (attach to bar)
//   - top-right corner is 90° (flush against top screen border)
//   - bottom-right corner is convex (normal rounded far corner)
// Must be a child of a Shape item covering the full window.
ShapePath {
    id: root

    required property Item launcher  // Launcher.Wrapper

    readonly property real rounding: Config.border.rounding
    readonly property real panelWidth: launcher.implicitWidth
    readonly property real panelHeight: launcher.contentHeight

    // Flatten radii when the panel is very narrow (e.g. early in slide-out animation)
    readonly property bool flatten: panelWidth < rounding * 2
    readonly property real rx: flatten ? panelWidth / 2 : rounding

    // startX/startY are set by the parent Shape (Backgrounds.qml)
    // startX = bar.implicitWidth (left panel edge), startY = border.thickness - rounding

    strokeWidth: -1
    fillColor: Colors.palette.m3surface

    Behavior on fillColor { CAnim {} }

    // 1. Concave top-left corner (panel meets bar at top)
    PathArc {
        relativeX: root.rx
        relativeY: root.rounding
        radiusX: Math.min(root.rounding, root.panelWidth)
        radiusY: root.rounding
        direction: PathArc.Counterclockwise
    }
    // 2. Top edge (right across the top of the panel, flush to top screen border — no corner rounding)
    PathLine {
        relativeX: root.panelWidth - root.rx
        relativeY: 0
    }
    // 3. Right edge (down the far side of the panel — top-right corner is 90°)
    PathLine {
        relativeX: 0
        relativeY: Math.max(0, root.panelHeight - root.rounding)
    }
    // 5. Convex bottom-right corner
    PathArc {
        relativeX: -root.rx
        relativeY: root.rounding
        radiusX: Math.min(root.rounding, root.panelWidth)
        radiusY: root.rounding
        // default clockwise → convex at far edge
    }
    // 6. Bottom edge (left back toward the bar)
    PathLine {
        relativeX: -(root.panelWidth - root.rx * 2)
        relativeY: 0
    }
    // 7. Concave bottom-left corner (panel meets bar at bottom)
    PathArc {
        relativeX: -root.rx
        relativeY: root.rounding
        radiusX: Math.min(root.rounding, root.panelWidth)
        radiusY: root.rounding
        direction: PathArc.Counterclockwise
    }
}
