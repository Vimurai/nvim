return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "github/copilot.vim" }, -- or use "zbirenbaum/copilot.lua"
		{ "nvim-lua/plenary.nvim", branch = "master" },
	},
	build = "make tiktoken", -- Optional: Only needed on macOS/Linux for token counting
	opts = {
		prompts = {
			Rename = {
				prompt = "Please rename the variable or function to something more descriptive and meaningful based on the provided code context.",
				selection = function(selected_text)
					local select_module = require("CopilotChat.select")
					return select_module.visual(selected_text)
				end,
			},
		},
	},
	keys = {
		{ "<leader>zn", "<cmd>CopilotChatRename<CR>", mode = "v", desc = "Rename the variable or function" },
		{ "<leader>zc", "<cmd>CopilotChat<CR>", mode = "n", desc = "Chat with Copilot" },
		{ "<leader>ze", "<cmd>CopilotChatExplain<CR>", mode = "v", desc = "Explain Code" },
		{ "<leader>zr", "<cmd>CopilotChatReview<CR>", mode = "v", desc = "Review Code" },
		{ "<leader>zf", "<cmd>CopilotChatFix<CR>", mode = "v", desc = "Fix Code Issues" },
		{ "<leader>zo", "<cmd>CopilotChatOptimize<CR>", mode = "v", desc = "Optimize Code" },
		{ "<leader>zd", "<cmd>CopilotChatDocs<CR>", mode = "v", desc = "Generate Docs" },
		{ "<leader>zt", "<cmd>CopilotChatTests<CR>", mode = "v", desc = "Generate Tests" },
		{ "<leader>zm", "<cmd>CopilotChatCommit<CR>", mode = "n", desc = "Generate Commit Message" },
		{ "<leader>zs", "<cmd>CopilotChatCommit<CR>", mode = "v", desc = "Generate Commit for Selection" },
	},
}
