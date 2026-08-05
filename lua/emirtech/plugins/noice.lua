return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
				progress = { enabled = true },
				hover = { enabled = true, silent = true },
				signature = { enabled = false }, -- using ray-x/lsp_signature instead
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			routes = {
				-- silence noisy LSP "no information available" hovers
				{ filter = { event = "msg_show", find = "No information available" }, opts = { skip = true } },
				-- silence the Copilot didChange clamp warnings (ours, from earlier debugging)
				{
					filter = { event = "notify", find = "AgentTextDocumentConfiguration" },
					opts = { skip = true },
				},
			},
		},
	},
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 2500,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.40)
			end,
			stages = "fade",
			render = "compact",
			fps = 60,
		},
	},
	{
		"rachartier/tiny-glimmer.nvim",
		event = "VeryLazy",
		opts = {
			enabled = true,
			default_animation = "fade",
			refresh_interval_ms = 8,
			overwrite = {
				yank = { enabled = true, default_animation = "fade" },
				paste = { enabled = true, default_animation = "reverse_fade" },
				undo = { enabled = true, default_animation = "fade" },
				redo = { enabled = true, default_animation = "fade" },
				search = { enabled = false }, -- can feel noisy with regex search
			},
			transparency_color = nil,
		},
	},
}
