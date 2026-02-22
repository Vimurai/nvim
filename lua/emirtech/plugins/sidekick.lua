return {
	"folke/sidekick.nvim",
	event = "VeryLazy",
	opts = {
		-- Use snacks.nvim as the picker (already installed)
		picker = "snacks",
		nes = {
			enabled = true,
			debounce = 100,
		},
		copilot = {
			status = {
				-- Show copilot status in notifications
				level = vim.log.levels.INFO,
			},
		},
	},
	-- Enable the copilot LSP (required for NES)
	init = function()
		vim.lsp.enable("copilot_ls")
	end,
	keys = {
		-- NES (Next Edit Suggestions) navigation
		{
			"<Tab>",
			function()
				require("sidekick.nes").accept()
			end,
			mode = { "n", "i" },
			desc = "Accept NES suggestion",
		},
		{
			"]a",
			function()
				require("sidekick.nes").next()
			end,
			desc = "Next NES suggestion",
		},
		{
			"[a",
			function()
				require("sidekick.nes").prev()
			end,
			desc = "Prev NES suggestion",
		},
		-- AI CLI panel
		{
			"<leader>ak",
			function()
				require("sidekick").open()
			end,
			desc = "Sidekick AI CLI",
		},
		{
			"<leader>ap",
			function()
				require("sidekick").prompt()
			end,
			desc = "Sidekick Prompt",
		},
	},
}
