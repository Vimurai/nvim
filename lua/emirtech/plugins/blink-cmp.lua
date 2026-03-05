return {
	"saghen/blink.cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	version = "1.*",
	dependencies = {
		"rafamadriz/friendly-snippets",
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		-- 1. Add the blink-copilot dependency
		"fang2hou/blink-copilot",
	},
	opts = {
		keymap = {
			preset = "none",
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<Tab>"] = {
				"snippet_forward",
				function() -- sidekick next edit suggestion
					if require("sidekick").nes_jump_or_apply() then
						return true -- MUST return true so Blink knows to stop checking fallbacks
					end
				end,
				function() -- if you are using Neovim's native inline completions
					local inline = vim.lsp and vim.lsp.inline_completion
					if inline and type(inline.get) == "function" then
						local ok, sugg = pcall(inline.get)
						if ok and sugg ~= nil and sugg ~= false then
							inline.accept() -- Actually insert the text!
							return true -- MUST return true so Blink knows to stop checking fallbacks
						end
					end
				end,
				"fallback",
			},
		},
		appearance = {
			nerd_font_variant = "mono",
			-- Optional: Add a custom icon for Copilot so it stands out in the menu
			kind_icons = {
				Copilot = "",
			},
		},
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			menu = {
				draw = {
					treesitter = { "lsp" },
				},
			},
		},
		sources = {
			-- 2. Add 'copilot' to your default active sources list
			default = { "copilot", "lsp", "path", "snippets", "buffer" },
			-- 3. Define the provider configuration
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					score_offset = 100, -- Keeps Copilot suggestions high in the list
					async = true,
				},
			},
		},
		snippets = { preset = "luasnip" },
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
