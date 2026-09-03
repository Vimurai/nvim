return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			-- JavaScript, TypeScript, Vue: ESLint diagnostics come from the eslint
			-- LSP (lsp/lpconfig.lua), which also falls back to a default config when
			-- the project has none. Running the `eslint` CLI here too only duplicated
			-- diagnostics, and errored ("ENOENT" / "Could not find config file") in
			-- projects without an eslint binary or config.

			-- Lua: luacheck (requires `luacheck` to be installed globally or via Mason)
			lua = { "luacheck" },

			-- pylint, not flake8: mason_tool_installer installs pylint (see
			-- lsp/mason.lua) and flake8 was never installed, so every Python
			-- buffer logged "Error running flake8: ENOENT" on each lint trigger.
			python = { "pylint" },

			-- Markdown: markdownlint (requires `markdownlint-cli` to be installed)
			markdown = { "markdownlint" },

			-- Shell scripts: shellcheck (requires `shellcheck` to be installed)
			sh = { "shellcheck" },

			-- JSON: jsonlint (requires `jsonlint` to be installed)
			json = { "jsonlint" },

			-- YAML: yamllint (requires `yamllint` to be installed)
			yaml = { "yamllint" },

			-- C# (.NET):
			cs = { "dotnet-format" },
			razor = { "dotnet-format" },
		}

		lint.linters["dotnet-format"] = {
			cmd = "dotnet",
			args = { "format", "whitespace", "--verify-no-changes" },
			stdin = false,
			stream = "stdout",
			ignore_exitcode = true,
			parser = require("lint.parser").from_pattern(
				[[(%f[%w]%w+%.%w+)%((%d+),(%d+)%): (%w+) (%w%d+): (.*)]],
				{ "file", "lnum", "col", "severity", "code", "message" }
			),
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
