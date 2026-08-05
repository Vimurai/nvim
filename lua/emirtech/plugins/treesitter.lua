-- nvim-treesitter, `main` branch.
--
-- The `master` branch states outright that "Neovim 0.12 is not supported", and
-- on 0.12.4 it throws from query_predicates.lua: match values are now lists of
-- nodes rather than a single node, so get_node_text() receives a table and
-- node:range() blows up inside the highlighter's decoration provider.
--
-- `main` is a rewrite, not a version bump. Three things it does differently:
--   * it cannot be lazy-loaded, hence `lazy = false`
--   * it enables nothing by default — highlighting, indent and folds are Neovim
--     features you turn on yourself, per filetype
--   * `incremental_selection` no longer exists, so the old <CR>/<BS> expand and
--     shrink mappings are gone with no in-plugin replacement
--
-- Parser installs now need the tree-sitter CLI (>= 0.26.1) on PATH:
--   brew install tree-sitter-cli
--
-- The list is explicit because `main` dropped `auto_install`. Everything below
-- the first block was picked up automatically under the old config and is kept
-- so nothing silently loses highlighting.
local parsers = {
	-- previously ensure_installed
	"bash",
	"c",
	"c_sharp",
	"css",
	"dockerfile",
	"gitignore",
	"graphql",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"prisma",
	"query",
	"razor",
	"scss",
	"svelte",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"vue",
	"yaml",
	-- previously acquired via auto_install
	"astro",
	"cmake",
	"cpp",
	"csv",
	"editorconfig",
	"git_config",
	"gitcommit",
	"go",
	"gomod",
	"http",
	"ini",
	"latex",
	"make",
	"nginx",
	"pem",
	"php",
	"python",
	"regex",
	"robots_txt", -- was `robots` on master; renamed upstream
	"sql",
	"ssh_config",
	"toml",
	"typst",
	"xml",
	-- Dropped in the move: `jsonc` and `tmux` are not in main's registry.
	-- jsonc files fall back to the json parser; tmux has no parser here.
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- main does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			-- Asynchronous, and a no-op for parsers already present, so this is
			-- cheap on every start after the first.
			require("nvim-treesitter").install(parsers)

			-- `main` ships no auto-enable, so highlighting and indent are wired
			-- up here. pcall because a filetype with no installed parser raises,
			-- and a missing parser should degrade to plain syntax rather than
			-- error on every buffer.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("emirtech_treesitter", { clear = true }),
				callback = function(args)
					if pcall(vim.treesitter.start, args.buf) then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
	{
		-- Previously nested under treesitter's `autotag` key, which only the
		-- master-branch config module understood. It has its own setup now.
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			},
		},
	},
}
