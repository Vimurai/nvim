local home = vim.fn.expand("$HOME")

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"williamboman/mason.nvim",
			"nvim-neotest/nvim-nio",
			"Cliffback/netcoredbg-macOS-arm64.nvim",
		},
		event = "VeryLazy",
		config = function()
			local dap = require("dap")
			-- setup netcoredbg adapter
			require("netcoredbg-macOS-arm64").setup(dap)

			-- C#/.NET
			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch C# (netcoredbg)",
					request = "attach",
					cwd = home .. "/Documents/development/Repos/test",
					program = function()
						local proj = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
						return vim.fn.getcwd() .. "/bin/Debug/net9.0/" .. proj .. ".dll"
					end,
					stopAtEntry = true,
				},
			}

			-- Node.js
			dap.adapters.node2 = {
				type = "executable",
				command = "node",
				args = {
					home .. "/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js",
					"--stdio",
				},
			}
			dap.configurations.javascript = {
				{
					name = "Launch JS (Node)",
					type = "node2",
					request = "launch",
					program = "${file}",
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
					protocol = "inspector",
					console = "integratedTerminal",
				},
			}
			dap.configurations.typescript = {
				{
					name = "Launch TS (ts-node)",
					type = "node2",
					request = "launch",
					program = "${file}",
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
					protocol = "inspector",
					runtimeExecutable = "ts-node",
				},
			}

			-- keymaps: <leader>d{c|s|n|o|b|r|l}
			local map = vim.keymap.set
			map("n", "<leader>dc", dap.continue, { desc = "DAP Continue" })
			map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
			map("n", "<leader>ds", dap.step_over, { desc = "DAP Step Over" })
			map("n", "<leader>dn", dap.step_into, { desc = "DAP Step Into" })
			map("n", "<leader>do", dap.step_out, { desc = "DAP Step Out" })
			map("n", "<leader>dr", dap.repl.open, { desc = "DAP Open REPL" })
			map("n", "<leader>dl", dap.run_last, { desc = "DAP Run Last" })
			map("n", "<leader>dt", function()
				if require("dapui").is_open() then
					require("dapui").close()
				else
					require("dapui").open()
				end
			end, { desc = "DAP Toggle UI" })
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		event = "VeryLazy",
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
				mappings = {
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				layouts = {
					{
						elements = { { id = "scopes", size = 0.25 }, "breakpoints", "stacks", "watches" },
						size = 40,
						position = "left",
					},
					{ elements = { "repl", "console" }, size = 0.25, position = "bottom" },
				},
				controls = {
					enabled = true,
					element = "repl",
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "◀",
						run_last = "↻",
						terminate = "⏹",
					},
				},
				floating = {
					border = "rounded",
					mappings = { close = { "q", "<Esc>" } },
				},
				windows = { indent = 1 },
			})

			dap.listeners.after.event_initialized["dapui"] = dapui.open
			dap.listeners.before.event_terminated["dapui"] = dapui.close
			dap.listeners.before.event_exited["dapui"] = dapui.close

			-- macOS-style breakpoint sign
			vim.fn.sign_define("DapBreakpoint", {
				text = "●",
				texthl = "Error",
				linehl = "",
				numhl = "",
			})
		end,
	},
}
