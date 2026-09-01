-- macros.lua
local langs = require("emirtech.core.macros.langs")
local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)

vim.api.nvim_create_augroup("LogMacro", { clear = true })

local pattern = vim.list_extend(vim.deepcopy(langs.js_family), { "cs" })

vim.api.nvim_create_autocmd("FileType", {
	group = "LogMacro",
	pattern = pattern,
	callback = function(args)
		local ft = vim.bo[args.buf].filetype

		if ft == "cs" then
			-- Normal mode macro for C#
			vim.fn.setreg("Q", 'yiwoConsole.WriteLine("' .. esc .. 'pa: " + ' .. esc .. "la);" .. esc)

			-- Visual mode logging for C#
			vim.keymap.set("v", "<leader>cl", function()
				vim.cmd('normal! "vy')
				local selected = vim.fn.getreg("v")
				local escaped = selected:gsub('"', '\\"')
				local line = string.format('Console.WriteLine("%s: " + %s);', escaped, selected)
				vim.api.nvim_input(esc .. "o" .. line .. esc)
			end, { desc = "Console log visual selection (C#)", buffer = args.buf })
		else
			-- Normal mode macro for JS/TS/Vue/Svelte
			vim.fn.setreg("Q", "yiwoconsole.log('" .. esc .. "pa': " .. esc .. "la," .. esc .. "pl")

			-- Visual mode logging for JS-like
			vim.keymap.set("v", "<leader>cl", function()
				vim.cmd('normal! "vy')
				local selected = vim.fn.getreg("v")
				local escaped = selected:gsub("'", "\\'")
				local line = string.format("console.log('%s:', %s);", escaped, selected)
				vim.api.nvim_input(esc .. "o" .. line .. esc)
			end, { desc = "Console log visual selection (JS)", buffer = args.buf })
		end
	end,
})

-- Optional command to reset the macro manually
vim.api.nvim_create_user_command("SetLogMacro", function()
	local ft = vim.bo.filetype
	if ft == "cs" then
		vim.fn.setreg("Q", 'yiwoConsole.WriteLine("' .. esc .. 'pa: " + ' .. esc .. "la);" .. esc)
	else
		vim.fn.setreg("Q", "yiwoconsole.log('" .. esc .. "pa': " .. esc .. "la," .. esc .. "pl")
	end
	print("Log macro set for " .. ft)
end, {})

-- Normal mode <leader>cl shortcut (works for all)
vim.keymap.set("n", "<leader>cl", "@Q", { desc = "Log word under cursor" })
