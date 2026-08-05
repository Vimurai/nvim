-- Neovim >= 0.12 renders Copilot as native ghost text via
-- vim.lsp.inline_completion (enabled in sidekick.lua). On those versions the
-- completion-menu source would surface the same suggestions a second time, so
-- it is dropped. On 0.11 the native engine does not exist and this source is
-- the only Copilot surface there is — removing it unconditionally would leave
-- no suggestions at all.
local has_native_inline = vim.lsp.inline_completion ~= nil

local sources = has_native_inline and { "lsp", "path", "snippets", "buffer" }
	or { "copilot", "lsp", "path", "snippets", "buffer" }

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
				function() -- native inline completion (Neovim >= 0.12)
					-- get() IS the accept: it applies the displayed candidate and
					-- returns whether one was applied. The API has no accept()
					-- (:h lsp-inline_completion), so calling one throws.
					local inline = vim.lsp and vim.lsp.inline_completion
					if inline and type(inline.get) == "function" and inline.get() then
						return true -- MUST return true so Blink knows to stop checking fallbacks
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
			default = sources,
			-- Provider stays defined either way; it is simply not in `default`
			-- on 0.12, so it costs nothing and can be re-enabled by hand.
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
