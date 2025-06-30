return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		input = { enabled = true }, -- enable the input window
		spelling = { enabled = true }, -- enable the spelling window
		indent = { enabled = true }, -- enable the indent window
		explorer = {
			enabled = true,
		},
		dashboard = {
			sections = {
				{ section = "header" },
				{
					pane = 2,
					section = "terminal",
					cmd = "colorscript -e square",
					height = 5,
					padding = 1,
				},
				{ section = "keys", gap = 1, padding = 1 },
				{
					pane = 2,
					icon = " ",
					title = "Recent Files",
					section = "recent_files",
					indent = 2,
					padding = 1,
				},
				{ pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				{
					pane = 2,
					icon = " ",
					title = "Git Status",
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					cmd = "git status --short --branch --renames",
					height = 5,
					padding = 1,
					ttl = 5 * 60,
					indent = 3,
				},
				{ section = "startup" },
			},
		},
		scope = {
			-- This is the scope of the plugin, it can be a table or a function
			-- The function will be called with the current file and should return a table
			-- The table should contain the following
			--
		},
		-- Documentation for the picker
		-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
		picker = {
			hidden = true, -- show hidden files in the pickers
			-- My ~/github/dotfiles-latest/neovim/lazyvim/lua/config/keymaps.lua
			-- file was always showing at the top, I needed a way to decrease its
			-- score, in frecency you could use :FrecencyDelete to delete a file
			-- from the database, here you can decrease it's score
			transform = function(item)
				if not item.file then
					return item
				end
				-- Demote the "lazyvim" keymaps file:
				if item.file:match("lazyvim/lua/config/keymaps%.lua") then
					item.score_add = (item.score_add or 0) - 30
				end
				-- Boost the "neobean" keymaps file:
				-- if item.file:match("neobean/lua/config/keymaps%.lua") then
				--   item.score_add = (item.score_add or 0) + 100
				-- end
				return item
			end,
			-- In case you want to make sure that the score manipulation above works
			-- or if you want to check the score of each file
			debug = {
				scores = false, -- show scores in the list
			},
			-- I like the "ivy" layout, so I set it as the default globaly, you can
			-- still override it in different keymaps
			layout = {
				preset = "ivy",
				-- When reaching the bottom of the results in the picker, I don't want
				-- it to cycle and go back to the top
				cycle = false,
			},
			layouts = {
				-- I wanted to modify the ivy layout height and preview pane width,
				-- this is the only way I was able to do it
				-- NOTE: I don't think this is the right way as I'm declaring all the
				-- other values below, if you know a better way, let me know
				--
				-- Then call this layout in the keymaps above
				-- got example from here
				-- https://github.com/folke/snacks.nvim/discussions/468
				ivy = {
					layout = {
						box = "vertical",
						backdrop = false,
						row = -1,
						width = 0,
						height = 0.5,
						border = "top",
						title = " {title} {live} {flags}",
						title_pos = "left",
						{ win = "input", height = 1, border = "bottom" },
						{
							box = "horizontal",
							{ win = "list", border = "none" },
							{ win = "preview", title = "{preview}", width = 0.5, border = "left" },
						},
					},
				},
				-- I wanted to modify the layout width
				--
				vertical = {
					layout = {
						backdrop = false,
						width = 0.8,
						min_width = 80,
						height = 0.8,
						min_height = 30,
						box = "vertical",
						border = "rounded",
						title = "{title} {live} {flags}",
						title_pos = "center",
						{ win = "input", height = 1, border = "bottom" },
						{ win = "list", border = "none" },
						{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
					},
				},
			},
			matcher = {
				frecency = true,
			},
			win = {
				input = {
					keys = {
						-- to close the picker on ESC instead of going to normal mode,
						-- add the following keymap to your config
						["<Esc>"] = { "close", mode = { "n", "i" } },
						-- I'm used to scrolling like this in LazyGit
						["J"] = { "preview_scroll_down", mode = { "i", "n" } },
						["K"] = { "preview_scroll_up", mode = { "i", "n" } },
						["H"] = { "preview_scroll_left", mode = { "i", "n" } },
						["L"] = { "preview_scroll_right", mode = { "i", "n" } },
					},
				},
			},
			formatters = {
				file = {
					filename_first = true, -- display filename before the file path
					truncate = 80,
				},
			},
		},
		notifier = {
			enabled = true,
			top_down = false, -- place notifications from top to bottom
		},
		-- This keeps the image on the top right corner, basically leaving your
		-- text area free, suggestion found in reddit by user `Redox_ahmii`
		-- https://www.reddit.com/r/neovim/comments/1irk9mg/comment/mdfvk8b/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
		styles = {
			snacks_image = {
				relative = "editor",
				col = -1,
			},
		},
		image = {
			enabled = true,
			doc = {
				-- Personally I set this to false, I don't want to render all the
				-- images in the file, only when I hover over them
				-- render the image inline in the buffer
				-- if your env doesn't support unicode placeholders, this will be disabled
				-- takes precedence over `opts.float` on supported terminals
				inline = vim.g.neovim_mode == "skitty" and true or false,
				-- only_render_image_at_cursor = vim.g.neovim_mode == "skitty" and false or true,
				-- render the image in a floating window
				-- only used if `opts.inline` is disabled
				float = true,
				-- Sets the size of the image
				-- max_width = 60,
				-- max_width = vim.g.neovim_mode == "skitty" and 20 or 60,
				-- max_height = vim.g.neovim_mode == "skitty" and 10 or 30,
				max_width = vim.g.neovim_mode == "skitty" and 5 or 60,
				max_height = vim.g.neovim_mode == "skitty" and 2.5 or 30,
				-- max_height = 30,
				-- Apparently, all the images that you preview in neovim are converted
				-- to .png and they're cached, original image remains the same, but
				-- the preview you see is a png converted version of that image
				--
				-- Where are the cached images stored?
				-- This path is found in the docs
				-- :lua print(vim.fn.stdpath("cache") .. "/snacks/image")
				-- For me returns `~/.cache/neobean/snacks/image`
				-- Go 1 dir above and check `sudo du -sh ./* | sort -hr | head -n 5`
			},
		},
	},
	keys = {
		{ "<leader>e", false },
		-- Top Pickers & Explorer
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{
			"<leader>ee",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
		{
			"<leader>ef",
			function()
				Snacks.picker.explorer({
					cwd = vim.fn.expand("%:p:h"),
				})
			end,
			desc = "File Explorer (Current File)",
		},
		-- find
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Find Git Files",
		},
		{
			"<leader>fp",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent",
		},
		-- git
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Git Branches",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"<leader>gL",
			function()
				Snacks.picker.git_log_line()
			end,
			desc = "Git Log Line",
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git Status",
		},
		{
			"<leader>gS",
			function()
				Snacks.picker.git_stash()
			end,
			desc = "Git Stash",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git Diff (Hunks)",
		},
		{
			"<leader>gf",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Git Log File",
		},
		-- LSP
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Goto T[y]pe Definition",
		},
	},

	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- Setup some globals for debugging (lazy-loaded)
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				-- ✅ Set Neovim UI to use Snacks (AFTER snacks is loaded)
				vim.ui.input = Snacks.input
				vim.ui.select = Snacks.picker.select

				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.line_number():map("<leader>ul")
				Snacks.toggle
					.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
					:map("<leader>uc")
				Snacks.toggle.treesitter():map("<leader>uT")
				Snacks.toggle
					.option("background", { off = "light", on = "dark", name = "Dark Background" })
					:map("<leader>ub")
				-- Snacks.toggle.inlay_hints():map("<leader>uh")
				Snacks.toggle.indent():map("<leader>ug")
				Snacks.toggle.dim():map("<leader>uD")
			end,
		})
	end,
}
