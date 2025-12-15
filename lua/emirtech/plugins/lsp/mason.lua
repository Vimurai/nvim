return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			automatic_enable = true,
			-- list of servers for mason to install
			-- if you want to see all of the servers run :Mason
			ensure_installed = {
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"pyright",
				"vue_ls", -- Vue.js LSP
				"csharp_ls", -- c# LSP
				"vtsls",
				"eslint",
				"gopls",
			},
		})

		mason_tool_installer.setup({
			auto_update = true,
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"pylint",
				"shfmt", -- shell script formatter
				"markdownlint", -- markdown linter
				"golines", -- Go code formatter
				"jsonlint", -- for JSON files
				"clang-format", -- if working with C/C++
				"csharpier", -- C# formatter
				"eslint_d", -- JavaScript/TypeScript linter
			},
		})
	end,
}
