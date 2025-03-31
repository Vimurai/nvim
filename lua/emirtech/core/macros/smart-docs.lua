vim.api.nvim_create_user_command("SmartDocBlock", function()
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
	local ft = vim.bo.filetype
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

	local indent = line:match("^(%s*)") or ""
	local name, args, returns = nil, nil, false
	local doc = {}

	-- ===== JS / TS =====
	if ft:match("javascript") or ft:match("typescript") or ft:match("vue") then
		name, args = line:match("function%s+([%w_]+)%s*%((.-)%)")
		if not name then
			name, args = line:match("const%s+([%w_]+)%s*=%s*%((.-)%)%s*=>")
		end
		if not name then
			vim.notify("Couldn't detect JS/TS function", vim.log.levels.WARN)
			return
		end

		-- 🔁 Look inside the full function body by tracking brace count
		local total_lines = vim.api.nvim_buf_line_count(0)
		local open_braces = 0
		local inside_function = false

		for i = row - 1, total_lines - 1 do
			local l = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
			if l then
				if l:find("{") then
					open_braces = open_braces + select(2, l:gsub("{", ""))
					inside_function = true
				end
				if l:find("}") then
					open_braces = open_braces - select(2, l:gsub("}", ""))
				end

				if inside_function and l:match("%s*return%s+") then
					returns = true
				end

				if inside_function and open_braces == 0 then
					break -- end of function
				end
			end
		end

		table.insert(doc, indent .. "/**")
		table.insert(doc, indent .. " * " .. name .. " — TODO: Describe this function")
		for param in (args or ""):gmatch("([%w_]+)") do
			table.insert(doc, indent .. " * @param {*} " .. param)
		end
		if returns then
			table.insert(doc, indent .. " * @returns {*} result")
		end
		table.insert(doc, indent .. " */")

	-- ===== C# =====
	elseif ft == "cs" then
		args = line:match("%((.-)%)")
		name = line:match("[%s%w]*%s+([%w_]+)%s*%b()%s*{?")

		if not name or not args then
			vim.notify("Couldn't detect C# method", vim.log.levels.WARN)
			return
		end

		-- Infer return from type (non-void)
		returns = not line:match("void%s+" .. name)

		table.insert(doc, indent .. "/// <summary>")
		table.insert(doc, indent .. "/// " .. name .. " — TODO: Describe this method")
		table.insert(doc, indent .. "/// </summary>")
		for type_, param in args:gmatch("([%w_%.<>]+)%s+([%w_]+)") do
			table.insert(doc, string.format(indent .. '/// <param name="%s"></param>', param))
		end
		if returns then
			table.insert(doc, indent .. "/// <returns></returns>")
		end
	else
		vim.notify("SmartDocBlock not implemented for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	-- Insert above current line
	vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, doc)

	-- Move to summary line for Copilot suggestions
	vim.api.nvim_win_set_cursor(0, { row - #doc + 2, #indent + 4 }) -- cursor inside summary
	vim.api.nvim_feedkeys("i", "n", true)
end, {})

vim.keymap.set("n", "<leader>sd", ":SmartDocBlock<CR>", { desc = "Smart Doc Block (JS/C#)" })
