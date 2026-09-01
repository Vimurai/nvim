-- flash.nvim: labeled jump-to-anywhere motions with treesitter integration.
--
-- `s`/`S` are already substitute.nvim's operator/eol mappings (subtitute.lua),
-- so flash lives on `gs`/`gS` instead — those are free (LSP goto-* keys are
-- all lowercase single letters via snacks.lua, no `gs`/`gS` in use).
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"gs",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash Jump",
		},
		{
			"gS",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
		{
			"<c-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
}
