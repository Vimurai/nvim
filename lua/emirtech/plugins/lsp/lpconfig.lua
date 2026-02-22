return {
	-- 1) Core LSP + Mason wiring (no lsp-zero)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim", -- IMPORTANT for modern Mason flow
			"saghen/blink.cmp",
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{ "folke/neodev.nvim", opts = {} },
			"ray-x/lsp_signature.nvim",
		},
		config = function()
			-- -------------------------
			-- Diagnostics UI (global)
			-- -------------------------
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

			-- -------------------------
			-- Capabilities (for blink.cmp)
			-- -------------------------
			local capabilities = require("blink.cmp").get_lsp_capabilities({
				textDocument = {
					completion = { completionItem = { snippetSupport = true } },
					implementation = { dynamicRegistration = true },
				},
				offsetEncoding = { "utf-16" },
			})

			-- -------------------------
			-- Helper: razor detection (fix signatureHelp JsonException)
			-- -------------------------
			local function is_razor(bufnr)
				return vim.bo[bufnr].filetype == "razor"
			end

			-- -------------------------
			-- Keymaps + safe signature attach (per-buffer)
			-- -------------------------
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP keymaps + safe addons",
				callback = function(event)
					local bufnr = event.buf
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if not client then
						return
					end

					local map = vim.keymap.set

					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {
						buffer = bufnr,
						desc = "Code Action",
					})

					map("n", "<leader>rn", vim.lsp.buf.rename, {
						buffer = bufnr,
						desc = "Rename Symbol",
					})

					map("n", "<leader>rs", "<cmd>LspRestart<cr>", {
						buffer = bufnr,
						desc = "Restart LSP",
					})

					map("n", "<leader>d", vim.diagnostic.open_float, {
						buffer = bufnr,
						desc = "Show Diagnostics",
					})

					map("n", "K", vim.lsp.buf.hover, {
						buffer = bufnr,
						desc = "Hover Documentation",
					})

					-- (This avoids the Roslyn/Razor cohost signatureHelp deserialize error.)
					if not is_razor(bufnr) then
						local ok, sig = pcall(require, "lsp_signature")
						if ok then
							sig.on_attach({
								hint_enable = false,
								floating_window = true,
							}, bufnr)
						end
					elseif client.server_capabilities and client.server_capabilities.signatureHelpProvider then
						-- extra safety: prevent signature requests from this client in razor buffers
						client.server_capabilities.signatureHelpProvider = nil
					end
				end,
			})

			-- -------------------------
			-- Server configs (native API)
			-- -------------------------

			-- Lua LS (optional; neodev already helps)
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})

			-- ESLint (fixAll on save)
			vim.lsp.config("eslint", {
				capabilities = capabilities,
				settings = {
					experimental = { useFlatConfig = true },
					codeActionOnSave = { enable = true, mode = "all" },
				},
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
				on_attach = function(client, bufnr)
					if not client.server_capabilities.codeActionProvider then
						return
					end

					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							if not vim.api.nvim_buf_is_valid(bufnr) then
								return
							end
							vim.lsp.buf.code_action({
								apply = true,
								context = { only = { "source.fixAll.eslint" } },
							})
						end,
					})
				end,
			})

			-- Vue: follow current guidance (vue_ls + vtsls hybrid requirement)
			-- vue_ls was renamed from volar.  [oai_citation:1‡GitHub](https://github.com/vuejs/language-tools/wiki/Neovim?utm_source=chatgpt.com)
			local vue_language_server_path = vim.fn.stdpath("data")
				.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

			local vue_ts_plugin = {
				name = "@vue/typescript-plugin",
				location = vue_language_server_path,
				languages = { "vue" },
				configNamespace = "typescript",
				enableForWorkspaceTypeScriptVersions = true,
			}

			vim.lsp.config("vtsls", {
				capabilities = capabilities,
				settings = {
					vtsls = {
						tsserver = {
							globalPlugins = { vue_ts_plugin },
						},
					},
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			})

			vim.lsp.config("vue_ls", {
				capabilities = capabilities,
				filetypes = { "vue" },
				init_options = {
					typescript = {
						tsdk = vim.fn.stdpath("data")
							.. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
					},
				},
			})

			-- -------------------------
			-- Enable servers (explicitly)
			-- -------------------------
			-- Mason-lspconfig can auto-enable installed servers, but enabling explicitly is stable & clear.
			vim.lsp.enable({ "lua_ls", "eslint", "vtsls", "vue_ls" })
		end,
	},
}
