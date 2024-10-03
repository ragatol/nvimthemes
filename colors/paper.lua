local theme_template = require "themetemplate"

local theme_colors = {
	guicolors = true,
	type = "light",
	background = "#E2DAD2",
	foreground = "#000000",
	accent = "#202010",
	syntax = {
		functions = "#503030",
		numbers = "#804000",
		booleans = "#804000",
		strings = theme_template.invert_color("#804000"),
	},
	custom = {
		Delimiter = { bold = true },
		Keyword = { bold = true },
		Type = { italic = true },
		Structure = { italic = true },
		["@keyword.return"] = { link = "Keyword" },
		["@string.escape"] = { bold = true },
	}
}

theme_template.apply(theme_colors)
