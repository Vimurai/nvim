return {
	"kylechui/nvim-surround",
	event = { "BufReadPre", "BufNewFile" },
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	config = true,
}

-- usage:
-- Normal mode:
--  cs"'    Change surrounding from " to '
--  ds'     Delete surrounding '
--  ysaw(   Surround a word with parentheses
--  S"     Add " surrounding to entire line
--  yss"   Surround entire line with "
--  yS$"   Surround from cursor to end of line with "
--  S$"    Add " surrounding from cursor to end of line
--  S"     Add " surrounding to entire line
--  ysiW]  Surround inner WORD with []
--  ysiW<q  Surround inner WORD with <q>uotes
--  ysiW<Q  Surround inner WORD with <Q>uotes (custom)
--  ysiwQ  Surround inner word with Q (custom)
--  yswQ  Surround from cursor to end of word with Q (custom)
--  yssQ  Surround entire line with Q (custom)
--  yS$Q  Surround from cursor to end of line with Q (custom)
--  S$Q  Add Q surrounding from cursor to end of line (custom)
--  SQ  Add Q surrounding to entire line (custom)
