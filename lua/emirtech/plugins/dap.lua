return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"nvim-neotest/nvim-nio",
			"folke/which-key.nvim",
			-- Critical for M1/M2/M3 chips (Apple Silicon)
			"Cliffback/netcoredbg-macOS-arm64.nvim",
		},
		event = "VeryLazy",
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Automatically handle netcoredbg for Apple Silicon
			require("netcoredbg-macOS-arm64").setup(dap)

			require("mason-nvim-dap").setup({
				ensure_installed = { "js-debug-adapter", "codelldb" },
				automatic_installation = true,
				handlers = {},
			})

			-----------------------------------------------------------------------
			-- Adapters
			-----------------------------------------------------------------------

			-- JS/TS Adapter (pwa-node)
			dap.adapters["pwa-node"] = {
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

			-- C/C++ Adapter (codelldb) — for host C/C++ binaries
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/codelldb",
					args = { "--port", "${port}" },
				},
			}

			-- ESP32 Adapter (xtensa-esp-elf-gdb via OpenOCD)
			-- Prereq: `idf.py openocd` running in another terminal (or Snacks term)
			dap.adapters.esp32_gdb = {
				type = "executable",
				command = vim.fn.expand("~")
					.. "/.espressif/tools/xtensa-esp-elf-gdb/*/xtensa-esp-elf-gdb/bin/xtensa-esp32-elf-gdb",
				name = "xtensa-esp-elf-gdb",
			}

			-----------------------------------------------------------------------
			-- Helper Functions for .NET
			-----------------------------------------------------------------------

			local function build_project()
				local cmd = "dotnet build -c Debug"
				print("Building: " .. cmd)
				local output = vim.fn.system(cmd)
				print(output)
			end

			local function get_dll_path()
				local cwd = vim.fn.getcwd()
				-- Search for the executable-looking DLL with a runtimeconfig
				local config_files = vim.fn.glob(cwd .. "/bin/Debug/**/*.runtimeconfig.json", false, true)
				local executable_dlls = {}
				
				for _, config in ipairs(config_files) do
					local dll = config:gsub("%.runtimeconfig%.json$", ".dll")
					if vim.fn.filereadable(dll) == 1 then
						-- Filter out common framework DLLs
						if not string.match(dll, "Microsoft%") and not string.match(dll, "System%") then
							table.insert(executable_dlls, dll)
						end
					end
				end

				if #executable_dlls == 1 then
					return executable_dlls[1]
				elseif #executable_dlls > 1 then
					return vim.fn.input("Select DLL: ", executable_dlls[1], "file")
				else
					return vim.fn.input("Path to DLL: ", cwd .. "/bin/Debug/", "file")
				end
			end

			-----------------------------------------------------------------------
			-- Configurations
			-----------------------------------------------------------------------

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch .NET App (M1/M2 Native)",
					request = "launch",
					program = function()
						if vim.fn.confirm("Build project?", "&Yes\n&No", 1) == 1 then
							build_project()
						end
						return get_dll_path()
					end,
				cwd = "${workspaceFolder}",
				stopAtEntry = false,
				console = "integratedTerminal",
				env = {
					ASPNETCORE_ENVIRONMENT = "Development",
					-- Ensure dotnet tool can find the native libraries
					DOTNET_ROOT = "/opt/homebrew/bin/dotnet",
				},
				},
				{
					type = "coreclr",
					name = "Attach to Process",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
			}

			dap.configurations.razor = dap.configurations.cs

			-- C/C++ configurations (codelldb for host binaries)
			local cpp_configs = {
				{
					name = "Launch executable (codelldb)",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
				{
					name = "Attach to ESP32 (OpenOCD :3333)",
					type = "esp32_gdb",
					request = "launch",
					program = function()
						local cwd = vim.fn.getcwd()
						local elfs = vim.fn.glob(cwd .. "/build/*.elf", false, true)
						if #elfs == 1 then
							return elfs[1]
						end
						return vim.fn.input("Path to .elf: ", cwd .. "/build/", "file")
					end,
					cwd = "${workspaceFolder}",
					miDebuggerServerAddress = "localhost:3333",
					stopAtEntry = true,
					setupCommands = {
						{ text = "set remotetimeout 60", description = "longer timeout", ignoreFailures = false },
						{ text = "monitor reset halt", description = "reset target", ignoreFailures = true },
						{ text = "flushregs", description = "refresh regs", ignoreFailures = true },
					},
				},
			}
			dap.configurations.c = cpp_configs
			dap.configurations.cpp = cpp_configs

			-- JS/TS configurations
			local js_langs = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }
			for _, lang in ipairs(js_langs) do
				dap.configurations[lang] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch Current File (Node)",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to Process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					}
				}
			end

			-----------------------------------------------------------------------
			-- UI & Keymaps
			-----------------------------------------------------------------------

			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			local map = vim.keymap.set
			map("n", "<leader>dc", dap.continue, { desc = "DAP: Continue/Start" })
			map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
			map("n", "<leader>ds", dap.step_over, { desc = "DAP: Step Over" })
			map("n", "<leader>di", dap.step_into, { desc = "DAP: Step Into" })
			map("n", "<leader>do", dap.step_out, { desc = "DAP: Step Out" })
			map("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
			map("n", "<leader>dl", dap.run_last, { desc = "DAP: Run Last" })
			map("n", "<leader>dt", dapui.toggle, { desc = "DAP: Toggle UI" })
			map("n", "<leader>dx", dap.terminate, { desc = "DAP: Terminate" })

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "ErrorMsg" })
		end,
	},
}
