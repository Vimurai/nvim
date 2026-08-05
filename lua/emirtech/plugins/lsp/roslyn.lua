return {
	"seblyng/roslyn.nvim",
	ft = { "cs", "razor", "cshtml" },
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities({
			textDocument = {
				completion = { completionItem = { snippetSupport = true } },
				implementation = { dynamicRegistration = true },
			},
		})
		capabilities.offsetEncoding = { "utf-16" }

		-- Server-level settings go through vim.lsp.config, not roslyn.setup().
		-- roslyn.setup() forwards its whole table to roslyn.config, which reads
		-- only filewatching / choose_target / ignore_target / broad_search /
		-- lock_target / debug. `config`, `exe` and `args` were deprecated and
		-- then removed upstream, so anything nested under them is silently
		-- dropped — which is what happened to the settings below.
		vim.lsp.config("roslyn", {
			capabilities = capabilities,
			cmd = {
				vim.fn.stdpath("data") .. "/mason/bin/roslyn",
				"--stdio",
				"--logLevel=Information",
				-- vim.lsp.get_log_path() is deprecated in 0.12.
				"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
			},
			settings = {
				["razor"] = {
					enabled = true,
				},
				-- Razor save-on-format runs synchronously with a 5000ms timeout
				-- (see formatting.lua). Full-solution background analysis starves
				-- the server of that window and the format request times out or
				-- freezes the editor. Analyzers are the expensive pass and buy the
				-- least here, so they are off entirely; compiler diagnostics stay
				-- on for open buffers so real errors still surface.
				["csharp|background_analysis"] = {
					dotnet_analyzer_diagnostics_scope = "none",
					dotnet_compiler_diagnostics_scope = "openFiles",
				},
				["csharp|inlay_hints"] = {
					csharp_enable_inlay_hints_for_implicit_object_creation = true,
					csharp_enable_inlay_hints_for_implicit_variable_types = true,
					csharp_enable_inlay_hints_for_lambda_parameter_types = true,
					csharp_enable_inlay_hints_for_types = true,
				},
			},
		})

		require("roslyn").setup({
			-- "off" registers file watching and then ignores every file, which is
			-- what stops the server drowning in didChangeWatchedFiles. The plugin
			-- sets didChangeWatchedFiles.dynamicRegistration = false for us in this
			-- mode, so doing it by hand in capabilities is redundant. A boolean
			-- false is no longer recognised — the option is a string enum now.
			filewatching = "off",
			broad_search = true,
			choose_target = function(targets)
				return targets[1]
			end,
		})
	end,
}
