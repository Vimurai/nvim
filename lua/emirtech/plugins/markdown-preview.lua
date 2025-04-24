return {
	"iamcco/markdown-preview.nvim",
	ft = { "markdown" },
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
		vim.g.mkdp_auto_start = 0
		vim.g.mkdp_auto_close = 0
		vim.g.mkdp_refresh_slow = 1
		vim.g.mkdp_open_to_the_world = 1
		vim.g.mkdp_port = "8888"
	end,
	build = "cd app && npm install",
}
