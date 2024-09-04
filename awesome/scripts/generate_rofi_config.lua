local theme = require("beautiful").get()
local naughty = require("naughty")

local config_string = [[
configuration {
    modi: "drun";
    font: "VictorMono Nerd Font Bold 11";
    lines: 10;
    width: 2;
    columns: 1;
    display-drun: " ";
    eh: 1;
    location: 0;
    yoffset: 0;
    xoffset: 0;
    scrollbar: true;
}
textbox-prompt-colon {
    margin:     0;
    expand:     false;
    str:        " ";
    text-color: inherit;
}
entry {
    text-color:        var(normal-foreground);
    cursor:            text;
    spacing:           0;
    placeholder-color: ]] .. theme.system_black_light .. [[;
    placeholder:       "Type to filter";
}
scrollbar {
    width:        4px;
    padding:      0;
    handle-width: 8px;
    border:       0;
    handle-color: ]] .. theme.green .. [[;
}
window {
    background: @background;
    padding: 18px;
    width: 40%;
    children: [mainbox];
}
mainbox {
    padding:      5px;
    border:       0px;
    spacing:      0px;
    orientation:  vertical;
}
num-filtered-rows {
    expand:     false;
    text-color: ]] .. theme.system_black_light .. [[;
}
num-rows {
    expand:     false;
    text-color: ]] .. theme.system_black_light .. [[;
}
textbox-num-sep {
    expand:     false;
    str:        "   ";
    text-color: ]] .. theme.system_black_light .. [[;
}
* {
    background:                  ]] .. theme.bg_normal .. [[;
    background-color:            @background;
    foreground:                  ]] .. theme.fg_normal .. [[;
    border-color:                @background;
    separatorcolor:              @border-color;

    normal-background:           @background;
    normal-foreground:           @foreground;
    alternate-normal-background: @background;
    alternate-normal-foreground: @foreground;
    selected-normal-background:  @background;
    selected-normal-foreground:  ]] .. theme.green .. [[;

    active-background:           @background;
    active-foreground:           ]] .. theme.yellow .. [[;
    alternate-active-background: @active-background;
    alternate-active-foreground: @active-foreground;
    selected-active-background:  @active-foreground;
    selected-active-foreground:  @active-background;

    urgent-background:           @background;
    urgent-foreground:           ]] .. theme.red .. [[;
    alternate-urgent-background: @urgent-background;
    alternate-urgent-foreground: ]] .. theme.red .. [[;
    selected-urgent-background:  @urgent-foreground;
    selected-urgent-foreground:  @urgent-background;
}
]]

local colors_string = [[
* {
    background:                  ]] .. theme.bg_normal .. [[;
    background-color:            @background;
    foreground:                  ]] .. theme.fg_normal .. [[;
    border-color:                @background;
    separatorcolor:              @border-color;

    normal-background:           @background;
    normal-foreground:           @foreground;
    alternate-normal-background: @background;
    alternate-normal-foreground: @foreground;
    selected-normal-background:  @background;
    selected-normal-foreground:  ]] .. theme.green .. [[;

    active-background:           @background;
    active-foreground:           ]] .. theme.yellow .. [[;
    alternate-active-background: @active-background;
    alternate-active-foreground: @active-foreground;
    selected-active-background:  @active-foreground;
    selected-active-foreground:  @active-background;

    urgent-background:           @background;
    urgent-foreground:           ]] .. theme.red .. [[;
    alternate-urgent-background: @urgent-background;
    alternate-urgent-foreground: ]] .. theme.red .. [[;
    selected-urgent-background:  @urgent-foreground;
    selected-urgent-foreground:  @urgent-background;
}
]]

local function generate_rofi_config()
    local rofi_config = io.open("/home/chase/.config/rofi/config.rasi", "w")

    naughty.notify({
        preset = naughty.config.presets.normal,
        title = "rofi",
        text = "generating rofi config..."
    })
    rofi_config:write(config_string)
    rofi_config:close()

    local color_config = io.open("/home/chase/.config/rofi/powermenu/colors.rasi", "w")
    color_config:write(colors_string)
    color_config:close()
end

generate_rofi_config()