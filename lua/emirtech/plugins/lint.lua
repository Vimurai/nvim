return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			-- JavaScript, TypeScript, Vue: ESLint is often handled by LSP, but can be added here too if preferred
			javascript = { "eslint" },
			typescript = { "eslint" },
			javascriptreact = { "eslint" },
			typescriptreact = { "eslint" },
			vue = { "eslint" },

			-- Lua: luacheck (requires `luacheck` to be installed globally or via Mason)
			lua = { "luacheck" },

			-- Python: flake8, pylint (requires linters to be installed)
			python = { "flake8" },

			-- Markdown: markdownlint (requires `markdownlint-cli` to be installed)
			markdown = { "markdownlint" },

			-- Shell scripts: shellcheck (requires `shellcheck` to be installed)
			sh = { "shellcheck" },

			-- JSON: jsonlint (requires `jsonlint` to be installed)
			json = { "jsonlint" },

			-- YAML: yamllint (requires `yamllint` to be installed)
			yaml = { "yamllint" },

			-- C# (.NET):
			-- For C#, many diagnostics come from the Roslyn LSP.
			-- External CLI linters for C# are less common than for JS/Python,
			-- but you could add something like `dotnet format`'s analysis output
			-- if there was a way to integrate it as a linter, or a dedicated
			-- C# linter if one exists (e.g., dotnet-format can check style).
			-- For now, relying on Roslyn LSP for C# diagnostics is typical.
			cs = {}, -- Placeholder for potential future C# specific linters
		}

		-- Optional: Configure how diagnostics are displayed (similar to LSP diagnostics)
		vim.diagnostic.config({
			signs = true,
			virtual_text = true,
			update_in_insert = false,
			float = {
				border = "rounded",
				source = true,
			},
		})

		-- Autocmds to run linting
		-- Lint on save
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				lint.try_lint()
			end,
		})

		-- Lint on opening a buffer
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "BufWritePost", "InsertLeave" }, {
			callback = function()
				lint.try_lint()
			end,
		})

		-- You can also define specific linters and their commands/args if not auto-detected
		-- lint.linters.eslint = {
		--   cmd = { "eslint_d", "--stdin", "--stdin-filename", "%file" },
		--   stdin = true,
		-- }

		-- Example: Keymap to manually trigger linting
		vim.keymap.set("n", "<leader>lt", function()
			lint.try_lint()
		end, { desc = "Trigger Lint" })
	end,
}
