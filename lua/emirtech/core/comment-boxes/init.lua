-- ~/.config/nvim/lua/commentboxes/init.lua
-- 🌟 Beautiful macOS‐style Smart Comment Boxes

local M = {}

-- 1) Fallback table for all non‐Vue filetypes, or when TS commentstring isn't set.
local DEFAULT_TOKENS = {
	lua = "--",
	python = "#",
	javascript = "//",
	typescript = "//",
	c = "//",
	cpp = "//",
	java = "//",
	cs = "//",
	html = "<!--",
	xml = "<!--",
	css = "/*",
	scss = "/*",
	json = "//",
	sh = "#",
	bash = "#",
	go = "//",
	rust = "//",
	php = "//",
	ruby = "#",
}

-- 1) Helpers: count regex matches in lines[1..cursor_row]
local function count_matches(lines, pat)
	local total = 0
	for _, line in ipairs(lines) do
		-- gsub returns (new_str, count)
		total = total + select(2, line:gsub(pat, ""))
	end
	return total
end

-- 2) Detect whether cursor is in a <script> or <style> block
local function get_vue_comment_prefix()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	-- grab all lines up to (and including) current
	local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)

	-- count opens and closes for <script ...>
	local opens = count_matches(lines, "<script[^>]*>")
	local closes = count_matches(lines, "</script>")
	if opens > closes then
		return "// ", ""
	end

	-- count opens and closes for <style ...>
	opens = count_matches(lines, "<style[^>]*>")
	closes = count_matches(lines, "</style>")
	if opens > closes then
		return "/* ", " */"
	end

	-- fallback: template/html
	return "<!-- ", " -->"
end

-- 3) Hook it into your master chooser
local has_tscc, tscc = pcall(require, "ts_context_commentstring.internal")

local function get_comment_prefix()
	if vim.bo.filetype == "vue" then
		return get_vue_comment_prefix()
	end

	-- your existing ts_context_commentstring or DEFAULT_TOKENS logic here
	if has_tscc then
		local cs = tscc.calculate_commentstring({ key = "__default", location = nil })
		if cs and cs:find("%%s") then
			return cs:match("^(.-)%%s(.-)$")
		end
	end

	local tok = DEFAULT_TOKENS[vim.bo.filetype] or "//"
	if tok == "<!--" then
		return "<!-- ", " -->"
	elseif tok == "/*" then
		return "/* ", " */"
	else
		return tok .. " ", ""
	end
end

-- 5) Core utilities
local function insert_lines(lines)
	vim.api.nvim_put(lines, "l", true, true)
end

local function center_text(text, width)
	local pad = math.floor((width - #text) / 2)
	return string.rep(" ", pad) .. text .. string.rep(" ", width - #text - pad)
end

local function make_box(content, top_char, mid_tmpl, bot_char)
	local open, close = get_comment_prefix()
	local w = math.max(24, #content + 8)
	insert_lines({
		open .. "╭" .. top_char:rep(w) .. "╮" .. close,
		open .. mid_tmpl:gsub("%%s", center_text(content, w)) .. close,
		open .. "╰" .. bot_char:rep(w) .. "╯" .. close,
	})
end

-- Find the next function/class/block below the cursor.
-- Returns { code = string, row = number (1-based) } or nil.
local function find_next_function_below()
	local cur_row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
	local total = vim.api.nvim_buf_line_count(0)

	-- Try Treesitter: walk the full tree for the first function-like node below cursor
	local ok_lang, parser = pcall(vim.treesitter.get_parser, 0)
	if ok_lang and parser then
		local tree = parser:parse()[1]
		if tree then
			local root = tree:root()
			local result = nil
			local function walk(node)
				if result then
					return
				end
				local t = node:type()
				local sr, _, er, _ = node:range() -- 0-based
				local node_start_1 = sr + 1
				if
					node_start_1 > cur_row
					and (
						t:match("function")
						or t:match("method")
						or t:match("class")
						or t:match("declaration")
						or t:match("definition")
					)
				then
					local lines = vim.api.nvim_buf_get_lines(0, sr, er + 1, false)
					if #lines > 0 then
						result = { code = table.concat(lines, "\n"), row = node_start_1 }
					end
					return
				end
				for child in node:iter_children() do
					walk(child)
				end
			end
			walk(root)
			if result then
				return result
			end
		end
	end

	-- Fallback: regex scan for function-like lines
	local patterns = {
		"^%s*function%s",
		"^%s*local%s+function%s",
		"^%s*def%s+",
		"^%s*class%s+",
		"^%s*public%s+",
		"^%s*private%s+",
		"^%s*protected%s+",
		"^%s*async%s+function",
		"^%s*export%s+",
	}
	for r = cur_row + 1, total do
		local line = vim.api.nvim_buf_get_lines(0, r - 1, r, false)[1] or ""
		for _, pat in ipairs(patterns) do
			if line:match(pat) then
				local lines = vim.api.nvim_buf_get_lines(0, r - 1, math.min(r + 19, total), false)
				return { code = table.concat(lines, "\n"), row = r }
			end
		end
	end

	return nil
end

-- Read exactly `n` lines below the cursor (plain slice).
local function get_lines_below_cursor(n)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local total = vim.api.nvim_buf_line_count(0)
	local lines = vim.api.nvim_buf_get_lines(0, row, math.min(row + n, total), false)
	return table.concat(lines, "\n")
end

local function ask_copilot(prompt, fallback, fn)
	local ok, chat = pcall(require, "CopilotChat")
	if not ok or not chat.ask then
		fn(fallback)
		return
	end

	local success = pcall(chat.ask, prompt, {
		headless = true,
		callback = function(res)
			local refined = res and res.content and res.content:match("^%s*(.-)%s*$")
			vim.schedule(function()
				fn((refined and #refined > 0) and refined or fallback)
			end)
		end,
	})

	if not success then
		fn(fallback)
	end
end

local function summarise_prompt(code)
	return "Summarize the following code into a short, professional title for a comment box header. "
		.. "Rules: title case, max 40 characters, no trailing punctuation, output ONLY the title text, nothing else.\n\n"
		.. "```\n"
		.. code
		.. "\n```"
end

local function with_input(fn)
	vim.ui.input({ prompt = "Box Title (empty=auto, number=N lines):" }, function(input)
		-- ── 1. NUMBER INPUT: capture next N lines → generate title ───────────────
		local n = input and tonumber(input:match("^%s*(%d+)%s*$"))
		if n then
			local code = get_lines_below_cursor(n)
			if not code or #code:match("^%s*(.-)%s*$") == 0 then
				fn("Section")
				return
			end
			ask_copilot(summarise_prompt(code), "Section", fn)
			return
		end

		-- ── 2. EMPTY INPUT: find next function → move cursor above it → generate ─
		if not input or input:match("^%s*$") then
			local found = find_next_function_below()
			if not found then
				fn("Section")
				return
			end
			-- Place cursor on the line just above the function so nvim_put inserts there
			local target_row = math.max(1, found.row - 1)
			vim.api.nvim_win_set_cursor(0, { target_row, 0 })
			ask_copilot(summarise_prompt(found.code), "Section", fn)
			return
		end

		-- ── 3. TEXT INPUT: refine/clean the title ────────────────────────────────
		local prompt = "Rewrite the following into a short, professional title suitable for a code comment box. "
			.. "Rules: title case, max 40 characters, no trailing punctuation, output ONLY the title text, nothing else.\n\n"
			.. "Input: "
			.. input
		ask_copilot(prompt, input, fn)
	end)
end

-- 6) Public API: six styles
function M.BoxRounded(t)
	make_box(t, "━", "│%s│", "━")
end

function M.BoxThick(t)
	make_box(t, "═", "║%s║", "═")
end

-- ── 📌 Minimal box ─────────────────────────────
function M.BoxMinimal(t)
	local o, c = get_comment_prefix()
	local txt = t or "📌 Info"
	insert_lines({ o .. "── " .. "📌 " .. txt .. " " .. ("─"):rep(40 - #txt) .. c })
end

-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
--    📋 Task list
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
function M.BoxTaskList(t)
	local o, c = get_comment_prefix()
	local txt = t or "📋 Task List"
	insert_lines({
		o .. ("░"):rep(32) .. c,
		o .. "   " .. "📋 " .. txt .. c,
		o .. ("░"):rep(32) .. c,
	})
end

-- 🌟╌╌╌╌╌╌╌╌╌╌🌟
--  ⎸ Bubbleee ⎹
-- 🌟╌╌╌╌╌╌╌╌╌╌🌟
function M.BoxBubble(t)
	local o, c = get_comment_prefix()
	local w = #t + 2
	insert_lines({
		o .. "🌟" .. ("╌"):rep(w) .. "🌟" .. c,
		o .. " ⎸ " .. t .. " ⎹" .. c,
		o .. "🌟" .. ("╌"):rep(w) .. "🌟" .. c,
	})
end

function M.BoxSeparator(t)
	local o, c = get_comment_prefix()
	local txt = t or "✨ Separator"

	local w = 60 - #txt - 4
	insert_lines({ o .. "─── " .. "✨ " .. txt .. " " .. ("─"):rep(w) .. c })
end

-- 🚀──▶▶ Start section ▶▶──🚀
function M.BoxStartSection(t)
	local o, c = get_comment_prefix()
	local txt = t or "Start Section"
	insert_lines({
		o .. "🚀──▶▶ " .. txt .. " ▶▶──🚀" .. c,
	})
end
-- ╭•••••••••••╮
-- │ 🐞  Bug   │
-- ╰•••••••••••╯
-- 🐞 BUG Box: for pesky bugs
function M.BoxBug(t)
	local o, c = get_comment_prefix()
	local txt = t or "BUG"
	local w = #txt + 8
	insert_lines({
		o .. "╭" .. ("•"):rep(w) .. "╮" .. c,
		o .. "│ 🐞  " .. txt .. "   │" .. c,
		o .. "╰" .. ("•"):rep(w) .. "╯" .. c,
	})
end

-- ⚡━━━━━━━━━━━━━━━━━━━━━━━━⚡
--   Highlight
-- ⚡━━━━━━━━━━━━━━━━━━━━━━━━⚡
-- ⚡ HIGHLIGHT Box: spotlight a snippet
function M.BoxHighlight(t)
	local o, c = get_comment_prefix()
	local txt = t or "Highlight"
	local w = math.max(24, #txt + 4)
	insert_lines({
		o .. "⚡" .. ("━"):rep(w) .. "⚡" .. c,
		o .. "  " .. txt .. string.rep(" ", w - #txt) .. c,
		o .. "⚡" .. ("━"):rep(w) .. "⚡" .. c,
	})
end

-- 🛑◀◀── Box end ──◀◀🛑
function M.BoxEndSection(t)
	local o, c = get_comment_prefix()
	local txt = t or "End Section"
	insert_lines({
		o .. "🛑◀◀── " .. txt .. " ──◀◀🛑" .. c,
	})
end

-- 7) Install commands & mappings
function M.setup()
	for name, fn in pairs({
		Rounded = M.BoxRounded,
		Thick = M.BoxThick,
		Minimal = M.BoxMinimal,
		Bubble = M.BoxBubble,
		Separator = M.BoxSeparator,
		StartSection = M.BoxStartSection,
		EndSection = M.BoxEndSection,
		TaskList = M.BoxTaskList,
		Bug = M.BoxBug,
		Highlight = M.BoxHighlight,
	}) do
		vim.api.nvim_create_user_command("Box" .. name, function()
			with_input(fn)
		end, {})
		-- `<leader>b` + initial
		local key = ({
			Rounded = "r",
			Thick = "t",
			Minimal = "m",
			TaskList = "l",
			Bubble = "b",
			Separator = "S",
			StartSection = "s",
			EndSection = "e",
			Bug = "B",
			Highlight = "H",
		})[name]
		vim.keymap.set("n", "<leader>b" .. key, function()
			with_input(fn)
		end, { desc = "Box" .. name })
	end
end

return M
