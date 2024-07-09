local wezterm = require("wezterm")

local config = {
	scrollback_lines = 10000,
	enable_scroll_bar = true,
	font = wezterm.font("JetBrainsMono Nerd Font Mono"),
	font_size = 13.0,
	pane_focus_follows_mouse = false,
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	max_fps = 60,
	window_background_opacity = 1.0,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	window_frame = {
		font = wezterm.font({ family = "Roboto", weight = "Bold" }),
		font_size = 11.0,
	},
	colors = {
		tab_bar = {
			-- The color of the inactive tab bar edge/divider
			inactive_tab_edge = "#575757",
		},
	},
	keys = {
		{
			key = "k",
			mods = "CMD",
			action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
		},
		{
			key = "d",
			mods = "CMD",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "d",
			mods = "CMD|SHIFT",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		-- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
		{
			key = "LeftArrow",
			mods = "OPT",
			action = wezterm.action({ SendString = "\x1bb" }),
		},
		-- Make Option-Right equivalent to Alt-f; forward-word
		{
			key = "RightArrow",
			mods = "OPT",
			action = wezterm.action({ SendString = "\x1bf" }),
		},
		{
			key = "LeftArrow",
			mods = "CMD",
			action = wezterm.action({ SendString = "\x1bOH" }),
		},
		{
			key = "RightArrow",
			mods = "CMD",
			action = wezterm.action({ SendString = "\x1bOF" }),
		},
		-- Select next tab with cmd-opt-left/right arrow
		{
			key = "LeftArrow",
			mods = "CMD|OPT",
			action = wezterm.action.ActivateTabRelative(-1),
		},
		{
			key = "RightArrow",
			mods = "CMD|OPT",
			action = wezterm.action.ActivateTabRelative(1),
		},
		-- Select next pane with cmd-left/right arrow
		{
			key = "[",
			mods = "CMD",
			action = wezterm.action({ ActivatePaneDirection = "Prev" }),
		},
		{
			key = "]",
			mods = "CMD",
			action = wezterm.action({ ActivatePaneDirection = "Next" }),
		},
	},
	mouse_bindings = {
		{
			event = { Down = { streak = 1, button = "Left" } },
			mods = "CMD|ALT",
			action = wezterm.action.SelectTextAtMouseCursor("Block"),
			alt_screen = "Any",
		},
		{
			event = { Down = { streak = 4, button = "Left" } },
			action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
			mods = "NONE",
		},
	},
}

return config
