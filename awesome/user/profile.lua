local user = {

	-- user info
	name         = "Chase",
    modkey       = "Mod4",
    --user_img     = os.getenv("HOME") .. "/.config/awesome/assets/user.png",

	-- apps
	terminal     = "gnome-terminal",
	file_manager = "nautilus",
	browser      = "firefox",
	editor       = "code",

    -- appearance
	wallpaper    = os.getenv("HOME") .. "/.config/awesome/backgrounds/generated_wallpaper.png",
	icon_path    = os.getenv("HOME") .. '/.icons/Gruvbox-Material-Dark/48x48/apps/',
    theme        = "gruvbox", -- available themes: [gruvbox, everforest, nord, rose_pine]

    -- behavior
    generate_rofi_config = false,
    generate_zathura_config = false,
}

return user
