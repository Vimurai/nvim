return {
	"ray-x/lsp_signature.nvim",
	event = "LspAttach",
	config = function()
		require("lsp_signature").setup({
			bind = true,
			floating_window = true,
			hint_prefix = "💡 ",
			handler_opts = {
				border = "rounded",
			},
			toggle_key = "<M-x>", -- optional: toggle with Alt+x
		})
	end,
}
