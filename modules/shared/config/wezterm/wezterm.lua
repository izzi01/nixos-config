local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrains Mono")
config.font_size = 16.0

-- Set default program based on operating system
if wezterm.target_triple:find("windows") then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
end

if wezterm.target_triple:find("apple") then
	local homebrew_paths_string = "/opt/homebrew/bin/zellij, /usr/local/bin/zellij"
	local zellij_in_homebrew = #wezterm.glob(homebrew_paths_string) > 0
	if zellij_in_homebrew then
		config.default_prog = { "/opt/homebrew/bin/zellij", "-l", "welcome" }
	else
		config.default_prog = nil
	end
end

-- Set font size based on DPI
-- local dpi = wezterm.gui.screens()[1].effective_dpi
-- if dpi >= 144 then
--   config.font_size = 14.0
-- elseif dpi >= 120 then
--   config.font_size = 13.0
-- else
--   config.font_size = 12.0
-- end

-- Hiberee theme colors
local hiberee = {
	foreground = "#c5c8c6",
	background = "#1d1f21",
	cursor_bg = "#c5c8c6",
	cursor_border = "#c5c8c6",
	cursor_fg = "#1d1f21",
	selection_bg = "#373b41",
	selection_fg = "#c5c8c6",

	ansi = {
		"#1d1f21", -- black
		"#cc6666", -- red
		"#b5bd68", -- green
		"#f0c674", -- yellow
		"#81a2be", -- blue
		"#b294bb", -- magenta
		"#8abeb7", -- cyan
		"#c5c8c6", -- white
	},

	brights = {
		"#373b41", -- bright black
		"#cc6666", -- bright red
		"#b5bd68", -- bright green
		"#f0c674", -- bright yellow
		"#81a2be", -- bright blue
		"#b294bb", -- bright magenta
		"#8abeb7", -- bright cyan
		"#ffffff", -- bright white
	},
}

config.colors = hiberee
-- F11 to toggle fullscreen mode
config.keys = {
	{ key = "F11", action = wezterm.action.ToggleFullScreen },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
}
-- URLs in Markdown files are not handled properly by default
-- Source: https://github.com/wez/wezterm/issues/3803#issuecomment-1608954312
config.hyperlink_rules = {
	-- Matches: a URL in parens: (URL)
	{
		regex = "\\((\\w+://\\S+)\\)",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in brackets: [URL]
	{
		regex = "\\[(\\w+://\\S+)\\]",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in curly braces: {URL}
	{
		regex = "\\{(\\w+://\\S+)\\}",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in angle brackets: <URL>
	{
		regex = "<(\\w+://\\S+)>",
		format = "$1",
		highlight = 1,
	},
	-- Then handle URLs not wrapped in brackets
	{
		-- Before
		--regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
		--format = '$0',
		-- After
		regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
		format = "$1",
		highlight = 1,
	},
	-- implicit mailto link
	{
		regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
		format = "mailto:$0",
	},
}
config.hide_mouse_cursor_when_typing = false
return config
