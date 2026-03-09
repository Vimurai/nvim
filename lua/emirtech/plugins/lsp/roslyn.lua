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

		require("roslyn").setup({
			config = {
				capabilities = capabilities,
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
			broad_search = false,
		})
	end,
}
