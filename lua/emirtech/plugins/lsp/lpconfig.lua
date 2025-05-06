return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		-- Optional Power-ups:
		"ray-x/lsp_signature.nvim", -- Signature help
	},
	config = function()
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- Diagnostic visuals
		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			float = { border = "rounded", source = true },
		})

		-- Diagnostic signs
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Shared on_attach
		local on_attach = function(_, bufnr)
			local map = vim.keymap.set
			local opts = { buffer = bufnr, silent = true }
			map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
			map("n", "<leader>rn", vim.lsp.buf.rename, opts)
			map("n", "<leader>rs", ":LspRestart<CR>", opts)
		end

		-- Autocompletion capabilities
		local capabilities = cmp_nvim_lsp.default_capabilities()
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		capabilities.offsetEncoding = { "utf-16" }

		-- Setup all LSPs via mason
		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})
			end,

			-- Specific server configurations
			["svelte"] = function()
				lspconfig.svelte.setup({
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						on_attach(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePost", {
							pattern = { "*.js", "*.ts" },
							callback = function(ctx)
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
							end,
						})
					end,
				})
			end,

			["graphql"] = function()
				lspconfig.graphql.setup({
					capabilities = capabilities,
					on_attach = on_attach,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				})
			end,

			["emmet_ls"] = function()
				lspconfig.emmet_ls.setup({
					capabilities = capabilities,
					on_attach = on_attach,
					filetypes = {
						"html",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
						"vue",
						"javascriptreact",
						"typescriptreact",
					},
				})
			end,

			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							completion = { callSnippet = "Replace" },
						},
					},
				})
			end,

			["volar"] = function()
				lspconfig.volar.setup({
					capabilities = capabilities,
					on_attach = on_attach,
					filetypes = {
						"typescript",
						"javascript",
						"javascriptreact",
						"typescriptreact",
						"vue",
					},
					init_options = {
						vue = { hybridMode = false },
						typescript = {
							tsdk = vim.fn.expand(
								"~/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib"
							),
						},
					},
				})
			end,

			["ts_ls"] = function()
				lspconfig["ts_ls"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
					root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
				})
			end,

			["omnisharp"] = function()
				lspconfig.omnisharp.setup({
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = {
						"dotnet",
						vim.fn.expand("~/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll"),
					},
					settings = {
						FormattingOptions = {
							EnableEditorConfigSupport = true,
							OrganizeImports = nil,
						},
						MsBuild = {
							LoadProjectsOnDemand = nil,
						},
						RoslynExtensionsOptions = {
							EnableAnalyzersSupport = true,
							EnableImportCompletion = nil,
							AnalyzeOpenDocumentsOnly = nil,
						},
						Sdk = {
							IncludePrereleases = true,
						},
					},
				})
			end,
		})
	end,
}
