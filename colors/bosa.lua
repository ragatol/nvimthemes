local theme_template = require "themetemplate"

local theme_colors = {
	guicolors = true,
	type = "dark",
	background = "#1D1923",
	foreground = "#F2ECE2",
	accent = "#FFC23A",
	syntax = {
		identifiers = "#F4ECE2",
		keywords = "#FFC23A",
		qualifier = "#FFC23A",
		constants = "#E1AD9B",
		operators = "#C3383B",
		delimiters = "#E55359",
		numbers = "#A9C7C2",
		strings = "#9F8E6D",
		comments = "#5D555B",
		types = "#739EA7",
		builtins = "#739EA7",
		functions = "#E8CBB2",
		preprocessor = "#E3D936",
		exceptions = "#FFC23A",
		namespaces = "#E1AD9B",
		parameters = "#F4ECE2",
	},
}

theme_template.apply(theme_colors)
