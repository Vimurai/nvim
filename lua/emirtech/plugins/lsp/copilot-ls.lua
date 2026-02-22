-- copilot-language-server config (required for sidekick.nvim NES)
-- Enabled via vim.lsp.enable("copilot_ls") in sidekick.lua init()
vim.lsp.config("copilot_ls", {
	cmd = { vim.fn.expand("$HOME/.local/share/nvim/mason/bin/copilot-language-server"), "--stdio" },
	filetypes = { "*" }, -- attach to all filetypes so NES works everywhere
	root_markers = { ".git" },
	init_options = {
		editorInfo = { name = "Neovim", version = vim.version().major .. "." .. vim.version().minor },
		editorPluginInfo = { name = "sidekick.nvim", version = "0.0.1" },
	},
})

return {}
