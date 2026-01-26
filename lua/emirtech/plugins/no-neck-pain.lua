return {
	"shortcuts/no-neck-pain.nvim",
	lazy = false, -- This plugin is often desired to be active early
	config = function()
		local no_neck_pain = require("no-neck-pain")

		no_neck_pain.setup({
			-- You can customize options here. Some common ones include:
			-- width = 0.8, -- Width of the focused window (as a fraction of total width)
			-- height = 0.8, -- Height of the focused window (as a fraction of total height)
			-- resize_delay = 0, -- Delay before resizing windows
		})

		-- Recommended keymaps for easy toggling of layouts
		local wk = require("which-key")

		wk.add({
			{
				"<leader>w",
				group = "Window Layout",
			},
			{ "<leader>wt", no_neck_pain.toggle, desc = "Toggle No-Neck-Pain Layout" },
			-- You might also want keymaps for specific layouts if the plugin supports them directly,
			-- but `toggle` is often the most used.
		})
	end,
}
