vim.keymap.set("v", "<leader>tc", function()
	local start_row = vim.fn.line("v")
	local end_row = vim.fn.line(".")
	if start_row > end_row then
		start_row, end_row = end_row, start_row
	end

	local indent = string.rep(" ", vim.fn.indent(start_row))
	local ft = vim.bo.filetype
	local selected_lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

	local try_block = {}

	-- ===== JS / TS / Vue / React / Svelte =====
	if
		vim.tbl_contains({
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"vue",
			"svelte",
		}, ft)
	then
		table.insert(try_block, indent .. "try {")
		for _, line in ipairs(selected_lines) do
			table.insert(try_block, indent .. "  " .. line)
		end
		table.insert(try_block, indent .. "} catch (e) {")
		table.insert(try_block, indent .. "  console.error(e)")
		table.insert(try_block, indent .. "}")

	-- ===== C# =====
	elseif ft == "cs" then
		table.insert(try_block, indent .. "try")
		table.insert(try_block, indent .. "{")
		for _, line in ipairs(selected_lines) do
			table.insert(try_block, indent .. "    " .. line)
		end
		table.insert(try_block, indent .. "} catch (Exception ex)")
		table.insert(try_block, indent .. "{")
		table.insert(try_block, indent .. "    Console.WriteLine(ex);")
		table.insert(try_block, indent .. "}")

	-- ===== Future Languages =====
	else
		vim.notify("try/catch macro not implemented for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, try_block)
end, { desc = "Wrap selection in try/catch (language aware)" })
