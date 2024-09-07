local theme_colors = {
	guicolors = true,
	type = "dark",
	background = "#31312E",
	foreground = "#D2D2CD",
	accent = "#D2D2CD",
	syntax = {
		strings = "#BDB29E",
		keywords = "#8C9A8E",
		constants = "#BFBDB0",
		operators = "#E23D35",
		delimiters = "#E5E4DC",
		numbers = "#ADD5D9",
		types = "#A6A499",
		builtins = "#A6A499",
		functions = "#AFBFB5",
		preprocessor = "#76D6B0",
		namespaces = "#A8BAAB",
	},
	custom = {
		["@punctuation.delimiter"] = { link = "Operator" },
		["@keyword.return"] = { fg = "#E23D35", italic = true },
		["@keyword.operator"] = { fg = "#E23D35", italic = true },
		["@keyword.exception"] = { fg = "#2FC18B", italic = true },
	},
}

require [[themetemplate]].apply(theme_colors)
