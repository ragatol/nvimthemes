local theme_colors = {
	guicolors = true,
	type = "dark",
	background = "#2A2F31",
	foreground = "#E6E7EB",
	accent = "#F9B322",
	secondary = "#B79E7F",
	syntax = {
		--comments = "#78817D",
		strings = "#CBB497",
		identifiers = "#EBE3D7",
		keywords = "#E3B274",
		constants = "#E48E56",
		operators = "#E9A374",
		delimiters = "#D8D9DB",
		numbers = "#E1CEB1",
		types = "#B4AFAA",
		builtins = "#CBC8C4",
		qualifier = "#D26721",
		functions = "#B4AFAA",
		preprocessor = "#836F5F",
		exceptions = "#A79587",
		namespaces = "#C1B4A5",
		parameters = "#DDD0BC",
	},
}

require [[themetemplate]].apply(theme_colors)
