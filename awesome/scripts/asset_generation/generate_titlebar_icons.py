"""Generates the titlebar icons for the theme."""

import textwrap

from colors import COLOR_POOL, THEME_NAME

ICON_TO_COLOR = {
    "close": "red",
    "floating": "blue",
    "maximized": "green",
    "minimize": "orange",
    "ontop": "purple",
    "sticky": "foreground",
}
BRIGHTNESS_INCREASE = 0.2

ICON_PATH = "/home/chase/.config/awesome/theme/" + THEME_NAME + "/icons/titlebar/"


def hex_to_rgb(hex_color: str) -> tuple:
    """Helper function to convert hex to RGB"""
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def increase_brightness(rgb: tuple, percentage: float) -> tuple:
    """Increase the brightness of an RGB color by a percentage."""
    r, g, b = rgb
    r = min(int(r * (1 + percentage)), 255)
    g = min(int(g * (1 + percentage)), 255)
    b = min(int(b * (1 + percentage)), 255)
    return (r, g, b)


def rgb_to_hex(rgb: tuple) -> str:
    """Helper function to convert RGB to hex"""
    return "#{:02x}{:02x}{:02x}".format(*rgb)


def brighten_hex_color(hex_color: str, percentage: float) -> str:
    """Brighten a hex color by a percentage."""
    rgb = hex_to_rgb(hex_color)
    brightened_rgb = increase_brightness(rgb, percentage)
    return rgb_to_hex(brightened_rgb)


def create_svg_string(color: str) -> str:
    """Create an SVG string for a titlebar icon with the specified color."""
    svg_string = textwrap.dedent(
        f"""\
    <?xml version="1.0" encoding="utf-8"?>
    <!-- Generator: Adobe Illustrator 26.0.1, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
    <svg version="1.1"
        id="svg8" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:svg="http://www.w3.org/2000/svg"
        xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 240 240"
        style="enable-background:new 0 0 240 240;" xml:space="preserve">
    <style type="text/css">
        .st0{{fill:{color};}}
    </style>
    <sodipodi:namedview  bordercolor="#666666" borderopacity="1.0" id="base" inkscape:current-layer="layer1" inkscape:cx="201.37169" inkscape:cy="118.28466" inkscape:document-rotation="0" inkscape:document-units="mm" inkscape:pagecheckerboard="true" inkscape:pageopacity="0.0" inkscape:pageshadow="2" inkscape:window-height="740" inkscape:window-maximized="0" inkscape:window-width="1287" inkscape:window-x="45" inkscape:window-y="28" inkscape:zoom="1.0391556" pagecolor="#ffffff" showgrid="false" units="px">
        </sodipodi:namedview>
    <g id="layer1" inkscape:groupmode="layer" inkscape:label="Layer 1">
        <g id="g2168">
            <path id="path2170" class="st0" d="M103.9,69.9h32.2c18.8,0,34,15.2,34,34v32.2c0,18.8-15.2,34-34,34h-32.2c-18.8,0-34-15.2-34-34
                v-32.2C69.9,85.1,85.1,69.9,103.9,69.9z"/>
            <path id="path2172" class="st0" d="M54,20c-18.8,0-34,15.2-34,34v15.9V186c0,18.8,15.2,34,34,34h132c18.8,0,34-15.2,34-34V54
                c0-18.8-15.2-34-34-34H54z M119.8,119.8h0.3v0.3h-0.3V119.8z"/>
        </g>
    </g>
    </svg>
    """
    )
    return svg_string


# generate icons
if __name__ == "__main__":
    for icon_type in ["close", "minimize"]:
        for view in ["normal", "focus"]:
            for mouse in ["", "_hover"]:
                file_name = icon_type + "_" + view + mouse + ".svg"
                if mouse == "_hover":
                    color = brighten_hex_color(
                        COLOR_POOL[ICON_TO_COLOR[icon_type]], BRIGHTNESS_INCREASE
                    )
                else:
                    color = COLOR_POOL[ICON_TO_COLOR[icon_type]]
                svg_string = create_svg_string(color)
                with open(ICON_PATH + file_name, "w+") as file:
                    file.write(svg_string)
                print(f"Generated {file_name}")

    for icon_type in ["floating", "maximized", "ontop", "sticky"]:
        for view in ["normal", "focus"]:
            for state in ["active", "inactive"]:
                for mouse in ["", "_hover"]:
                    file_name = icon_type + "_" + view + "_" + state + mouse + ".svg"
                    if mouse == "_hover":
                        color = brighten_hex_color(
                            COLOR_POOL[ICON_TO_COLOR[icon_type]], BRIGHTNESS_INCREASE
                        )
                    else:
                        color = COLOR_POOL[ICON_TO_COLOR[icon_type]]
                    svg_string = create_svg_string(color)
                    with open(ICON_PATH + file_name, "w+") as file:
                        file.write(svg_string)
                    print(f"Generated {file_name}")
