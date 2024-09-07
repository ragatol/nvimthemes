local theme_template = require "themetemplate"

local theme_colors = {
	guicolors = true,
	type = "dark",
	background = "#1F0C12",
	foreground = "#D3FEF5",
	accent = "#4CFDD3",
	syntax = {
		identifiers = "#B6CDAB",
		keywords = "#5FC6B1",
		qualifier = "#FFC23A",
		constants = "#82FFF4",
		operators = "#D3FEF5",
		delimiters = "#D3FEF5",
		numbers = "#82FFF4",
		strings = "#9E6144",
		comments = "#5D555B",
		types = "#979074",
		builtins = "#739EA7",
		functions = "#5FC6B1",
		preprocessor = "#BAD794",
		exceptions = "#FFC23A",
		namespaces = "#E1AD9B",
		parameters = "#F4ECE2",
	},
	custom = {
		--Delimiter = { fg = "#D3FEF5", bold = true },
	},
}

theme_template.apply(theme_colors)
