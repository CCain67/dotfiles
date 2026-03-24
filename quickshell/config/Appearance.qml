pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property QtObject rounding: QtObject {
        readonly property int small: 12
        readonly property int normal: 17
        readonly property int large: 25
        readonly property int full: 1000
    }

    readonly property QtObject spacing: QtObject {
        readonly property int small: 7
        readonly property int smaller: 10
        readonly property int normal: 12
        readonly property int larger: 15
        readonly property int large: 20
    }

    readonly property QtObject padding: QtObject {
        readonly property int small: 5
        readonly property int smaller: 7
        readonly property int normal: 10
        readonly property int larger: 12
        readonly property int large: 15
    }

    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string sans: "Rubik"
            readonly property string mono: "GeistMono Nerd Font"
            readonly property string material: "Material Symbols Rounded"
            readonly property string clock: "Rubik"
        }
        readonly property QtObject size: QtObject {
            readonly property int small: 11
            readonly property int smaller: 12
            readonly property int normal: 13
            readonly property int larger: 15
            readonly property int large: 18
            readonly property int extraLarge: 28
        }
    }

    readonly property QtObject anim: QtObject {
        readonly property QtObject curves: QtObject {
            readonly property list<real> emphasized: [0.05, 0, 2/15, 0.06, 1/6, 0.4, 5/24, 0.82, 0.25, 1, 1, 1]
            readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
            readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
            readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
            readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
            readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
            readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
            readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
            readonly property list<real> expressiveEffects: [0.34, 0.8, 0.34, 1, 1, 1]
        }
        readonly property QtObject durations: QtObject {
            readonly property int small: 200
            readonly property int normal: 400
            readonly property int large: 600
            readonly property int extraLarge: 1000
            readonly property int expressiveFastSpatial: 350
            readonly property int expressiveDefaultSpatial: 500
            readonly property int expressiveEffects: 200
        }
    }
}
