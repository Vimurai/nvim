-- strip-logs.lua: remove debug log lines from the current buffer — the
-- console.log(...) statements <leader>cl (log.lua) inserts, or ones added by
-- hand. Counterpart to <leader>cl the way `Q` register is to `q`.
local langs = require("emirtech.core.macros.langs")

-- Matches a *standalone* debug-log statement line (the shape log.lua always
-- generates): `console.log(...)`, `console.debug(...)`, `console.info(...)`.
-- console.error/warn are left alone — those are usually deliberate error
-- surfacing (e.g. the catch blocks <leader>tc inserts), not debug noise.
local function is_js_log_line(trimmed)
	for _, kind in ipairs({ "log", "debug", "info" }) do
		if trimmed:match("^console%." .. kind .. "%(.*%)%s*;?$") then
			return true
		end
	end
	return false
end

vim.api.nvim_create_user_command("StripLogs", function()
	local ft = vim.bo.filetype
	local bufnr = 0

	local matcher
	if langs.is_js_family(ft) then
		matcher = is_js_log_line
	elseif ft == "cs" then
		matcher = function(trimmed)
			return trimmed:match("^Console%.WriteLine%(.*%)%s*;?$") ~= nil
		end
	else
		vim.notify("StripLogs not implemented for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local kept = {}
	local removed = 0

	for _, line in ipairs(lines) do
		local trimmed = line:match("^%s*(.-)%s*$")
		if matcher(trimmed) then
			removed = removed + 1
		else
			table.insert(kept, line)
		end
	end

	if removed == 0 then
		vim.notify("No debug log lines found", vim.log.levels.INFO)
		return
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, kept)
	vim.notify(string.format("Stripped %d debug log line%s", removed, removed == 1 and "" or "s"), vim.log.levels.INFO)
end, {})

vim.keymap.set("n", "<leader>cL", ":StripLogs<CR>", { desc = "Strip debug log lines (JS/C#)" })
