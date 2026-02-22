return {
	"folke/sidekick.nvim",
	event = "VeryLazy",
	opts = {
		picker = "snacks",
		nes = {
			enabled = true,
			debounce = 100,
		},
		copilot = {
			status = {
				level = vim.log.levels.INFO,
			},
		},
		cli = {
			win = {
				layout = "right",
				keys = {
					-- Esc exits terminal insert mode → normal mode so <leader>h/l/j/k work
					escape = { "<Esc>", "<C-\\><C-n>", mode = "t", desc = "exit terminal mode" },
					-- Option+hjkl for window nav from terminal mode (Mac-safe)
					nav_left = { "<M-h>", "nav_left", expr = true, desc = "go to left window" },
					nav_down = { "<M-j>", "nav_down", expr = true, desc = "go to lower window" },
					nav_up = { "<M-k>", "nav_up", expr = true, desc = "go to upper window" },
					nav_right = { "<M-l>", "nav_right", expr = true, desc = "go to right window" },
				},
			},
		},
	},
	-- Enable the copilot LSP (required for NES)
	init = function()
		vim.lsp.enable("copilot_ls")
	end,
	keys = {
		{
			"]a",
			function()
				require("sidekick.nes").jump()
			end,
			desc = "NES: jump to next suggestion",
		},
		{
			"[a",
			function()
				require("sidekick.nes").clear()
			end,
			desc = "NES: clear suggestion",
		},
		-- AI CLI panel
		{
			"<leader>ak",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick AI CLI toggle",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").select_prompt()
			end,
			desc = "Sidekick prompt picker",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").select_tool()
			end,
			desc = "Sidekick tool picker",
		},
	},
}
