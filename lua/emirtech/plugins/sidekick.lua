return {
	"folke/sidekick.nvim",
	event = "VeryLazy",
	opts = {
		picker = "snacks",
		nes = {
			enabled = function(buf)
				return vim.bo[buf].filetype ~= "vue"
			end,
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
					escape = { "<Esc>", "<C-\\><C-n>", mode = "t", desc = "exit terminal mode" },
					nav_left = { "<M-h>", "nav_left", expr = true, desc = "go to left window" },
					nav_down = { "<M-j>", "nav_down", expr = true, desc = "go to lower window" },
					nav_up = { "<M-k>", "nav_up", expr = true, desc = "go to upper window" },
					nav_right = { "<M-l>", "nav_right", expr = true, desc = "go to right window" },
				},
			},
		},
	},
	init = function()
		-- 1. Start the server
		vim.lsp.enable("copilot_ls")
		-- 2. ENABLE the native ghost text engine
		if vim.lsp.inline_completion then
			vim.lsp.inline_completion.enable(true)
		end
	end,
	keys = {
		{
			"<tab>",
			function()
				-- if there is a next edit, jump to it, otherwise apply it if any
				if require("sidekick").nes_jump_or_apply() then
					return "" -- return empty string so Neovim doesn't type anything
				end

				-- if you are using Neovim's native inline completions
				local inline = vim.lsp and vim.lsp.inline_completion
				if inline and type(inline.get) == "function" then
					local ok, sugg = pcall(inline.get)
					if ok and sugg ~= nil and sugg ~= false then
						-- 3. ACCEPT the completion to actually insert the text!
						inline.accept()
						return ""
					end
				end

				-- fall back to normal tab
				return "<tab>"
			end,
			mode = { "i", "n" },
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
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
			"<leader>ad",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Detach a CLI Session",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Send File",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
		{
			"<leader>al", -- Changed this from 'at' because it conflicted with "Send This" above
			function()
				require("sidekick.cli").select_tool()
			end,
			desc = "Sidekick tool picker",
		},
	},
}
