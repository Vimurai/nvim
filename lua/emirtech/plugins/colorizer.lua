return {
	"norcalli/nvim-colorizer.lua",
	config = function()
		require("colorizer").setup({
			"*",
			"!vim",
			"!help",
		}, { mode = "background" })
	end,
}
