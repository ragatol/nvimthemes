local hi = vim.api.nvim_set_hl

-- color conversions
local function str_to_rgb(str)
	local colors = {}
	local index = 1
	for v in string.gmatch(str, "%x%x") do
		colors[index] = tonumber(v, 16) / 255.0
		index = index + 1
	end
	return colors[1], colors[2], colors[3]
end

local function rgb_to_str(r, g, b)
	r = math.floor(r * 255 + 0.5)
	g = math.floor(g * 255 + 0.5)
	b = math.floor(b * 255 + 0.5)
	return string.format("#%02X%02X%02X", r, g, b)
end

local function cbrtf(x)
	local x3 = x * x * x
	local taylor_series = 1 + x3 / 9 + (x3 * x3) / 81
	return x3 * taylor_series
end

local function rgb_to_oklab(r, g, b)
	-- Convert sRGB to OKLAB
	local function to_linear(v)
		return v < 0.04045 and v / 12.92 or math.pow((v + 0.055) / 1.055, 2.4)
	end
	r = to_linear(r)
	g = to_linear(g)
	b = to_linear(b)

	local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

	local l_ = cbrtf(l)
	local m_ = cbrtf(m)
	local s_ = cbrtf(s)

	local L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
	local A = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
	local B = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_

	return L, A, B
end

local function str_to_oklab(s)
	return rgb_to_oklab(str_to_rgb(s))
end

local function oklab_to_rgb(L, A, B)
	-- Convert OKLAB to sRGB
	local function from_linear(v)
		return v <= 0.0031308 and v * 12.92 or math.pow(1.055 * v, 2.4) - 0.055
	end

	local l_ = L + 0.3963377774 * A + 0.2158037573 * B
	local m_ = L - 0.1055613458 * A - 0.0638541728 * B
	local s_ = L - 0.0894841775 * A - 1.2914855480 * B

	local l = l_ * l_ * l_
	local m = m_ * m_ * m_
	local s = s_ * s_ * s_

	local r = from_linear(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s)
	local g = from_linear(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s)
	local b = from_linear(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)

	return r, g, b
end

local function oklab_to_str(L, A, B)
	return rgb_to_str(oklab_to_rgb(L, A, B))
end

local function rgb_to_xyz(r, g, b)
	-- Convert sRGB to linear RGB
	r = r > 0.04045 and ((r + 0.055) / 1.055) ^ 2.4 or (r / 12.92)
	g = g > 0.04045 and ((g + 0.055) / 1.055) ^ 2.4 or (g / 12.92)
	b = b > 0.04045 and ((b + 0.055) / 1.055) ^ 2.4 or (b / 12.92)

	-- Apply transformation matrix to XYZ
	local x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
	local y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
	local z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041

	return x, y, z
end

-- Convert XYZ to RGB
local function xyz_to_rgb(x, y, z)
	-- Apply reverse transformation matrix from XYZ
	local r = x * 3.2404542 + y * -1.5371385 + z * -0.4985314
	local g = x * -0.9692660 + y * 1.8760108 + z * 0.0415560
	local b = x * 0.0556434 + y * -0.2040259 + z * 1.0572252

	-- Convert linear RGB to sRGB
	r = r > 0.0031308 and (1.055 * r ^ (1 / 2.4) - 0.055) or (r * 12.92)
	g = g > 0.0031308 and (1.055 * g ^ (1 / 2.4) - 0.055) or (g * 12.92)
	b = b > 0.0031308 and (1.055 * b ^ (1 / 2.4) - 0.055) or (b * 12.92)

	-- Clamp values to [0, 1]
	r = math.max(0, math.min(1, r))
	g = math.max(0, math.min(1, g))
	b = math.max(0, math.min(1, b))

	return r, g, b
end

-- Convert XYZ to LAB
local function xyz_to_lab(x, y, z)
	-- Reference white point (D65)
	local ref_X = 0.95047
	local ref_Y = 1.0
	local ref_Z = 1.08883

	-- Normalize XYZ values
	x = x / ref_X
	y = y / ref_Y
	z = z / ref_Z

	-- Convert to LAB
	x = x > 0.00885645167903563081 and x ^ (1 / 3) or (7.787037037037036 * x) + (16 / 116)
	y = y > 0.00885645167903563081 and y ^ (1 / 3) or (7.787037037037036 * y) + (16 / 116)
	z = z > 0.00885645167903563081 and z ^ (1 / 3) or (7.787037037037036 * z) + (16 / 116)

	local L = (116 * y) - 16
	local a = 500 * (x - y)
	local b = 200 * (y - z)

	return L, a, b
end

-- Convert LAB to XYZ
local function lab_to_xyz(L, a, b)
	-- Reference white point (D65)
	local ref_X = 0.95047
	local ref_Y = 1.0
	local ref_Z = 1.08883

	-- Convert to XYZ
	local y = (L + 16) / 116
	local x = (a / 500) + y
	local z = y - (b / 200)

	x = ref_X * (x > 0.206896551724137931 and x ^ 3 or (x - 16 / 116) / 7.787037037037036)
	y = ref_Y * (y > 0.206896551724137931 and y ^ 3 or (y - 16 / 116) / 7.787037037037036)
	z = ref_Z * (z > 0.206896551724137931 and z ^ 3 or (z - 16 / 116) / 7.787037037037036)

	return x, y, z
end

local function str_to_lab(str)
	return xyz_to_lab(rgb_to_xyz(str_to_rgb(str)))
end

local function lab_to_str(l, a, b)
	return rgb_to_str(xyz_to_rgb(lab_to_xyz(l, a, b)))
end

-- Convert LAB to LCH
local function lab_to_lch(L, a, b)
	local C = math.sqrt(a ^ 2 + b ^ 2)
	local H = math.atan2(b, a)

	return L, C, H
end

-- Convert LCH to LAB
local function lch_to_lab(L, C, H)
	local a = C * math.cos(H)
	local b = C * math.sin(H)

	return L, a, b
end

local function str_to_lch(str)
	return { lab_to_lch(str_to_lab(str)) }
end

local function lch_to_str(lch)
	return lab_to_str(lch_to_lab(unpack(lch)))
end

local function mix_lch(color1, color2, t)
	local L1, C1, H1 = color1[1], color1[2], color1[3]
	local L2, C2, H2 = color2[1], color2[2], color2[3]

	-- Interpolate L, C, and H separately
	local L = L1 + (L2 - L1) * t
	local C = C1 + (C2 - C1) * t

	-- Ensure H is within [0, 2π)
	local H
	if math.abs(H2 - H1) <= math.pi then
		H = H1 + (H2 - H1) * t
	elseif H1 <= H2 then
		H = H1 + (H2 - H1 + 2 * math.pi) * t
	else
		H = H1 + (H2 - H1 - 2 * math.pi) * t
	end

	-- Clamp H to [0, 2π)
	H = H % (2 * math.pi)

	return { L, C, H }
end

local function make_gradation(foreground, background)
	local fg = str_to_lch(foreground)
	local bg = str_to_lch(background)
	local gradations = {}
	for i = 1, 6 do
		gradations[i] = lch_to_str(mix_lch(bg, fg, i / 6.0))
	end
	return gradations
end

local function invert_lch(accent_lch)
	local L, C, H = unpack(accent_lch)

	H = H + math.pi % (2 * math.pi)

	return { L, C, H }
end

local function invert_color_str(color_str)
	return lch_to_str(invert_lch(str_to_lch(color_str)))
end

local function make_syntax(foreground, background, accent, gradient, secondary)
	-- make colors
	local fore_lch = str_to_lch(foreground)
	local grad4_lch = str_to_lch(gradient[4])
	local accent_lch = str_to_lch(accent)
	local secondary_lch = type(secondary) == "string" and str_to_lch(secondary) or accent_lch
	local numbers_lch = mix_lch(accent_lch, fore_lch, 0.6)
	local types_lch = mix_lch(accent_lch, secondary_lch, 0.8)
	local builtin_lch = mix_lch(accent_lch, secondary_lch, 0.5)
	local strings_lch = mix_lch(secondary_lch, grad4_lch, 0.6)
	local pre_lch = mix_lch(secondary_lch, fore_lch, 0.5)
	local function_lch = mix_lch(secondary_lch, fore_lch, 0.7)
	-- to string
	local numbers_str = lch_to_str(numbers_lch)
	local strings_str = lch_to_str(strings_lch)
	local types_str = lch_to_str(types_lch)
	local builtin_str = lch_to_str(builtin_lch)
	local pre_str = lch_to_str(pre_lch)
	local function_str = lch_to_str(function_lch)
	-- make base syntax
	return {
		comments = gradient[3],
		keywords = accent,
		identifiers = foreground,
		qualifier = accent,
		constants = foreground,
		operators = secondary,
		delimiters = gradient[5],
		numbers = numbers_str,
		strings = strings_str,
		types = types_str,
		builtins = builtin_str,
		functions = function_str,
		preprocessor = pre_str,
		exceptions = pre_str,
		namespaces = function_str,
		parameters = foreground,
	}
end

-- for ui elements using gradation and accent colors
local function apply_ui(foreground, background, accent, gradation)
	local hl = {
		Conceal = { fg = gradation[2] },
		CurSearch = { bg = gradation[2], sp = gradation[4], underline = true },
		Cursor = { fg = background, bg = foreground },
		CursorLine = { bg = gradation[1] },
		CursorLineNr = { fg = accent, bg = gradation[1] },
		CursorLineSign = { fg = accent, bg = gradation[1] },
		Directory = { link = "Accent" },
		Folded = { fg = background, bg = gradation[3], italic = true },
		LineNr = { link = "Conceal" },
		LspInlayHint = { link = "Conceal" },
		MatchParen = { fg = accent, bg = gradation[2] },
		MoreMsg = { fg = gradation[3] },
		NonText = { fg = gradation[1] },
		NormalFloat = { fg = foreground, bg = gradation[2], blend = 10 },
		Pmenu = { link = "NormalFloat" },
		PmenuSbar = { bg = gradation[1] },
		PmenuSel = { fg = background, bg = accent },
		PmenuThumb = { bg = gradation[3] },
		Question = { link = "Accent" },
		QuickFixLine = { link = "Accent" },
		Search = { bg = gradation[2] },
		SignColumn = { fg = accent, bg = background },
		SpecialKey = { fg = gradation[4] },
		StatusLine = { fg = background, bg = gradation[4], bold = true },
		StatusLineNC = { fg = gradation[3], bg = background },
		Substitute = { fg = background, bg = gradation[4] },
		TabLine = { fg = gradation[3], bg = gradation[1] },
		TabLineFill = { link = "TabLine" },
		TabLineSel = { fg = gradation[5], bg = background, bold = true },
		Title = { fg = foreground, bold = true },
		Visual = { bg = gradation[3], fg = background },
		WildMenu = { link = "PmenuSel" },
		WinSeparator = { fg = gradation[3] },
		qfFilename = { link = "Parameter" },
	}
	for k, v in pairs(hl) do
		hi(0, k, v)
	end
end

local function apply_syntax(foreground, theme)
	local hl = {
		Comment = { fg = theme.comments, italic = true },

		Constant = { fg = theme.constants, bold = true },
		String = { fg = theme.strings },
		Character = { link = "String" },
		Number = { fg = theme.numbers },
		Boolean = { fg = theme.numbers, italic = true },
		Float = { link = "Number" },

		Identifier = { fg = theme.identifiers },
		Function = { fg = theme.functions },

		Statement = { fg = theme.preprocessor, bold = true },
		Conditional = { link = "Keyword" },
		Repeat = { link = "Conditional" },
		Label = { link = "Statement" },
		Operator = { fg = theme.operators },
		Keyword = { fg = theme.keywords, italic = true },
		Exception = { fg = theme.keywords, italic = true },

		PreProc = { fg = theme.preprocessor, italic = true },
		Include = { link = "PreProc" },
		Define = { link = "PreProc" },
		Macro = { link = "PreProc" },
		PreCondit = { link = "PreProc" },

		Type = { fg = theme.builtins, italic = true },
		StorageClass = { fg = theme.qualifier },
		Structure = { fg = theme.types },
		Typedef = { link = "Type" },

		Special = { fg = theme.constants, bold = true },
		SpecialChar = { link = "Special" },
		Tag = { link = "Structure" },
		Delimiter = { fg = theme.delimiters },
		SpecialComment = { link = "Special" },
		Debug = { link = "Special" },

		Underlined = { underline = true },

		Ignore = { fg = theme.comments },

		-- Error = { fg = theme.error },

		Todo = { fg = foreground, underdouble = true },

		-- Added = {},
		-- Changed = {},
		-- Removed = {},

		Namespace = { fg = theme.namespaces, italic = true },
		Parameter = { fg = theme.parameters },
		Punctuation = { fg = theme.operators },

		-- Treesitter and LSP extra highlights
		["@attribute.c"] = { link = "Comment" },
		["@attribute.cpp"] = { link = "Comment" },
		["@constant.builtin"] = { link = "Boolean" },
		["@constructor"] = { link = "Structure" },
		["@function.builtin"] = { fg = theme.functions, italic = true },
		["@keyword.conditional.ternary"] = { link = "Operator" },
		["@keyword.directive"] = { link = "PreProc" },
		["@keyword.import"] = { link = "Include" },
		["@keyword.return"] = { link = "Operator" },
		["@module"] = { link = "Namespace" },
		["@module.cpp"] = {},
		["@string.special.url"] = { fg = theme.comments, italic = true, underline = true },
		["@tag"] = { link = "Function" },
		["@tag.attribute"] = { link = "Identifier" },
		["@tag.delimiter"] = { link = "Delimiter" },
		["@type"] = { link = "Structure" },
		["@type.builtin"] = { link = "Type" },
		["@type.qualifier"] = { link = "StorageClass" },
		["@variable"] = { link = "Identifier" },
		["@variable.builtin"] = { link = "Keyword" },
		["@variable.parameter"] = { link = "Parameter" },
		["@lsp.type.keyword"] = { link = "Keyword" },
		["@lsp.type.namespace"] = { link = "Namespace" },
		["@lsp.type.type"] = { link = "Structure" },
	}
	for k, v in pairs(hl) do
		hi(0, k, v)
	end
end

local function apply(theme)
	if not theme.accent then theme.accent = theme.foreground end
	vim.api.nvim_set_option_value("termguicolors", theme.guicolors, { scope = "global" })
	vim.api.nvim_set_option_value("background", theme.type, { scope = "global" })
	vim.cmd [[hi clear]]
	hi(0, "Normal", { fg = theme.foreground, bg = theme.background })
	hi(0, "Accent", { fg = theme.accent })
	local gradient = make_gradation(theme.foreground, theme.background)
	local syntax = make_syntax(theme.foreground, theme.background, theme.accent, gradient, theme.secondary)
	if theme.syntax then
		for k, v in pairs(theme.syntax) do
			syntax[k] = v
		end
	end
	apply_syntax(theme.foreground, syntax)
	apply_ui(theme.foreground, theme.background, theme.accent, gradient)
	if theme.custom then
		for k, v in pairs(theme.custom) do
			hi(0, k, v)
		end
	end
end

-- return package metatable
local M = {}
M.apply = apply
M.make_gradation = make_gradation
M.invert_color = invert_color_str
return M
