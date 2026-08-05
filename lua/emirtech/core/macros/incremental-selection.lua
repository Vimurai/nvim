-- Treesitter incremental selection.
--
-- nvim-treesitter's `main` branch removed the module system entirely (upstream
-- 692b051b, "drop modules"), and `incremental_selection` went with it. This
-- restores the <CR> / <BS> behaviour on top of the core treesitter API, which
-- is all the old module used anyway.
--
--   <CR>  normal  select the smallest named node under the cursor
--   <CR>  visual  grow the selection to the next enclosing node
--   <BS>  visual  shrink back to the previous selection
--
-- Assumes 'selection' is "inclusive" (Neovim's default) for the end-column math.

local M = {}

-- Per-buffer stack of ranges we have grown through, so <BS> can retrace.
-- Keyed by bufnr; cleared whenever a selection is started fresh.
local stacks = {}

---@return integer[] {start_row, start_col, end_row, end_col} 0-indexed, end col exclusive
local function to_range(node)
	local srow, scol, erow, ecol = node:range()
	return { srow, scol, erow, ecol }
end

local function same_range(a, b)
	return a and b and a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
end

---Apply a treesitter range as a charwise visual selection.
local function select_range(range)
	local srow, scol, erow, ecol = range[1], range[2], range[3], range[4]

	-- Treesitter end columns are exclusive; visual selection is inclusive. A
	-- range ending at column 0 actually ends at the end of the previous line.
	if ecol == 0 then
		erow = math.max(erow - 1, srow)
		local line = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or ""
		ecol = #line
	end
	ecol = math.max(ecol - 1, 0)

	if vim.fn.mode():match("^[vV\22]") then
		vim.cmd("normal! \27") -- drop out of visual before repositioning
	end
	vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
	vim.cmd("normal! v")
	vim.api.nvim_win_set_cursor(0, { erow + 1, ecol })
end

---The visual selection as a treesitter-style range.
local function current_visual_range()
	local s = vim.fn.getpos("v")
	local e = vim.fn.getpos(".")
	local srow, scol = s[2] - 1, s[3] - 1
	local erow, ecol = e[2] - 1, e[3] - 1
	if srow > erow or (srow == erow and scol > ecol) then
		srow, scol, erow, ecol = erow, ecol, srow, scol
	end
	return { srow, scol, erow, ecol + 1 } -- back to exclusive end
end

---Smallest named node covering `range`, then walk outward until strictly bigger.
local function grow(range)
	local ok, node = pcall(vim.treesitter.get_node, {
		bufnr = 0,
		pos = { range[1], range[2] },
		ignore_injections = false,
	})
	if not ok or not node then
		return nil
	end

	-- Descend past nodes that do not actually contain the selection end.
	while node do
		local r = to_range(node)
		local covers = (r[3] > range[3]) or (r[3] == range[3] and r[4] >= range[4])
		if covers and not same_range(r, range) then
			return r
		end
		node = node:parent()
	end
	return nil
end

function M.init()
	local buf = vim.api.nvim_get_current_buf()
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf })
	if not ok or not node then
		-- No parser for this buffer: behave like an ordinary <CR>.
		return vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
	end
	local range = to_range(node)
	stacks[buf] = { range }
	select_range(range)
end

function M.expand()
	local buf = vim.api.nvim_get_current_buf()
	local stack = stacks[buf]
	local current = current_visual_range()

	-- If the user moved the selection by hand, restart tracking from it.
	if not stack or not same_range(stack[#stack], current) then
		stack = { current }
		stacks[buf] = stack
	end

	local next_range = grow(current)
	if not next_range then
		return select_range(current) -- already at the root; keep what we have
	end
	stack[#stack + 1] = next_range
	select_range(next_range)
end

function M.shrink()
	local buf = vim.api.nvim_get_current_buf()
	local stack = stacks[buf]
	if not stack or #stack < 2 then
		return -- nothing to retrace; leave the selection alone
	end
	table.remove(stack)
	select_range(stack[#stack])
end

vim.keymap.set("n", "<CR>", M.init, { desc = "Treesitter: start incremental selection" })
vim.keymap.set("x", "<CR>", M.expand, { desc = "Treesitter: grow selection" })
vim.keymap.set("x", "<BS>", M.shrink, { desc = "Treesitter: shrink selection" })

-- <CR> in the quickfix/location list must still jump to the entry, and in a
-- terminal it must still be sent through.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("emirtech_incsel_optout", { clear = true }),
	pattern = { "qf", "help", "netrw", "lazy", "mason", "checkhealth", "TelescopePrompt" },
	callback = function(args)
		pcall(vim.keymap.del, "n", "<CR>", { buffer = args.buf })
		vim.keymap.set("n", "<CR>", "<CR>", { buffer = args.buf, remap = false })
	end,
})

return M
