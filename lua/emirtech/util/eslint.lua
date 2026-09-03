-- ESLint helpers shared by the eslint LSP config.
--
-- Goal: a project with no ESLint config (and possibly no ESLint install) still
-- gets linted with a sane default instead of the server erroring with
-- "Could not find config file".
--
-- The default config lives in <nvim config>/eslint/fallback.mjs and its
-- dependencies (eslint, @eslint/js, typescript-eslint, eslint-plugin-vue, …)
-- are installed in <nvim config>/eslint/node_modules via `npm install`.
local M = {}

M.dir = vim.fn.stdpath("config") .. "/eslint"
M.node_path = M.dir .. "/node_modules"

local flat_config_files = {
	"eslint.config.js",
	"eslint.config.mjs",
	"eslint.config.cjs",
	"eslint.config.ts",
	"eslint.config.mts",
	"eslint.config.cts",
}

local legacy_config_files = {
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.mjs",
	".eslintrc.yaml",
	".eslintrc.yml",
	".eslintrc.json",
}

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local s = f:read("*a")
	f:close()
	return s
end

--- Kind of ESLint config found per project root ("flat" | "legacy").
--- Filled from root_dir (which knows the buffer) and read in before_init
--- (which only knows the root).
M.kind_by_root = {}

--- Search upward from directory `dir` (stopping at `root`) for an ESLint config.
--- @return "flat"|"legacy"|nil
function M.find_config(dir, root)
	local opts = { path = dir, upward = true, type = "file", limit = 1, stop = vim.fs.dirname(root) }
	if vim.fs.find(flat_config_files, opts)[1] then
		return "flat"
	end
	if vim.fs.find(legacy_config_files, opts)[1] then
		return "legacy"
	end
	-- Legacy: "eslintConfig" key inside package.json.
	for _, pkg in ipairs(vim.fs.find("package.json", vim.tbl_extend("force", opts, { limit = math.huge }))) do
		local s = read_file(pkg)
		if s and s:find('"eslintConfig"', 1, true) then
			return "legacy"
		end
	end
	return nil
end

--- True when the project has its own ESLint install at `root`.
function M.has_project_eslint(root)
	return vim.uv.fs_stat(root .. "/node_modules/eslint/package.json") ~= nil
end

--- Major version of the ESLint the project ships, or nil.
function M.project_eslint_major(root)
	local s = read_file(root .. "/node_modules/eslint/package.json")
	local v = s and s:match('"version"%s*:%s*"(%d+)')
	return v and tonumber(v) or nil
end

--- True when the bundled fallback deps are installed; warns once otherwise.
function M.fallback_installed()
	if vim.uv.fs_stat(M.node_path .. "/eslint/package.json") then
		return true
	end
	vim.notify_once(("ESLint fallback deps missing. Run:\n  cd %s && npm install"):format(M.dir), vim.log.levels.WARN)
	return false
end

--- Path to a generated flat config that applies the default to `root`.
--- One tiny wrapper per project root is cached under stdpath("cache"), so the
--- default can resolve plugins from the project first and the bundle second.
--- If this content changes, stale wrappers are simply rewritten on next use.
function M.fallback_config(root)
	local dir = vim.fn.stdpath("cache") .. "/eslint-fallback"
	vim.fn.mkdir(dir, "p")
	local file = dir .. "/" .. vim.fn.sha256(root):sub(1, 16) .. ".mjs"
	local content = ("import make from %s;\nexport default make(%s, %s);\n"):format(
		vim.json.encode(M.dir .. "/fallback.mjs"),
		vim.json.encode(root),
		vim.json.encode(M.dir)
	)
	if read_file(file) ~= content then
		local f = assert(io.open(file, "w"))
		f:write(content)
		f:close()
	end
	return file
end

return M
