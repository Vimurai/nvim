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
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
			formatters = {
				csharpier = {
					command = vim.fn.expand("~/.dotnet/tools/csharpier"),
					args = { "--write-stdout", "$FILENAME" },
					stdin = true,
					to_tempfile = false,
					require_cwd = false,
				},
				prettier = {
					command = "./node_modules/.bin/prettier", -- ✅ Use local Prettier directly
					args = {
						"--config",
						vim.fn.getcwd() .. "/.prettierrc.json", -- ✅ Force config location
						"--stdin-filepath",
						"$FILENAME",
					},
					stdin = true,
					require_cwd = true,
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
