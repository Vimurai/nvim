-- CodeCompanion: agent chat, inline edits, and code review inside Neovim.
--
-- Why this exists alongside sidekick.nvim and CopilotChat: sidekick embeds a CLI
-- agent in a terminal and reloads files the agent touches, but it never sees the
-- agent's edits — there is no diff and nothing to accept or reject. CodeCompanion
-- adds that review layer, plus ACP so the same agents (Claude Code, Codex, Copilot
-- CLI, Gemini) can drive edits with a diff you approve.
--
-- Keymap namespace is <leader>c. <leader>a is sidekick, <leader>z is CopilotChat.
-- <leader>ca (code action) and <leader>cl (log macro) are already taken, so this
-- avoids both.
return {
	"olimorris/codecompanion.nvim",
	version = "^19.0.0",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
		"CodeCompanionCmd",
		"CodeCompanionCodeReview",
	},
	keys = {
		{ "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion: toggle chat" },
		{ "<leader>cp", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion: action palette" },
		{ "<leader>cn", "<cmd>CodeCompanionChat<cr>", mode = "n", desc = "CodeCompanion: new chat" },
		{ "<leader>cs", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "CodeCompanion: send selection to chat" },
		{ "<leader>ci", ":CodeCompanion ", mode = { "n", "v" }, desc = "CodeCompanion: inline prompt" },
		{ "<leader>cr", "<cmd>CodeCompanionCodeReview<cr>", mode = "n", desc = "CodeCompanion: review agent changes" },
		{
			"<leader>cm",
			"<cmd>CodeCompanionCodeReview Comment<cr>",
			mode = { "n", "v" },
			desc = "CodeCompanion: comment on hunk",
		},
		{ "<leader>cg", "<cmd>CodeCompanion /commit<cr>", mode = "n", desc = "CodeCompanion: commit message" },
	},
	opts = {
		-- Every interaction runs on Copilot. You are already authenticated for it
		-- (copilot-language-server via mason-lspconfig), so this needs no extra
		-- API key, no extra binary, and no separate sign-in.
		interactions = {
			chat = { adapter = "copilot" },
			inline = { adapter = "copilot" },
			cmd = { adapter = "copilot" },

			-- Pull-request-style review of an agent's work. Snapshots the worktree
			-- to refs/worktree/codecompanion/baseline, diffs it against disk, and
			-- puts one quickfix entry per hunk. Works with agents running outside
			-- CodeCompanion too, so it covers what sidekick's CLI does.
			code_review = {
				enabled = true,
				display = {
					virtual_text = { enabled = true, icon = "💬 " },
					diff = { enabled = true, layout = "vertical", provider = "native" },
				},
			},
		},
		display = {
			action_palette = {
				-- Matches the snacks picker already used by sidekick and snacks.nvim.
				provider = "snacks",
				opts = { show_preset_actions = true, show_preset_prompts = true },
			},
			chat = {
				window = {
					layout = "vertical",
					position = "right",
					width = 0.42, -- roughly matches the CopilotChat split
					border = "rounded",
				},
				-- Show the model in the chat buffer so it is obvious what answered.
				show_settings = false,
			},
			diff = { enabled = true },
		},
		opts = {
			log_level = "ERROR",
		},
	},
	init = function()
		local ok, wk = pcall(require, "which-key")
		if ok then
			wk.add({ { "<leader>c", group = "CodeCompanion", mode = { "n", "v" } } })
		end
	end,
}
