return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
			{ "folke/which-key.nvim" },
			{ "nvim-telescope/telescope.nvim", branch = "0.1.x" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			-- Harpoon is now a dependency for context
			{ "ThePrimeagen/harpoon" },
		},
		lazy = false,
		build = "make tiktoken",

		config = function()
			---------------------------------------------------------------------------
			-- 1) Picker wiring: Snacks preferred, Telescope fallback for vim.ui.select
			---------------------------------------------------------------------------
			local function setup_ui_select()
				local ok_snacks, snacks = pcall(require, "snacks")
				if ok_snacks and snacks.picker and snacks.picker.enable_ui_select then
					snacks.picker.enable_ui_select()
					return
				end

				local ok_tel, telescope = pcall(require, "telescope")
				if ok_tel then
					pcall(function()
						telescope.setup({
							extensions = {
								["ui-select"] = {},
							},
						})
						telescope.load_extension("ui-select")
					end)

					if telescope.extensions and telescope.extensions["ui-select"] then
						vim.ui.select = function(items, opts, on_choice)
							telescope.extensions["ui-select"].select(items, opts, on_choice)
						end
					end
				end
			end
			setup_ui_select()

			---------------------------------------------------------------------------
			-- 2) CopilotChat base setup
			---------------------------------------------------------------------------
			local chat = require("CopilotChat")
			local window = chat.chat

			chat.setup({
				window = {
					layout = "vertical",
					width = 0.45,
					border = "rounded",
					title = "🤖 CopilotChat",
				},
				auto_insert_mode = true,
			})

			local wk = require("which-key")

			---------------------------------------------------------------------------
			-- 3) Helpers: source + Harpoon context
			---------------------------------------------------------------------------
			-- Always tell CopilotChat which *code* window is the source
			local function set_source_to_current_window()
				local winnr = vim.api.nvim_get_current_win()
				local bufnr = vim.api.nvim_win_get_buf(winnr)
				local ft = vim.bo[bufnr].filetype

				-- If we’re accidentally in the chat window, don’t overwrite source
				if ft ~= "copilot-chat" then
					pcall(window.set_source, winnr)
				end

				return winnr, bufnr
			end

			-- Utility: are we in any visual mode?
			local function in_visual_mode()
				local m = vim.fn.mode()
				return m == "v" or m == "V" or m == "\22" -- charwise, linewise, block
			end

			-- Ask with Harpoon-based context
			local function ask_smart(prompt)
				set_source_to_current_window()

				-- 1. Sync first to ensure internal sticky state matches Harpoon
				local ok_h, harpoon = pcall(require, "harpoon")
				local harpoon_buffers = {}
				if ok_h then
					for _, item in ipairs(harpoon:list().items) do
						if item.value and item.value ~= "" then
							table.insert(harpoon_buffers, "#file:" .. item.value)
						end
					end
				end

				-- 2. Explicitly clear any existing #file sticky items from the active chat
				-- to prevent accumulation if the events didn't catch everything.
				if chat.chat and chat.chat.sticky then
					for i = #chat.chat.sticky, 1, -1 do
						if chat.chat.sticky[i]:match("^#file:") then
							table.remove(chat.chat.sticky, i)
						end
					end
				end

				local header
				if in_visual_mode() then
					header = "#selection\n"
				else
					header = "#buffer:active\n"
				end

				chat.ask(header .. prompt, {
					sticky = harpoon_buffers,
				})
			end

			---------------------------------------------------------------------------
			-- 4) Harpoon → CopilotChat Sync (Auto-remove)
			---------------------------------------------------------------------------
			local ok_h, h = pcall(require, "harpoon")
			if ok_h then
				local function sync_harpoon_to_copilot()
					local ok_c, c = pcall(require, "CopilotChat")
					if not ok_c then
						return
					end

					local active_chat = c.chat
					if not active_chat then
						return
					end

					-- Ensure sticky table exists
					active_chat.sticky = active_chat.sticky or {}

					-- 1. Remove all existing #file: sticky items
					for i = #active_chat.sticky, 1, -1 do
						if active_chat.sticky[i]:match("^#file:") then
							table.remove(active_chat.sticky, i)
						end
					end

					-- 2. Re-add from Harpoon list
					for _, item in ipairs(h:list().items) do
						if item.value and item.value ~= "" then
							table.insert(active_chat.sticky, "#file:" .. item.value)
						end
					end
				end

				h:extend({
					REMOVE = sync_harpoon_to_copilot,
					CLEAR = sync_harpoon_to_copilot,
					ADD = sync_harpoon_to_copilot,
					UI_CLOSE = sync_harpoon_to_copilot,
				})
			end

			---------------------------------------------------------------------------
			-- 5) Rename prompt (your DDD / Clean Code rules)
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
				"- If selection is provided: restrict renames strictly to the selected code and update references only inside that selection.",
				"- Otherwise: process the whole active buffer coherently.",
				"",
				"Rules:",
				"- Do NOT change behavior or add new features.",
				"- Rename identifiers (variables, parameters, fields, methods, local functions) to intention-revealing names.",
				"- Keep public API shape unless the file is purely internal; if a rename affects public API, call it out explicitly.",
				"- Update related XML/doc comments and references in the edited scope.",
				"- Prefer domain terms (e.g., Džemat, Donation, Subscription, Project).",
				"- Examples: usr → user, usrLst → users, calc → CalculateMonthlySubscriptionCost, amt → amount.",
				"",
				"Output:",
				"- Provide a unified diff suitable for application; minimal, precise edits only.",
			}, "\n")

			local REFACTOR_PROMPT = table.concat({
				"Refactor the code to improve its structure and readability without changing its external behavior. Follow these guidelines:",
				"- Apply principles from 'Clean Code' by Robert C. Martin, such as meaningful naming, small functions, and single responsibility.",
				"- Use design patterns where appropriate to enhance code organization and maintainability.",
				"- Ensure that the refactored code adheres to best practices in the relevant programming language.",
				"",
				"Scope:",
				"- If a selection is provided: restrict refactoring strictly to the selected code and update references only inside that selection.",
				"- Otherwise: process the whole active buffer coherently.",
				"",
				"Rules:",
				"- Do NOT introduce new features or change existing functionality.",
				"- Focus on improving code clarity, reducing complexity, and enhancing modularity.",
				"- Update related comments and documentation within the edited scope as necessary.",
				"",
				"Output:",
				"- Provide a unified diff suitable for application; minimal, precise edits only.",
			}, "\n")

			-- Selection-only refactor (visual mode)
			local function refactor_selection_only()
				if not in_visual_mode() then
					vim.notify("CopilotChat: visual selection required for this mapping.", vim.log.levels.WARN)
					return
				end

				local prompt = table.concat({
					REFACTOR_PROMPT,
					"",
					"IMPORTANT:",
					"- Only edit inside #selection.",
					"- Ignore any other buffers and lines outside the selection.",
				}, "\n")

				ask_smart(prompt)
			end

			-- Whole-buffer refactor (normal mode)
			local function refactor_whole_buffer()
				local prompt = table.concat({
					REFACTOR_PROMPT,
					"",
					"IMPORTANT:",
					"- Treat the entire active buffer as the refactor scope.",
				}, "\n")

				ask_smart(prompt)
			end

			-- Selection-only rename (visual mode)
			local function rename_selection_only()
				if not in_visual_mode() then
					vim.notify("CopilotChat: visual selection required for this mapping.", vim.log.levels.WARN)
					return
				end

				local prompt = table.concat({
					RENAME_PROMPT,
					"",
					"IMPORTANT:",
					"- Only edit inside #selection.",
					"- Ignore any other buffers and lines outside the selection.",
				}, "\n")

				ask_smart(prompt)
			end

			-- Whole-buffer rename (normal mode)
			local function rename_whole_buffer()
				local prompt = table.concat({
					RENAME_PROMPT,
					"",
					"IMPORTANT:",
					"- Treat the entire active buffer as the refactor scope.",
				}, "\n")

				ask_smart(prompt)
			end

			---------------------------------------------------------------------------
			-- 5) Keymaps
			---------------------------------------------------------------------------
			wk.add({
				-- Toggle chat
				{
					"<leader>zz",
					"<cmd>CopilotChatToggle<CR>",
					desc = "CopilotChat: Toggle",
					mode = "n",
				},

				-- Talk (visual → selection, normal → buffer)
				{
					"<leader>zt",
					function()
						ask_smart(
							"Let's discuss this code. Summarize in 3 bullets, list risks, then ask me one clarifying question."
						)
					end,
				desc = "CopilotChat: Talk (smart selection/buffer + harpooned files)",
				mode = { "n", "v" },
				},

				-- Explain (Senior)
				{
					"<leader>zes",
					function()
						ask_smart("Explain senior-level: goals, data flow, invariants, trade-offs, risks.")
					end,
				desc = "CopilotChat: Explain (Senior, smart selection/buffer + harpooned files)",
				mode = { "n", "v" },
				},

				-- Explain (Junior)
				{
					"<leader>zej",
					function()
						ask_smart("Explain for a beginner: what it does, step-by-step with a tiny example.")
					end,
				desc = "CopilotChat: Explain (Junior, smart selection/buffer + harpooned files)",
				mode = { "n", "v" },
				},

				-- Rename: whole buffer (normal)
				{
					"<leader>zr",
					rename_whole_buffer,
				desc = "CopilotChat: Rename (Whole Buffer • Clean Code/DDD/Pro C#)",
				mode = "n",
				},

				-- Rename: selection only (visual)
				{
					"<leader>zr",
					rename_selection_only,
				desc = "CopilotChat: Rename (Selection Only • Clean Code/DDD/Pro C#)",
				mode = "v",
				},

				-- Refactor: whole buffer (normal)
				{
					"<leader>zf",
					refactor_whole_buffer,
				desc = "CopilotChat: Refactor (Whole Buffer • Clean Code)",
				mode = "n",
				},

				-- Refactor: selection only (visual)
				{
					"<leader>zf",
					refactor_selection_only,
				desc = "CopilotChat: Refactor (Selection Only • Clean Code)",
				mode = "v",
				},

				-- Generate Unit Tests (smart selection/buffer + harpooned files)
				{
					"<leader>zgt",
					function()
						ask_smart("Generate comprehensive unit tests for the active code. Focus on edge cases and common scenarios.")
					end,
				desc = "CopilotChat: Generate Unit Tests",
				mode = { "n", "v" },
				},

				-- Suggest Improvements (Refactor, Debug, Maintain) (smart selection/buffer + harpooned files)
				{
					"<leader>zsi",
					function()
						ask_smart("Review the active code for refactoring opportunities, potential bugs, and areas for improved maintainability. Provide specific, actionable suggestions.")
					end,
					desc = "CopilotChat: Suggest Improvements",
					mode = { "n", "v" },
				},

				-- Explain diagnostic under cursor
				{
					"<leader>zd",
					function()
						local diag = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })[1]
						if not diag then
							vim.notify("No diagnostic on this line", vim.log.levels.WARN)
							return
						end
						set_source_to_current_window()
						chat.ask(
							"#buffer:active\nExplain this error and show how to fix it:\n\n```\n" .. diag.message .. "\n```",
							{}
						)
					end,
					desc = "CopilotChat: Explain diagnostic under cursor",
					mode = "n",
				},

				-- AI commit message (staged diff, falls back to unstaged)
				{
					"<leader>zgc",
					function()
						local diff = vim.fn.system("git diff --staged")
						if diff == nil or diff:match("^%s*$") then
							diff = vim.fn.system("git diff")
						end
						if diff == nil or diff:match("^%s*$") then
							vim.notify("No git diff found", vim.log.levels.WARN)
							return
						end
						set_source_to_current_window()
						chat.ask(
							"Write a conventional commit message for this diff.\n"
								.. "Rules: type(scope): subject — types: feat|fix|refactor|chore|docs|test|style|perf.\n"
								.. "Output ONLY the commit message, nothing else.\n\n```diff\n"
								.. diff
								.. "\n```",
							{}
						)
					end,
					desc = "CopilotChat: Generate commit message",
					mode = "n",
				},
			})
		end, -- closes config = function()
	}, -- closes "CopilotC-Nvim/CopilotChat.nvim",
}