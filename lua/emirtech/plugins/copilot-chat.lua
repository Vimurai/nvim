return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
			{ "folke/which-key.nvim" },
			-- pickers you said you use:
			{ "folke/snacks.nvim" },
			{ "nvim-telescope/telescope.nvim" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
		},
		lazy = false,
		build = "make tiktoken",

		config = function()
			---------------------------------------------------------------------------
			-- 1) Picker wiring: snacks preferred, Telescope fallback for vim.ui.select
			---------------------------------------------------------------------------
			local function setup_ui_select()
				local ok_snacks, snacks = pcall(require, "snacks")
				if ok_snacks and snacks.picker and snacks.picker.enable_ui_select then
					snacks.picker.enable_ui_select()
				else
					local ok_tel, telescope = pcall(require, "telescope")
					if ok_tel then
						pcall(function()
							telescope.setup({ extensions = { ["ui-select"] = {} } })
							telescope.load_extension("ui-select")
						end)
						if telescope.extensions and telescope.extensions["ui-select"] then
							vim.ui.select = function(items, opts, on_choice)
								telescope.extensions["ui-select"].select(items, opts, on_choice)
							end
						end
					end
				end
			end
			setup_ui_select()

			---------------------------------------------------------------------------
			-- 2) CopilotChat base setup
			---------------------------------------------------------------------------
			local chat = require("CopilotChat")
			local select_api = require("CopilotChat.select")
			chat.setup({
				window = {
					layout = "vertical",
					width = 0.45,
					border = "rounded",
					title = "🤖 CopilotChat",
				},
				auto_insert_mode = true,
				-- default selection (used by prompts you might call directly)
				selection = function(source)
					return select_api.visual(source) or select_api.buffer(source)
				end,
			})

			---------------------------------------------------------------------------
			-- 3) Source capture helpers: always read from the *code* window/buffer
			---------------------------------------------------------------------------
			local wk = require("which-key")
			local ui = require("CopilotChat").chat

			local function capture_source_from_code()
				local src_win
				local focused = false
				pcall(function()
					focused = ui:focused()
				end)
				if focused then
					src_win = vim.fn.win_getid(vim.fn.winnr("#"))
				else
					src_win = vim.api.nvim_get_current_win()
				end
				if not (src_win and vim.api.nvim_win_is_valid(src_win)) then
					src_win = vim.api.nvim_get_current_win()
				end
				-- Set CopilotChat's source window (API may be method or function; handle both)
				if ui.set_source then
					local ok = pcall(function()
						ui.set_source(src_win)
					end)
					if not ok then
						pcall(function()
							ui:set_source(src_win)
						end)
					end
				end
				return { winnr = src_win, bufnr = vim.api.nvim_win_get_buf(src_win) }
			end

			---------------------------------------------------------------------------
			-- 4) Prompts & actions
			---------------------------------------------------------------------------
			local RENAME_PROMPT = table.concat({
				"Refactor names to follow professional standards:",
				"- Microsoft C# naming guidelines (types/methods/props: PascalCase; locals/parameters: camelCase; no abbrevs).",
				"- Clean Code (intention-revealing, pronounceable, searchable).",
				"- Refactoring (Fowler): consistent vocabulary, rename to clarify purpose.",
				"- Domain-Driven Design (Eric Evans): use Ubiquitous Language; prefer Value Objects & Enums where appropriate (naming only).",
				"- Pro C# 10 with .NET 6 conventions.",
				"",
				"Scope:",
				"- If selection is provided: restrict renames strictly to the selected code and update references within that selection.",
				"- Otherwise: process the whole buffer coherently.",
				"",
				"Rules:",
				"- Do NOT change behavior or add new features.",
				"- Rename identifiers (variables, parameters, fields, methods, local functions) to intention-revealing names.",
				"- Keep public API shape unless the file is purely internal; if a rename affects public API, call it out.",
				"- Update related XML/doc comments and references in the edited scope.",
				"- Prefer domain terms (e.g., Džemat, Donation, Subscription, Project).",
				"- Examples: usr → user, usrLst → users, calc → CalculateMonthlySubscriptionCost, amt → amount.",
				"",
				"Output:",
				"- Provide a unified diff suitable for application; minimal, precise edits only.",
			}, "\n")

			-- Ask using visual OR buffer (fallback), for general discuss/explain prompts
			local function ask_vis_or_buf(prompt)
				local source = capture_source_from_code()
				chat.ask(prompt, {
					selection = function(_)
						return select_api.visual(source) or select_api.buffer(source)
					end,
					sticky = { "#buffer:active" },
				})
			end

			-- === RENAME ===
			-- Visual-mode: strictly selection only (no fallback)
			local function rename_selection_only()
				local source = capture_source_from_code()
				local sel = select_api.visual(source)
				if not sel then
					vim.notify("CopilotChat: No visual selection detected.", vim.log.levels.WARN)
					return
				end
				chat.ask(RENAME_PROMPT, {
					selection = function(_)
						return sel
					end, -- force selection only
					sticky = { "#buffer:active" },
				})
			end

			-- Normal-mode: whole buffer
			local function rename_whole_buffer()
				local source = capture_source_from_code()
				chat.ask(RENAME_PROMPT, {
					selection = function(_)
						return select_api.buffer(source)
					end,
					sticky = { "#buffer:active" },
				})
			end

			---------------------------------------------------------------------------
			-- 5) Keymaps
			---------------------------------------------------------------------------
			wk.add({
				{ "<leader>zz", "<cmd>CopilotChatToggle<CR>", desc = "CopilotChat: Toggle", mode = "n" },

				-- Talk (sel/buffer)
				{
					"<leader>zt",
					function()
						ask_vis_or_buf(
							"Let's discuss this code. Summarize in 3 bullets, list risks, then ask me one clarifying question."
						)
					end,
					desc = "CopilotChat: Talk (visual → selection; normal → buffer)",
					mode = { "n", "v" },
				},

				-- Explain (Senior)
				{
					"<leader>zes",
					function()
						ask_vis_or_buf("Explain senior-level: goals, data flow, invariants, trade-offs, risks.")
					end,
					desc = "CopilotChat: Explain (Senior, sel/buffer)",
					mode = { "n", "v" },
				},

				-- Explain (Junior)
				{
					"<leader>zej",
					function()
						ask_vis_or_buf("Explain for a beginner: what it does, step-by-step with a tiny example.")
					end,
					desc = "CopilotChat: Explain (Junior, sel/buffer)",
					mode = { "n", "v" },
				},

				-- === Rename, per your request ===
				{
					"<leader>zr",
					rename_whole_buffer,
					desc = "CopilotChat: Rename (Whole Buffer • Clean Code/DDD/Pro C#)",
					mode = "n",
				},
				{
					"<leader>zr",
					rename_selection_only,
					desc = "CopilotChat: Rename (Selection Only • Clean Code/DDD/Pro C#)",
					mode = "v",
				},
			})
		end,
	},
}
