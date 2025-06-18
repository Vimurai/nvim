return {
	-- Harpoon.nvim
	"ThePrimeagen/harpoon", -- the plugin repo
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", "<leader>pl", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: Toggle quick menu" })
		vim.keymap.set("n", "<leader>pa", function()
			harpoon:list():add()
		end, { desc = "Harpoon: Add file" })
		vim.keymap.set("n", "<leader>pn", function()
			harpoon:list():next()
		end, { desc = "Harpoon: Next mark" })
		vim.keymap.set("n", "<leader>pp", function()
			harpoon:list():prev()
		end, { desc = "Harpoon: Prev mark" })

		-- Direct navigation mappings
		for i = 1, 9 do
			vim.keymap.set("n", "<leader>" .. i, function()
				harpoon:list():select(i)
			end, { desc = "Harpoon: Go to mark #" .. i })
		end
	end,
}
