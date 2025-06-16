return {
	"echasnovski/mini.animate",
	config = function()
		require("mini.animate").setup({
			scroll = { enable = true },
			cursor = { enable = true },
			resize = { enable = false },
		})
	end,
}
