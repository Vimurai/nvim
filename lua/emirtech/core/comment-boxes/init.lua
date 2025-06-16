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

local function with_input(fn)
	vim.ui.input({ prompt = "Box Title:" }, function(input)
		if input and #input > 0 then
			fn(input)
		end
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
			TaskList = "t",
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
