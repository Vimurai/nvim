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

		local function on_attach(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

			local map = vim.keymap.set
			local opts = { buffer = bufnr, silent = true }

			map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
			map("n", "<leader>rn", vim.lsp.buf.rename, opts)
			map("n", "<leader>rs", ":LspRestart<CR>", opts)
			map("n", "<leader>d", vim.diagnostic.open_float, opts)
		end

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
			on_attach = on_attach, -- 🔥 Add this line
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
			on_attach = on_attach,
			init_options = {
				typescript = {
					tsdk = vim.fn.stdpath("data")
						.. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
				},
			},
		})

		-- ESLint
		vim.lsp.config("eslint", {
			on_attach = function(client, bufnr)
				if client.server_capabilities.codeActionProvider then
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.code_action({
								apply = true,
								context = {
									only = { "source.fixAll.eslint" },
									diagnostics = {},
								},
							})
						end,
					})
				end
			end,
			settings = {
				experimental = { useFlatConfig = true },
				format = true,
				validate = "on",
				codeActionOnSave = { enable = true, mode = "all" },
				run = "onType",
				workingDirectory = { mode = "location" },
			},
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
		})

		-- C#
		vim.lsp.enable("omnisharp")

		-- HTML & CSS
		vim.lsp.enable("html")
		vim.lsp.enable("cssls")
		vim.lsp.enable("emmet_ls")

		-- Diagnostic autos
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function()
				vim.diagnostic.open_float(nil, { focusable = false })
			end,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.name ~= "" then
					vim.schedule(function()
						vim.cmd("LspStart " .. client.name)
					end)
				end
			end,
		})

		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function(args)
				vim.defer_fn(function()
					local bufnr = args.buf
					if #vim.lsp.get_active_clients({ bufnr = bufnr }) > 0 and #vim.diagnostic.get(bufnr) > 0 then
						vim.diagnostic.open_float(bufnr, { focus = false, scope = "line" })
					end
				end, 200)
			end,
		})
	end,
}
