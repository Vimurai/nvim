-- Neovim >= 0.12 renders Copilot as native ghost text via
-- vim.lsp.inline_completion (enabled in sidekick.lua). On those versions the
-- completion-menu source would surface the same suggestions a second time, so
-- it is dropped. On 0.11 the native engine does not exist and this source is
-- the only Copilot surface there is — removing it unconditionally would leave
-- no suggestions at all.
local has_native_inline = vim.lsp.inline_completion ~= nil

local sources = has_native_inline and { "lazydev", "lsp", "path", "snippets", "buffer" }
	or { "lazydev", "copilot", "lsp", "path", "snippets", "buffer" }

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
			-- Accepts only when you have actually selected something with <C-j>/<C-k>.
			-- With preselect off (see completion.list below) nothing is selected by
			-- default, so this falls through to a real newline.
			["<CR>"] = { "accept", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			-- Tab only ever acts at the cursor. It never moves you.
				--
				-- Next Edit Suggestions used to run here, ahead of inline completion.
				-- nes_jump_or_apply() is `Nes.jump() or Nes.apply()`, so whenever
				-- Copilot had a suggestion elsewhere in the file it won the race,
				-- threw the cursor across the buffer and edited there — even though
				-- ghost text was sitting under the cursor waiting to be accepted.
				-- NES now lives on <M-Tab> in insert mode and <Tab> in normal mode.
				["<Tab>"] = {
					-- 1. Ghost text at the cursor: the thing you are looking at.
					--    get() IS the accept — it applies the candidate and returns
					--    whether it did. The API has no accept() (:h
					--    lsp-inline_completion), so calling one throws.
					function()
						local inline = vim.lsp and vim.lsp.inline_completion
						if inline and type(inline.get) == "function" and inline.get() then
							return true -- stop checking fallbacks
						end
					end,
					-- 2. Snippet placeholders you are already inside.
					"snippet_forward",
					-- 3. A literal tab.
					"fallback",
				},
				-- Opt in to a Next Edit Suggestion without leaving insert mode.
				["<M-Tab>"] = {
					function()
						if require("sidekick").nes_jump_or_apply() then
							return true
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
			list = {
				selection = {
					-- blink defaults both of these to true, which is why <CR> kept
					-- accepting completions nobody chose: the first item was selected
					-- the instant the menu appeared, so Enter-for-a-newline accepted
					-- it instead. Nothing is selected now until you press <C-j>/<C-k>.
					preselect = false,
					-- Selecting no longer writes the item into the buffer as you move
					-- through the list; text only lands when you accept.
					auto_insert = false,
				},
			},
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
				-- lazydev supplies `vim.*` API completions in Lua config files;
				-- outranks lua_ls's own (often wrong) suggestions for those.
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		snippets = { preset = "luasnip" },
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
