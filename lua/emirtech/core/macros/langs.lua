-- langs.lua: shared filetype-family + indent helpers for the macros/ modules.
--
-- Single source of truth for "which filetypes count as JS-family" so log.lua,
-- smart-docs.lua, try-catch.lua and wrap-if.lua can't drift out of sync with
-- each other (they did — smart-docs was missing svelte). Add a new language
-- family here once new languages need macro support, instead of touching
-- every macro file.

local M = {}

M.js_family = {
	"javascript",
	"typescript",
	"javascriptreact",
	"typescriptreact",
	"vue",
	"svelte",
}

function M.is_js_family(ft)
	return vim.tbl_contains(M.js_family, ft)
end

-- One level of indentation for the given buffer, respecting its actual
-- shiftwidth/expandtab instead of a hardcoded "  " or "    " guess.
function M.indent_unit(bufnr)
	bufnr = bufnr or 0
	local sw = vim.bo[bufnr].shiftwidth
	if sw == 0 then
		sw = vim.bo[bufnr].tabstop
	end
	if vim.bo[bufnr].expandtab then
		return string.rep(" ", sw)
	end
	return "\t"
end

return M
