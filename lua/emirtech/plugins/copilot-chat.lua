return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "github/copilot.vim" }, -- or "zbirenbaum/copilot.lua"
		{ "nvim-lua/plenary.nvim", branch = "master" },
		{ "folke/which-key.nvim" },
	},
	lazy = false,
	build = "make tiktoken",

	opts = function()
		-- keep prompts simple; we'll handle selection manually in the keymap actions
		return {
			prompts = {
				Rename = {
					prompt = "Rename to a clearer, domain-meaningful name based on context.",
					-- selection is optional here (handled by talk_* functions)
				},
				ExplainLikeSenior = {
					prompt = "Explain senior-level: goals, data flow, invariants, trade-offs, risks.",
				},
				ExplainLikeJunior = {
					prompt = "Explain for a beginner: what it does, step-by-step with a tiny example.",
				},
			},
		}
	end,

	config = function(_, opts)
		local chat = require("CopilotChat")
		chat.setup(opts)

		local wk = require("which-key")

		-- ---------- raw text capture (visual OR entire buffer) ----------
		local function get_visual_text_or_nil()
			-- only works if we're in visual mode or visual selection is active
			local mode = vim.fn.mode()
			if mode ~= "v" and mode ~= "V" and mode ~= "\22" then -- \22 = CTRL-V (block)
				return nil
			end
			local _, cs_row, cs_col, _ = unpack(vim.fn.getpos("v"))
			local _, ce_row, ce_col, _ = unpack(vim.fn.getpos("."))
			-- normalize order
			if (ce_row < cs_row) or (ce_row == cs_row and ce_col < cs_col) then
				cs_row, ce_row = ce_row, cs_row
				cs_col, ce_col = ce_col, cs_col
			end
			local lines = vim.api.nvim_buf_get_lines(0, cs_row - 1, ce_row, false)
			if #lines == 0 then
				return ""
			end
			if #lines == 1 then
				lines[1] = string.sub(lines[1], cs_col, ce_col)
			else
				lines[1] = string.sub(lines[1], cs_col)
				lines[#lines] = string.sub(lines[#lines], 1, ce_col)
			end
			return table.concat(lines, "\n")
		end

		local function get_entire_buffer_text()
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			return table.concat(lines, "\n")
		end

		local function current_context()
			return {
				language = vim.bo.filetype or "",
				filename = vim.fn.expand("%:p") ~= "" and vim.fn.expand("%:p") or nil,
			}
		end

		-- ask with selection text (string), falling back to full buffer
		local function ask_with_buffer_fallback(prompt)
			local text = get_visual_text_or_nil()
			if not text or #text == 0 then
				text = get_entire_buffer_text()
			end
			if not text or #text == 0 then
				vim.notify("CopilotChat: current buffer is empty.", vim.log.levels.WARN)
				return
			end

			-- Provide selection as a function that returns a string
			chat.ask(prompt, {
				selection = function(_)
					return text
				end,
				context = current_context(),
			})
		end

		-- ------------------------------- keymaps -------------------------------
		wk.add({
			-- Panel
			{ "<leader>zz", "<cmd>CopilotChat<CR>", desc = "CopilotChat: Open panel", mode = "n" },

			-- Talk (sel/buffer) — this is your <leader>zt
			{
				"<leader>zt",
				function()
					ask_with_buffer_fallback(
						"Let's discuss this code. Summarize in 3 bullets, list risks, then ask me one clarifying question."
					)
				end,
				desc = "CopilotChat: Talk (sel/buffer)",
				mode = "n",
			},

			-- Explain helpers using the same robust selection
			{
				"<leader>zes",
				function()
					ask_with_buffer_fallback("Explain senior-level: goals, data flow, invariants, trade-offs, risks.")
				end,
				desc = "CopilotChat: Explain (Senior)",
				mode = "n",
			},
			{
				"<leader>zej",
				function()
					ask_with_buffer_fallback("Explain for a beginner: what it does, step-by-step with a tiny example.")
				end,
				desc = "CopilotChat: Explain (Junior)",
				mode = "n",
			},
		})

		-- Visual mode mirrors
		wk.add({
			{
				"<leader>zt",
				function()
					ask_with_buffer_fallback(
						"Let's discuss this code. Summarize in 3 bullets, list risks, then ask me one clarifying question."
					)
				end,
				desc = "CopilotChat: Talk about selection",
				mode = "v",
			},
			{
				"<leader>zes",
				function()
					ask_with_buffer_fallback("Explain senior-level: goals, data flow, invariants, trade-offs, risks.")
				end,
				desc = "CopilotChat: Explain Senior (Sel.)",
				mode = "v",
			},
			{
				"<leader>zej",
				function()
					ask_with_buffer_fallback("Explain for a beginner: what it does, step-by-step with a tiny example.")
				end,
				desc = "CopilotChat: Explain Junior (Sel.)",
				mode = "v",
			},
		})
	end,
}
