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
		-- The Copilot server itself is enabled by mason-lspconfig's
		-- automatic_enable, using nvim-lspconfig's canonical `copilot` config.
		-- Do not enable a second one here: sidekick's is_copilot() matches any
		-- client whose name contains "copilot", so a duplicate means two node
		-- processes, two sets of inlineCompletion candidates, and NES firing at
		-- whichever it picks first.
		if vim.lsp.inline_completion then
			vim.lsp.inline_completion.enable(true)
		end
	end,
	keys = {
		{
			-- Normal mode only. Insert-mode Tab is owned by blink.cmp's keymap
			-- (blink-cmp.lua), which runs the same NES-then-inline-completion
			-- chain and wins there anyway — having both meant two handlers racing
			-- for one key. Inline completion is insert-mode only in any case
			-- (":h lsp-inline_completion" refreshes on insert), so there is
			-- nothing for it to do here.
			"<tab>",
			function()
				if require("sidekick").nes_jump_or_apply() then
					return "" -- consumed: do not type a literal tab
				end
				return "<tab>" -- falls through to <C-i> / jumplist
			end,
			mode = "n",
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
				require("sidekick.cli").prompt()
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
				require("sidekick.cli").select()
			end,
			desc = "Sidekick tool picker",
		},
	},
}
