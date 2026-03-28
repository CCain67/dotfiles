import QtQuick
import QtQuick.Shapes
import "../../components"
import "../../config"
import "../../services"

// ShapePath for the OSD panel background.
// Draws a rounded rect that "grows" out of the right screen border:
//   - top-right and bottom-right corners are concave (attach to border)
//   - top-left and bottom-left corners are convex (normal rounded far corners)
// Must be a child of a Shape item covering the full window.
ShapePath {
    id: root

    required property Item osd  // Osd.Wrapper

    readonly property real rounding: Config.border.rounding
    readonly property real panelWidth: osd.implicitWidth
    readonly property real panelHeight: osd.contentHeight

    // Flatten radii when the panel is very narrow (e.g. early in slide-in animation)
    readonly property bool flatten: panelWidth < rounding * 2
    readonly property real rx: flatten ? panelWidth / 2 : rounding

    // startX/startY are set by the parent Shape (Backgrounds.qml)
    // startX = parent.width (right edge), startY = vertical midpoint minus half panel height minus rounding

    strokeWidth: -1
    fillColor: Colors.palette.m3surface

    Behavior on fillColor { CAnim {} }

    // 1. Concave top-right corner (panel meets border at top)
    PathArc {
        relativeX: -root.rx
        relativeY: root.rounding
        radiusX: Math.min(root.rounding, root.panelWidth)
        radiusY: root.rounding
        // default clockwise → concave at attachment edge
    }
    // 2. Top edge (left across the top of the panel)
    PathLine {
        relativeX: -(root.panelWidth - root.rx * 2)
        relativeY: 0
    }
    // 3. Concave top-left corner
    PathArc {
        relativeX: -root.rx
        relativeY: root.rounding
        radiusX: Math.min(root.rounding, root.panelWidth)
        radiusY: root.rounding
        direction: PathArc.Counterclockwise
    }
    // 4. Left edge (down the far side of the panel)
    PathLine {
        relativeX: 0
        relativeY: root.panelHeight - root.rounding * 2
    }
    // 5. Convex bottom-left corner
    PathArc {
        relativeX: root.rx
        relativeY: root.rounding
        radiusX: Math.min(root.rounding, root.panelWidth)
        radiusY: root.rounding
        direction: PathArc.Counterclockwise
    }
    // 6. Bottom edge (right back toward the border)
    PathLine {
        relativeX: root.panelWidth - root.rx * 2
        relativeY: 0
    }
    // 7. Convex bottom-right corner (panel meets border at bottom)
    PathArc {
        relativeX: root.rx
        relativeY: root.rounding
        radiusX: Math.min(root.rounding, root.panelWidth)
        radiusY: root.rounding
        // default clockwise → convex at attachment edge
    }
}
