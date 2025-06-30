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
				svelte = { "eslint_d", "prettier" },
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
				cs = { "csharpier" }, -- Added C# formatting support
			},
			format_on_save = {
				lsp_fallback = false,
				async = false,
				timeout_ms = 1000,
			},
			formatters = {
				csharpier = {
					command = vim.fn.expand("~/.dotnet/tools/csharpier"),
					args = { "format", "--write-stdout" },
					to_stdin = true,
				},
				prettier = {
					command = vim.fn.executable("./node_modules/.bin/prettier") == 1 and "./node_modules/.bin/prettier"
						or "prettier",
					args = {
						"--config",
						vim.fn.getcwd() .. "/.prettierrc.json",
						"--stdin-filepath",
						"$FILENAME",
					},
					stdin = true,
					require_cwd = false,
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
