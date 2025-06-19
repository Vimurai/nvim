return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "github/copilot.vim" }, -- or use "zbirenbaum/copilot.lua"
		{ "nvim-lua/plenary.nvim", branch = "master" },
	},
	build = "make tiktoken", -- Optional: Only needed on macOS/Linux for token counting
	opts = {},
	-- Key mappings for Copilot Chat plugin actions in Neovim.
	-- Each mapping specifies:
	--   - key: The key combination to trigger the action.
	--   - command: The Copilot Chat command to execute.
	--   - mode: The editor mode ("n" for normal, "v" for visual).
	--   - desc: A description for discoverability in which-key or similar plugins.
	keys = (function()
		local n = "n"
		local v = "v"
		return {
			{ "<leader>zc", "<cmd>CopilotChat<CR>", mode = n, desc = "Chat with Copilot" },
			{ "<leader>zm", "<cmd>CopilotChatCommit<CR>", mode = n, desc = "Generate Commit Message" },
			{ "<leader>ze", "<cmd>CopilotChatExplain<CR>", mode = v, desc = "Explain Code" },
			{ "<leader>zr", "<cmd>CopilotChatReview<CR>", mode = v, desc = "Review Code" },
			{ "<leader>zf", "<cmd>CopilotChatFix<CR>", mode = v, desc = "Fix Code Issues" },
			{ "<leader>zo", "<cmd>CopilotChatOptimize<CR>", mode = v, desc = "Optimize Code" },
			{ "<leader>zd", "<cmd>CopilotChatDocs<CR>", mode = v, desc = "Generate Docs" },
			{ "<leader>zt", "<cmd>CopilotChatTests<CR>", mode = v, desc = "Generate Tests" },
			{ "<leader>zs", "<cmd>CopilotChatCommit<CR>", mode = v, desc = "Generate Commit for Selection" },
		}
	end)(),
}
