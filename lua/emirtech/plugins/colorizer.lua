return {
	"norcalli/nvim-colorizer",
	event = { "BufReadPre", "BufNewFile" },
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	config = function()
		-- import colorizer
		local colorizer = require("colorizer")

		-- configure colorizer
		colorizer.setup({
			"*", -- Highlight all files, but customize some others.
			css = { rgb_fn = true }, -- Enable parsing rgb(...) and rgba(...) functions in CSS.
			html = { names = false }, -- Disable parsing "names" of html colors (e.g. "red", "blue").
			tailwind = true, -- Enable tailwind colors
			sass = { css = true }, -- Enable sass colors
			hsl_fn = true, -- Enable parsing hsl(...) and hsla(...) functions in CSS.
		})
	end,
}
