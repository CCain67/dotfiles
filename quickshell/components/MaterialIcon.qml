import "../services"
import "../config"

StyledText {
    property real fill
    // Colors.light is hardcoded false → grade is always -25
    readonly property int grade: -25

    font.family: Appearance.font.family.material
    font.pointSize: Appearance.font.size.larger
    font.variableAxes: ({
        FILL: fill.toFixed(1),
        GRAD: grade,
        opsz: fontInfo.pixelSize,
        wght: fontInfo.weight
    })
}
