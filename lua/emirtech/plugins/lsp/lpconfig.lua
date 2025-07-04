return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		"ray-x/lsp_signature.nvim",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local mason_registry = require("mason-registry")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local capabilities = cmp_nvim_lsp.default_capabilities()
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		capabilities.offsetEncoding = { "utf-16" }

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

		-- Vue LS (template + style support)
		vim.lsp.config("vue_ls", {
			-- add filetypes for typescript, javascript and vue
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			init_options = {
				vue = {
					-- disable hybrid mode
					hybridMode = false,
				},
			},
		})
		vim.lsp.enable("vue_ls")

		-- ESLINT
		lspconfig.eslint.setup({
			on_attach = function(client, bufnr)
				-- Format on save
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					command = "EslintFixAll",
				})
			end,
			settings = {
				-- Critical for eslint.config.js support
				experimental = {
					useFlatConfig = true,
				},
				format = true,
				validate = "on",
				codeActionOnSave = {
					enable = true,
					mode = "all",
				},
				run = "onType",
				workingDirectory = { mode = "location" },
			},
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"vue",
			},
		})

		-- C# via csharp_ls
		lspconfig.csharp_ls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git", ".razor"),
		})

		-- HTML
		lspconfig.html.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "html", "vue" },
		})

		-- CSS / SCSS / LESS
		lspconfig.cssls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "css", "scss", "less", "vue" },
		})

		-- Auto diagnostics on hover
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function()
				vim.diagnostic.open_float(nil, { focusable = false })
			end,
		})

		-- LSP restart on detach
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

		-- Show diagnostics on file open
		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function(args)
				vim.defer_fn(function()
					local bufnr = args.buf
					local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
					if #clients > 0 and #vim.diagnostic.get(bufnr) > 0 then
						vim.diagnostic.open_float(bufnr, { focus = false, scope = "line" })
					end
				end, 200)
			end,
		})
	end,
}
