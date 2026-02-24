return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && npm install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
		vim.g.mkdp_auto_start = 0
		vim.g.mkdp_auto_close = 0
		vim.g.mkdp_echo_preview_url = 1
		vim.cmd([[
      function! OpenMarkdownPreview (url)
        execute "silent ! open -a 'Google Chrome' " . shellescape(a:url)
      endfunction
    ]])
		vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
		vim.env.NVIM_MKDP_LOG_FILE = vim.fn.stdpath("cache") .. "/mkdp.log"
		vim.env.NVIM_MKDP_LOG_LEVEL = "debug"
	end,
	ft = { "markdown" },
}
