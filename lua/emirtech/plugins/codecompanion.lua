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
		adapters = {
			acp = {
				-- The stock claude_code adapter shells out to `claude-agent-acp`,
				-- which does not exist — no such binary, and nothing is published
				-- under that name. Claude Code itself has no ACP mode either
				-- (checked `claude --help`, v2.1.222). The working bridge is Zed's,
				-- installed with:
				--   npm install -g @zed-industries/claude-code-acp
				-- It authenticates through the claude CLI's own session, so if it
				-- ever reports a login is needed, run `claude /login` in a terminal.
				claude_code = function()
					local adapter = require("codecompanion.adapters").extend("claude_code", {
						commands = {
							default = { "claude-code-acp" },
							yolo = { "claude-code-acp", "--yolo" },
						},
					})

					-- Clear the env table outright rather than merging over it.
					--
					-- The adapter ships env = { CLAUDE_CODE_OAUTH_TOKEN =
					-- "CLAUDE_CODE_OAUTH_TOKEN" }, meaning "read that variable".
					-- When it is unset, get_env_vars falls through and hands the
					-- child the *literal name* as the value, so the bridge sends
					-- `Bearer CLAUDE_CODE_OAUTH_TOKEN` and the API answers 401
					-- "Invalid bearer token". Verified: env_replaced held a 23-char
					-- string, exactly the length of the variable name.
					--
					-- With nothing set here the bridge inherits the environment and
					-- uses the claude CLI's own Keychain session, which is the
					-- documented auth path ("Run `claude /login`"). vim.system adds
					-- to the inherited environment rather than replacing it, so an
					-- empty table means "change nothing".
					--
					-- Only set CLAUDE_CODE_OAUTH_TOKEN in your shell if you have
					-- generated a real long-lived token via `claude setup-token`.
					adapter.env = {}

					return adapter
				end,
			},
		},

		-- Every interaction runs on Copilot. You are already authenticated for it
		-- (~/.config/github-copilot), so this needs no extra API key, no extra
		-- binary, and no separate sign-in.
		--
		-- The model is pinned rather than left on "auto". GitHub's auto router
		-- sent a chat request to a model with a 12288-token limit and the request
		-- died with model_max_prompt_tokens_exceeded at 34420 tokens — code
		-- review and editor context push prompts well past that. This account
		-- only exposes two chat models anyway ("auto" and this one), so there is
		-- nothing lost by naming it. Check with :CodeCompanionActions if the
		-- roster changes.
		interactions = {
			chat = { adapter = { name = "copilot", model = "gpt-5.3-codex" } },
			inline = { adapter = { name = "copilot", model = "gpt-5.3-codex" } },
			cmd = { adapter = { name = "copilot", model = "gpt-5.3-codex" } },

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
