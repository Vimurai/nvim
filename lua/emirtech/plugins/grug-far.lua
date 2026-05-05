return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	opts = {
		headerMaxWidth = 80,
	},
	keys = {
		{
			"<leader>sr",
			function()
				require("grug-far").open({ transient = true })
			end,
			desc = "Search & Replace (project)",
		},
		{
			"<leader>sR",
			function()
				local ft = vim.bo.filetype
				require("grug-far").open({
					transient = true,
					prefills = { filesFilter = "*." .. (vim.fn.expand("%:e") ~= "" and vim.fn.expand("%:e") or "*") },
				})
			end,
			desc = "Search & Replace (current ext)",
		},
		{
			"<leader>sw",
			function()
				require("grug-far").open({ transient = true, prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Search & Replace (word under cursor)",
		},
		{
			"<leader>sv",
			function()
				require("grug-far").with_visual_selection({ transient = true })
			end,
			mode = "v",
			desc = "Search & Replace (visual selection)",
		},
	},
}
