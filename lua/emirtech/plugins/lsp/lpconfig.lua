return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"mason-org/mason.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		"ray-x/lsp_signature.nvim",
	},
	config = function()
		local lsp = require("lsp-zero")

		lsp.on_attach(function(client, bufnr)
			-- see :help lsp-zero-keybindings
			-- to learn the available actions
			lsp.default_keymaps({ buffer = bufnr })

			local map = vim.keymap.set
			local opts = { buffer = bufnr, silent = true }

			map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
			map("n", "<leader>rn", vim.lsp.buf.rename, opts)
			map("n", "<leader>rs", ":LspRestart<CR>", opts)
			map("n", "<leader>d", vim.diagnostic.open_float, opts)
		end)

		lsp.setup()

		-- (Optional) Configure lua language server for neovim

		local cap = require("cmp_nvim_lsp").default_capabilities()
		cap.textDocument.completion.completionItem.snippetSupport = true
		cap.offsetEncoding = { "utf-16" }

		vim.diagnostic.config({
			virtual_text = true,
			float = { border = "rounded", source = true },
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.INFO] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
				},
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP actions",
			callback = function(event)
				vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", { buffer = event.buf })
				-- More keybindings and commands....
			end,
		})

		local vue_language_server_path = vim.fn.stdpath("data")
			.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

		local vue_plugin = {
			name = "@vue/typescript-plugin",
			location = vue_language_server_path,
			enableForWorkspaceTypeScriptVersions = true,
			languages = { "vue" },
			configNamespace = "typescript",
		}
		local vtsls_config = {
			settings = {
				vtsls = {
					tsserver = {
						globalPlugins = {
							vue_plugin,
						},
					},
				},
			},
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
		}

		-- -- nvim 0.11 or above
		vim.lsp.config("vtsls", vtsls_config)
		-- vim.lsp.config("vue_ls", vue_ls_config)
		--

		vim.lsp.config("vue_ls", {
			filetypes = { "vue", "typescript", "javascript", "javascriptreact", "typescriptreact" },
			init_options = {
				typescript = {
					tsdk = vim.fn.stdpath("data")
						.. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
				},
			},
		})
	end,
}
