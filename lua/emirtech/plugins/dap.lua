return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"williamboman/mason.nvim",
			"nvim-neotest/nvim-nio",
			"Cliffback/netcoredbg-macOS-arm64.nvim",
			"mxsdev/nvim-dap-vscode-js",
			"folke/which-key.nvim",
			{
				"microsoft/vscode-js-debug",
				version = "1.x",
				build = "npm i && npm run compile vsDebugServerBundle && mv dist out",
			},
		},
		event = "VeryLazy",
		config = function()
			local dap = require("dap")

			-----------------------------------------------------------------------
			-- .NET (C#)
			-----------------------------------------------------------------------
			require("netcoredbg-macOS-arm64").setup(dap)

			require("dap-vscode-js").setup({
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
				adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
			})

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch .NET",
					request = "launch",
					program = function()
						return vim.fn.glob(vim.fn.getcwd() .. "/bin/Debug/net9.0/*.dll")
					end,
					env = { ASPNETCORE_ENVIRONMENT = "Development" },
				},
				{
					type = "coreclr",
					name = "Attach",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
			}

			for _, adapterType in ipairs({ "node", "chrome", "msedge" }) do
				local pwaType = "pwa-" .. adapterType

				dap.adapters[pwaType] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = {
							vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
							"${port}",
						},
					},
				}

				-- this allow us to handle launch.json configurations
				-- which specify type as "node" or "chrome" or "msedge"
				dap.adapters[adapterType] = function(cb, config)
					local nativeAdapter = dap.adapters[pwaType]

					config.type = pwaType

					if type(nativeAdapter) == "function" then
						nativeAdapter(cb, config)
					else
						cb(nativeAdapter)
					end
				end
			end

			local enter_launch_url = function()
				local co = coroutine.running()
				return coroutine.create(function()
					vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:" }, function(url)
						if url == nil or url == "" then
							return
						else
							coroutine.resume(co, url)
						end
					end)
				end)
			end

			for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file using Node.js (nvim-dap)",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to process using Node.js (nvim-dap)",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					-- requires ts-node to be installed globally or locally
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file using Node.js with ts-node/register (nvim-dap)",
						program = "${file}",
						cwd = "${workspaceFolder}",
						runtimeArgs = { "-r", "ts-node/register" },
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Launch Chrome (nvim-dap)",
						url = enter_launch_url,
						webRoot = "${workspaceFolder}",
						sourceMaps = true,
					},
					{
						type = "pwa-chrome",
						request = "attach",
						name = "Attach DAP to Running Chrome",
						port = 9222,
						webRoot = "${workspaceFolder}",
						sourceMaps = true,
					},
					{
						type = "pwa-msedge",
						request = "launch",
						name = "Launch Edge (nvim-dap)",
						url = enter_launch_url,
						webRoot = "${workspaceFolder}",
						sourceMaps = true,
					},
				}
			end

			-----------------------------------------------------------------------
			-- Keymaps
			-----------------------------------------------------------------------
			local map = vim.keymap.set

			map("n", "<leader>dc", dap.continue, { desc = "Continue" })
			map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Breakpoint" })
			map("n", "<leader>ds", dap.step_over, { desc = "Step Over" })
			map("n", "<leader>dn", dap.step_into, { desc = "Step Into" })
			map("n", "<leader>do", dap.step_out, { desc = "Step Out" })
			map("n", "<leader>dr", dap.repl.open, { desc = "REPL" })
			map("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
			map("n", "<leader>dt", function()
				require("dapui").toggle()
			end, { desc = "Toggle UI" })
		end,
	},

	-----------------------------------------------------------------------
	-- DAP UI
	-----------------------------------------------------------------------
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		event = "VeryLazy",
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			dapui.setup({
				layouts = {
					{
						elements = { "scopes", "breakpoints", "stacks", "watches" },
						size = 40,
						position = "left",
					},
					{
						elements = { "repl", "console" },
						size = 0.25,
						position = "bottom",
					},
				},
			})

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "ErrorMsg" })
		end,
	},
}
