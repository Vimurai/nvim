return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	config = function()
		local mc = require("multicursor-nvim")
		mc.setup()

		local set = vim.keymap.set

		local function safe_set(mode, lhs, rhs, opts)
			if type(rhs) == "function" or type(rhs) == "string" then
				set(mode, lhs, rhs, opts or {})
			end
		end

		-- Ergonomic cursor add/skip (Alt+j/k or arrows)
		safe_set({ "n", "x" }, "<C-k>", function()
			mc.lineAddCursor(-1)
		end)
		safe_set({ "n", "x" }, "<C-j>", function()
			mc.lineAddCursor(1)
		end)

		-- Match/add cursors by selection or word
		safe_set({ "n", "x" }, "<C-n>", function()
			mc.matchAddCursor(1)
		end)
		safe_set({ "n", "x" }, "<C-s>", function()
			mc.matchSkipCursor(1)
		end)
		safe_set({ "n", "x" }, "<A-N>", function()
			mc.matchAddCursor(-1)
		end)
		safe_set({ "n", "x" }, "<A-S>", function()
			mc.matchSkipCursor(-1)
		end)

		-- Select all matches (if available)
		if type(mc.selectAllMatches) == "function" then
			safe_set({ "n", "x" }, "<leader>m", mc.selectAllMatches)
		end

		-- Visual selection + match all
		if type(mc.matchAddCursor) == "function" and type(mc.selectAllMatches) == "function" then
			safe_set("x", "<leader>vm", function()
				mc.matchAddCursor(1)
				mc.selectAllMatches()
			end)
		end

		-- Toggle enable/disable cursors
		safe_set({ "n", "x" }, "<c-q>", mc.toggleCursor)

		-- Define multicursor mode mappings
		if type(mc.addKeymapLayer) == "function" then
			mc.addKeymapLayer(function(layerSet)
				layerSet({ "n", "x" }, "<left>", mc.prevCursor)
				layerSet({ "n", "x" }, "<right>", mc.nextCursor)
				layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

				layerSet("n", "<esc>", function()
					if not mc.cursorsEnabled() then
						mc.enableCursors()
					else
						mc.clearCursors()
					end
				end)

				-- Insert mode helpers
				layerSet("i", "<C-a>", "<Esc>^i")
				layerSet("i", "<C-e>", "<Esc>$a")
			end)
		end

		-- Highlights
		local hl = vim.api.nvim_set_hl
		hl(0, "MultiCursorCursor", { link = "Cursor" })
		hl(0, "MultiCursorVisual", { link = "Visual" })
		hl(0, "MultiCursorSign", { link = "SignColumn" })
		hl(0, "MultiCursorMatchPreview", { link = "Search" })
		hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
		hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
		hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

		-- Optional command
		vim.api.nvim_create_user_command("MCVars", function()
			if type(mc.matchAddCursor) == "function" and type(mc.selectAllMatches) == "function" then
				mc.matchAddCursor(1)
				mc.selectAllMatches()
			end
		end, { desc = "Multicursor on word under cursor" })
	end,
}
