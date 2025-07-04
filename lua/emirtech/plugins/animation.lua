return {
	"echasnovski/mini.animate",
	config = function()
		local animate = require("mini.animate")

		animate.setup({
			cursor = { enable = false },
			scroll = {
				enable = false,
			},
			resize = { enable = false },
			open = { enable = false },
			close = { enable = false },
		})
	end,
}
