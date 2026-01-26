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
				-- we’ll drive context via #buffer / #buffers / #selection in prompts
			})

			local wk = require("which-key")

			---------------------------------------------------------------------------
			-- 3) Helpers: source + context (selection vs buffer)
			---------------------------------------------------------------------------
			-- Always tell CopilotChat which *code* window is the source
			local function set_source_to_current_window()
				local winnr = vim.api.nvim_get_current_win()
				local bufnr = vim.api.nvim_win_get_buf(winnr)
				local ft = vim.bo[bufnr].filetype

				-- If we’re accidentally in the chat window, don’t overwrite source
				if ft ~= "copilot-chat" then
					-- API is a function, not a method: window.set_source(winnr)
					pcall(window.set_source, winnr)
				end

				return winnr, bufnr
			end

			-- Utility: are we in any visual mode?
			local function in_visual_mode()
				local m = vim.fn.mode()
				return m == "v" or m == "V" or m == "\22" -- charwise, linewise, block
			end

			-- Helper: get conventionally related files (e.g., for Vue components)
			-- This will look for files in the same directory with the same base name
			local function get_related_files(bufnr)
				local file_path = vim.api.nvim_buf_get_name(bufnr)
				if file_path == "" then
					return {}
				end

				local file_name = vim.fn.fnamemodify(file_path, ":t")         -- e.g., MyComponent.vue
				local base_name = vim.fn.fnamemodify(file_name, ":r")         -- e.g., MyComponent
				local dir_name = vim.fn.fnamemodify(file_path, ":h")          -- e.g., /path/to/component/

				if base_name == "" or dir_name == "" then
					return {}
				end

				local related_extensions = {
					-- Common web component relations
					".vue", ".ts", ".js", ".tsx", ".jsx",
					".css", ".scss", ".less", ".styl",
					-- Test files
					".test.ts", ".test.js", ".spec.ts", ".spec.js",
				}

				local related_files = {}
				local glob_pattern = dir_name .. "/" .. base_name .. ".*"
				
				-- Use vim.fn.glob to find files matching the pattern
				local found_files_str = vim.fn.glob(glob_pattern, true, true)
				local found_files = found_files_str

				for _, found_file_path in ipairs(found_files) do
					if found_file_path ~= "" and found_file_path ~= file_path then
						local found_ext = vim.fn.fnamemodify(found_file_path, ":e")
						-- Check if the found file has one of our "related" extensions
						for _, ext in ipairs(related_extensions) do
							if "." .. found_ext == ext then
								table.insert(related_files, found_file_path)
								break
							end
						end
					end
				end

				-- Also consider index files in subdirectories, e.g., 'src/components/MyComponent/index.vue'
				local potential_subdir = dir_name .. "/" .. base_name
				if vim.fn.isdirectory(potential_subdir) == 1 then
					for _, ext in ipairs({".vue", ".ts", ".js", ".tsx", ".jsx"}) do
						local index_file = potential_subdir .. "/index" .. ext
						if vim.fn.filereadable(index_file) == 1 then
							table.insert(related_files, index_file)
							break
						end
					end
				end

				return related_files
			end

			-- Ask with smart context:
			--  - visual → #selection
			--  - normal → #buffer:active
			--  - always include #buffers so it knows about all open files
			local function ask_smart(prompt)
				set_source_to_current_window()

				local header
				if in_visual_mode() then
					header = "#selection\n"
				else
					header = "#buffer:active\n"
				end

				local bufnr = vim.api.nvim_get_current_buf()
				local additional_sticky_buffers = {}
				for _, related_file_path in ipairs(get_related_files(bufnr)) do
					-- Use full path for #buffer: to ensure uniqueness
					table.insert(additional_sticky_buffers, "#buffer:" .. related_file_path)
				end

				chat.ask(header .. prompt, {
					-- Make it aware of all open buffers by default, plus explicitly related files
					sticky = vim.list_extend({ "#buffers" }, additional_sticky_buffers),
				})
			end

			---------------------------------------------------------------------------
			-- 4) Rename prompt (your DDD / Clean Code rules)
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

				set_source_to_current_window()

				-- #selection = only the visually selected code
				local prompt = table.concat({
					"#selection",
					"",
					REFACTOR_PROMPT,
					"",
					"IMPORTANT:",
					"- Only edit inside #selection.",
					"- Ignore any other buffers and lines outside the selection.",
				}, "\n")

				chat.ask(prompt, {
					sticky = { "#buffers" }, -- still let it *see* other buffers, but edits must be selection only
				})
			end

			-- Whole-buffer refactor (normal mode)
			local function refactor_whole_buffer()
				set_source_to_current_window()

				local prompt = table.concat({
					"#buffer:active",
					"",
					REFACTOR_PROMPT,
					"",
					"IMPORTANT:",
					"- Treat the entire active buffer as the refactor scope.",
					"- Use other open buffers (#buffers) only for extra context if needed.",
				}, "\n")

				chat.ask(prompt, {
					sticky = { "#buffers" },
				})
			end

			-- Selection-only rename (visual mode)
			local function rename_selection_only()
				if not in_visual_mode() then
					vim.notify("CopilotChat: visual selection required for this mapping.", vim.log.levels.WARN)
					return
				end

				set_source_to_current_window()

				-- #selection = only the visually selected code
				local prompt = table.concat({
					"#selection",
					"",
					RENAME_PROMPT,
					"",
					"IMPORTANT:",
					"- Only edit inside #selection.",
					"- Ignore any other buffers and lines outside the selection.",
				}, "\n")

				chat.ask(prompt, {
					sticky = { "#buffers" }, -- still let it *see* other buffers, but edits must be selection only
				})
			end

			-- Whole-buffer rename (normal mode)
			local function rename_whole_buffer()
				set_source_to_current_window()

				local prompt = table.concat({
					"#buffer:active",
					"",
					RENAME_PROMPT,
					"",
					"IMPORTANT:",
					"- Treat the entire active buffer as the refactor scope.",
					"- Use other open buffers (#buffers) only for extra context if needed.",
				}, "\n")

				chat.ask(prompt, {
					sticky = { "#buffers" },
				})
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
					desc = "CopilotChat: Talk (smart selection/buffer + all buffers)",
					mode = { "n", "v" },
				},

				-- Explain (Senior)
				{
					"<leader>zes",
					function()
						ask_smart("Explain senior-level: goals, data flow, invariants, trade-offs, risks.")
					end,
					desc = "CopilotChat: Explain (Senior, smart selection/buffer + all buffers)",
					mode = { "n", "v" },
				},

				-- Explain (Junior)
				{
					"<leader>zej",
					function()
						ask_smart("Explain for a beginner: what it does, step-by-step with a tiny example.")
					end,
					desc = "CopilotChat: Explain (Junior, smart selection/buffer + all buffers)",
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

				-- Generate Unit Tests (smart selection/buffer + all buffers + related files)
				{
					"<leader>zgt",
					function()
						ask_smart("Generate comprehensive unit tests for the active code. Focus on edge cases and common scenarios.")
					end,
					desc = "CopilotChat: Generate Unit Tests",
					mode = { "n", "v" },
				},

				-- Suggest Improvements (Refactor, Debug, Maintain) (smart selection/buffer + all buffers + related files)
				{
					"<leader>zsi",
					function()
						ask_smart("Review the active code for refactoring opportunities, potential bugs, and areas for improved maintainability. Provide specific, actionable suggestions.")
					end,
					desc = "CopilotChat: Suggest Improvements",
					mode = { "n", "v" },
				},
			})
		end,
	},
}
