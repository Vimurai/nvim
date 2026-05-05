-- ESP-IDF / ESP32 workflow integration
-- Prerequisites:
--   1. Source env before opening Neovim: `get_idf` (alias for . ~/esp/esp-idf/export.sh)
--   2. Run :IDFInit once per new project to set up clangd + compile_commands

local function idf_run(cmd)
	Snacks.terminal(cmd, { cwd = vim.fn.getcwd() })
end

-- Flags ESP-IDF passes to GCC that clangd (LLVM) doesn't understand
local CLANGD_REMOVE_FLAGS = [[
CompileFlags:
  Remove:
    - -fno-malloc-dce
    - -fno-shrink-wrap
    - -fno-tree-switch-conversion
    - -fstrict-volatile-bitfields
    - -fno-printf-return-value
    - -fno-jump-tables
    - -fzero-init-padding-bits=*
    - -mtext-section-literals
    - -mlongcalls
    - -mfix-esp32-psram-cache-issue
    - -mfix-esp32-psram-cache-strategy=*
    - --sysroot=*
    - -target
    - xtensa-esp*
]]

local function setup_commands()
	vim.api.nvim_create_user_command("IDFBuild", function()
		idf_run("idf.py build")
	end, { desc = "ESP-IDF: Build project" })

	vim.api.nvim_create_user_command("IDFFlash", function()
		idf_run("idf.py flash")
	end, { desc = "ESP-IDF: Flash to device" })

	vim.api.nvim_create_user_command("IDFMonitor", function()
		idf_run("idf.py monitor")
	end, { desc = "ESP-IDF: Serial monitor" })

	vim.api.nvim_create_user_command("IDFFlashMonitor", function()
		idf_run("idf.py flash monitor")
	end, { desc = "ESP-IDF: Flash then monitor" })

	vim.api.nvim_create_user_command("IDFMenuconfig", function()
		idf_run("idf.py menuconfig")
	end, { desc = "ESP-IDF: Interactive config UI" })

	vim.api.nvim_create_user_command("IDFClean", function()
		idf_run("idf.py fullclean")
	end, { desc = "ESP-IDF: Full clean build artifacts" })

	vim.api.nvim_create_user_command("IDFOpenOCD", function()
		Snacks.terminal("idf.py openocd", {
			cwd = vim.fn.getcwd(),
			win = { position = "bottom", height = 0.25 },
		})
	end, { desc = "ESP-IDF: Launch OpenOCD (JTAG gdb server on :3333)" })

	-- Launch OpenOCD in a background snacks terminal, wait for :3333, then start DAP
	vim.api.nvim_create_user_command("IDFDebug", function()
		local ok_dap, dap = pcall(require, "dap")
		if not ok_dap then
			vim.notify("nvim-dap not available", vim.log.levels.ERROR)
			return
		end

		-- 1. Start OpenOCD (idempotent: skip if port already open)
		local port_check = vim.fn.system("lsof -nP -iTCP:3333 -sTCP:LISTEN -t 2>/dev/null")
		if port_check == "" then
			Snacks.terminal("idf.py openocd", {
				cwd = vim.fn.getcwd(),
				win = { position = "bottom", height = 0.25 },
			})
			vim.notify("Starting OpenOCD on :3333 ...", vim.log.levels.INFO)
		else
			vim.notify("OpenOCD already listening on :3333", vim.log.levels.INFO)
		end

		-- 2. Poll until OpenOCD is listening, then trigger DAP "Attach to ESP32"
		local tries, max_tries = 0, 30 -- ~6s @ 200ms
		local timer = vim.uv.new_timer()
		timer:start(
			500,
			200,
			vim.schedule_wrap(function()
				tries = tries + 1
				local listening = vim.fn.system("lsof -nP -iTCP:3333 -sTCP:LISTEN -t 2>/dev/null")
				if listening ~= "" then
					timer:stop()
					timer:close()
					-- Find the ESP32 attach config and run it directly (no menu)
					for _, cfg in ipairs(dap.configurations.c or {}) do
						if cfg.type == "esp32_gdb" then
							dap.run(cfg)
							return
						end
					end
					vim.notify("No esp32_gdb config found in dap.configurations.c", vim.log.levels.WARN)
				elseif tries >= max_tries then
					timer:stop()
					timer:close()
					vim.notify("OpenOCD did not start within 6s — check your idf env", vim.log.levels.ERROR)
				end
			end)
		)
	end, { desc = "ESP-IDF: Start OpenOCD + attach DAP debugger" })

	vim.api.nvim_create_user_command("IDFSetTarget", function()
		local target = vim.fn.input("Target chip (esp32 / esp32s3 / esp32c3 / esp32h2): ")
		if target ~= "" then
			idf_run("idf.py set-target " .. target)
		end
	end, { desc = "ESP-IDF: Set target chip" })

	-- Run once per new project: sets target, builds, sets up clangd
	vim.api.nvim_create_user_command("IDFInit", function()
		local cwd = vim.fn.getcwd()
		local target = vim.fn.input("Target chip (esp32 / esp32s3 / esp32c3 / esp32h2): ")
		if target == "" then
			return
		end

		-- Write .clangd with flag removal (works regardless of global config issues)
		local clangd_path = cwd .. "/.clangd"
		local f = io.open(clangd_path, "w")
		if f then
			f:write(CLANGD_REMOVE_FLAGS)
			f:close()
			vim.notify("Created .clangd", vim.log.levels.INFO)
		end

		-- Build (generates compile_commands.json in build/) then symlink to root
		local build_cmd = string.format(
			"idf.py set-target %s && idf.py build && ln -sf build/compile_commands.json compile_commands.json",
			target
		)
		idf_run(build_cmd)
	end, { desc = "ESP-IDF: Init new project (set target + build + clangd setup)" })
end

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = setup_commands,
})

return {
	{
		"folke/snacks.nvim",
		keys = {
			{ "<leader>ii", "<cmd>IDFInit<cr>",         desc = "IDF: Init project (first time setup)" },
			{ "<leader>ib", "<cmd>IDFBuild<cr>",        desc = "IDF: Build" },
			{ "<leader>if", "<cmd>IDFFlash<cr>",        desc = "IDF: Flash" },
			{ "<leader>im", "<cmd>IDFMonitor<cr>",      desc = "IDF: Monitor" },
			{ "<leader>iM", "<cmd>IDFFlashMonitor<cr>", desc = "IDF: Flash + Monitor" },
			{ "<leader>ic", "<cmd>IDFMenuconfig<cr>",   desc = "IDF: Menuconfig" },
			{ "<leader>ix", "<cmd>IDFClean<cr>",        desc = "IDF: Full Clean" },
			{ "<leader>it", "<cmd>IDFSetTarget<cr>",    desc = "IDF: Set Target Chip" },
			{ "<leader>io", "<cmd>IDFOpenOCD<cr>",      desc = "IDF: OpenOCD (JTAG gdb server)" },
			{ "<leader>id", "<cmd>IDFDebug<cr>",        desc = "IDF: Debug (OpenOCD + DAP attach)" },
		},
	},
}
