return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				vue = { "prettier" }, -- Added Vue formatting support
				go = { "gofmt" },
				cs = { "csharpier" },
			},
			format_on_save = function(bufnr)
				local ft = vim.bo[bufnr].filetype

				-- ✅ Razor: format via LSP on save
				if ft == "razor" then
					return { lsp_format = "first", timeout_ms = 8000 }
				end

				-- ✅ For C#: use csharpier (no LSP)
				if ft == "cs" then
					return { lsp_format = "never", timeout_ms = 5000 }
				end

				-- ✅ Everything else: use configured formatter, fallback to LSP if none
				return { lsp_format = "fallback", timeout_ms = 1000 }
			end,
			formatters = {
				csharpier = {
					command = vim.fn.expand("~/.dotnet/tools/csharpier"),
					args = { "format", "--write-stdout", "--log-level", "None" },
					to_stdin = true,
				},
				prettier = {
					command = vim.fn.executable("./node_modules/.bin/prettier") == 1 and "./node_modules/.bin/prettier"
						or "prettier",
					args = {
						"--stdin-filepath",
						"$FILENAME",
					},
					stdin = true,
					format_on_save = false,
					require_cwd = false,
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_format = "fallback",
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
