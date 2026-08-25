import "../services"
import "../config"

StyledText {
    property real fill
    // Material's grade axis compensates for the optical weight shift between
    // light and dark backgrounds: -25 thins glyphs so they don't bloom on a dark
    // ground, 0 keeps them full weight on a light one. Now that light themes
    // ship this has to follow the theme — on paperwhite's #ebdbb2 a fixed -25
    // visibly under-inks every glyph.
    readonly property int grade: Colors.light ? 0 : -25

    font.family: Appearance.font.family.material
    font.pointSize: Appearance.font.size.larger
    font.variableAxes: ({
        FILL: fill.toFixed(1),
        GRAD: grade,
        opsz: fontInfo.pixelSize,
        wght: fontInfo.weight
    })
}
