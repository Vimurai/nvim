vim.lsp.config("copilot_ls", {
	cmd = { vim.fn.expand("$HOME/.local/share/nvim/mason/bin/copilot-language-server"), "--stdio" },
	-- REMOVED the filetypes = { "*" } line to kill the warning
	root_markers = { ".git" },
	init_options = {
		editorInfo = { name = "Neovim", version = vim.version().major .. "." .. vim.version().minor },
		editorPluginInfo = { name = "sidekick.nvim", version = "0.0.1" },
	},
})

return {}
