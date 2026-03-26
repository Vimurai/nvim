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
		capabilities.workspace = capabilities.workspace or {}
		capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

		require("roslyn").setup({
			config = {
				capabilities = capabilities,
				filewatching = false,
				settings = {
					["razor"] = {
						enabled = true,
					},
					["csharp"] = {
						inlayHints = {
							enableForParameters = true,
							enableForLiteralParameters = true,
							enableForIndexerParameters = true,
							enableForObjectCreationParameters = true,
							enableForOtherParameters = true,
							enableForImplicitVariableTypes = true,
							enableForLambdaParameterTypes = true,
							enableForImplicitObjectCreation = true,
						},
					},
				},
			},
			exe = vim.fn.stdpath("data") .. "/mason/bin/roslyn",
			args = {
				"--logLevel=Information",
				"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
			},
			broad_search = true,
			choose_target = function(sln)
				return sln[1]
			end,
		})
	end,
}
