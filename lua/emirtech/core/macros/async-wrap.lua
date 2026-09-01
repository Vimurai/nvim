-- async-wrap.lua: toggle `await` on a visual selection and, when adding it,
-- auto-promote the enclosing function to `async` via treesitter if it isn't
-- already (JS/TS/Vue/React/Svelte). Complements try-catch.lua for the common
-- `try { await x() } catch (e) {}` pattern.
local langs = require("emirtech.core.macros.langs")

local FUNCTION_TYPES = {
	function_declaration = true,
	function_expression = true,
	arrow_function = true,
	method_definition = true,
	generator_function_declaration = true,
}

local function find_enclosing_function(bufnr, row, col)
	-- Force a synchronous reparse: right after our own buffer edit, nothing
	-- has necessarily redrawn yet, and get_node() on a stale tree returns nil.
	local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not parser_ok or not parser then
		return nil
	end
	parser:parse()

	local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
	if not ok or not node then
		return nil
	end
	while node do
		if FUNCTION_TYPES[node:type()] then
			return node
		end
		node = node:parent()
	end
	return nil
end

local function ensure_async(bufnr, fn_node)
	local text = vim.treesitter.get_node_text(fn_node, bufnr)
	local header = text:match("^(.-)%(") or text
	if header:match("%f[%a]async%f[%A]") then
		return -- already async
	end

	-- Class methods: insert right before the method name so any `static`
	-- modifier stays first (`static foo()` -> `static async foo()`).
	if fn_node:type() == "method_definition" then
		local name_node = fn_node:field("name")[1]
		if name_node then
			local row, col = name_node:start()
			vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { "async " })
			return
		end
	end

	-- function/arrow/generator: `async` is the leading token, so it goes at
	-- the very start of the node.
	local row, col = fn_node:start()
	vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { "async " })
end

vim.keymap.set("v", "<leader>aw", function()
	local ft = vim.bo.filetype
	if not langs.is_js_family(ft) then
		vim.notify("Async wrap not implemented for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	local bufnr = 0
	local srow, scol = vim.fn.line("v"), vim.fn.col("v")
	local erow, ecol = vim.fn.line("."), vim.fn.col(".")

	if srow > erow or (srow == erow and scol > ecol) then
		srow, erow = erow, srow
		scol, ecol = ecol, scol
	end

	-- col("v") is the 1-indexed inclusive start -> 0-indexed inclusive start.
	-- col(".") is the 1-indexed inclusive end -> numerically equal to the
	-- 0-indexed *exclusive* end, so it's used as-is.
	srow, erow = srow - 1, erow - 1
	scol = scol - 1
	local line_len = #(vim.api.nvim_buf_get_lines(bufnr, erow, erow + 1, false)[1] or "")
	ecol = math.min(ecol, line_len)

	local lines = vim.api.nvim_buf_get_text(bufnr, srow, scol, erow, ecol, {})
	local text = table.concat(lines, "\n")

	local lead, rest = text:match("^(%s*)(.*)$")
	local new_text, added
	if rest:match("^await%s+") then
		new_text = lead .. rest:gsub("^await%s+", "", 1)
		added = false
	else
		new_text = lead .. "await " .. rest
		added = true
	end

	vim.api.nvim_buf_set_text(bufnr, srow, scol, erow, ecol, { new_text })

	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
	vim.api.nvim_feedkeys(esc, "nx", false)

	if added then
		vim.schedule(function()
			local fn_node = find_enclosing_function(bufnr, srow, scol)
			if fn_node then
				ensure_async(bufnr, fn_node)
			end
		end)
	end
end, { desc = "Toggle await on selection, auto-mark enclosing function async" })
