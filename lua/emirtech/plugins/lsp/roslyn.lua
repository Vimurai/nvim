return {
	"seblyng/roslyn.nvim",
	ft = { "cs", "razor", "cshtml" },
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		capabilities.offsetEncoding = { "utf-16" }
		capabilities.textDocument.implementation = { dynamicRegistration = true }

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
			broad_search = true,
		})
	end,
}
