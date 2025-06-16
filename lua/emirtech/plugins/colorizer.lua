return {
	"NvChad/nvim-colorizer.lua",
	config = function()
		require("colorizer").setup({
			filetypes = { "css", "scss", "vue", "javascript", "typescript", "lua" },
			user_default_options = {
				RGB = true,
				names = true,
				tailwind = true,
			},
		})
	end,
}
