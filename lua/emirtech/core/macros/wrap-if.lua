local langs = require("emirtech.core.macros.langs")

vim.keymap.set("v", "<leader>if", function()
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
	local start_row = vim.fn.line("v")
	local end_row = vim.fn.line(".")
	if start_row > end_row then
		start_row, end_row = end_row, start_row
	end

	local indent = string.rep(" ", vim.fn.indent(start_row))
	local unit = langs.indent_unit()
	local ft = vim.bo.filetype
	local selected_lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

	local wrapped = {}
	local cursor_row, cursor_col = start_row, 0

	-- ===== JS / TS / Vue / React / Svelte =====
	if langs.is_js_family(ft) then
		table.insert(wrapped, indent .. "if () {")
		for _, line in ipairs(selected_lines) do
			table.insert(wrapped, indent .. unit .. line)
		end
		table.insert(wrapped, indent .. "}")
		cursor_row = start_row
		cursor_col = #indent + 4 -- after `if (`

	-- ===== C# =====
	elseif ft == "cs" then
		table.insert(wrapped, indent .. "if ()")
		table.insert(wrapped, indent .. "{")
		for _, line in ipairs(selected_lines) do
			table.insert(wrapped, indent .. "    " .. line)
		end
		table.insert(wrapped, indent .. "}")
		cursor_row = start_row
		cursor_col = #indent + 4 -- after `if (`

	-- ===== Other Language Placeholder =====
	else
		vim.notify("Wrap-if macro not implemented for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	-- Replace selected lines with wrapped version
	vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, wrapped)

	-- Exit visual mode before cursor jump
	vim.api.nvim_feedkeys(esc, "x", false)

	-- Move cursor and enter insert mode after visual exit is processed
	vim.schedule(function()
		vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_col })
		vim.api.nvim_feedkeys("i", "n", true)
	end)
end, { desc = "Wrap selection in if() and focus condition" })
