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
		local lspconfig = require("lspconfig")
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

		local vue_ls_config = {
			on_init = function(client)
				client.handlers["tsserver/request"] = function(_, result, context)
					local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
					if #clients == 0 then
						vim.notify(
							"Could not found `vtsls` lsp client, vue_lsp would not work without it.",
							vim.log.levels.ERROR
						)
						return
					end
					local ts_client = clients[1]

					local param = unpack(result)
					local id, command, payload = unpack(param)
					ts_client:exec_cmd({
						title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
						command = "typescript.tsserverRequest",
						arguments = {
							command,
							payload,
						},
					}, { bufnr = context.bufnr }, function(_, r)
						local response_data = { { id, r.body } }
						---@diagnostic disable-next-line: param-type-mismatch
						client:notify("tsserver/response", response_data)
					end)
				end
			end,
			on_attach = on_attach, -- 🔥 Add this line
		}
		-- nvim 0.11 or above
		vim.lsp.config("vtsls", vtsls_config)
		vim.lsp.config("vue_ls", vue_ls_config)

		-- ESLint
		vim.lsp.config("eslint", {
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						if vim.fn.exists(":EslintFixAll") == 2 then
							vim.cmd("EslintFixAll")
						end
					end,
				})
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
		vim.lsp.config("csharp_ls", {
			on_attach = on_attach,
			capabilities = cap,
			root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git", ".razor"),
		})

		-- HTML & CSS
		vim.lsp.config("html", { on_attach = on_attach, capabilities = cap })
		vim.lsp.config("cssls", { on_attach = on_attach, capabilities = cap })
		vim.lsp.config("emmet_ls", {
			on_attach = on_attach,
			capabilities = cap,
			filters = { "html", "css", "javascript", "typescript", "vue" },
		})

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
