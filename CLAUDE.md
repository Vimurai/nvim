# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Neovim configuration using Lua with lazy.nvim as the plugin manager. The configuration is organized under the `emirtech` namespace and supports polyglot development (C#, TypeScript/Vue, Python, Go, Lua).

## Architecture

```
lua/emirtech/
├── core/                    # Core settings (options, keymaps, macros)
│   ├── options.lua          # Vim options, leader=<Space>, tabs=2
│   ├── keymaps.lua          # Global keymaps
│   ├── macros/              # Custom code macros (logging, docs, try-catch)
│   └── comment-boxes/       # Visual comment separators
├── plugins/                 # Plugin configs (one file per plugin)
│   ├── lsp/                 # LSP ecosystem (lspconfig, mason, roslyn)
│   └── *.lua                # Individual plugin specs
└── lazy.lua                 # lazy.nvim bootstrap
```

**Entry point:** `init.lua` requires `emirtech.core` and `emirtech.lazy`

## Key Patterns

### Plugin Configuration
Each plugin is a separate Lua file returning a lazy.nvim spec table:
```lua
return {
  "plugin/name",
  event = { "BufReadPre", "BufNewFile" },  -- Common lazy-load pattern
  dependencies = { ... },
  config = function() ... end,
}
```

### LSP Setup
Uses native `vim.lsp.config()` API (not lsp-zero). Key files:
- `plugins/lsp/lpconfig.lua` - Core LSP setup, capabilities, keymaps
- `plugins/lsp/mason.lua` - Server installation
- `plugins/lsp/roslyn.lua` - C#/Razor dedicated LSP

### Keymap Namespaces
- `<leader>p*` - Harpoon (bookmarks)
- `<leader>z*` - Copilot/CopilotChat
- `<leader>d*` - DAP debugging
- `<leader>x*` - Trouble diagnostics
- `<leader>g*` - Git operations
- `<leader>f*` - File finder
- `<leader>u*` - Toggles (spell, wrap, etc.)
- `<leader>b*` - Comment boxes
- `<leader>s*` - Smart operations
- `<leader>c*` - Code actions, logging

### Razor/C# Special Handling
- Custom filetype detection: `.razor`/`.cshtml` → `razor`
- Uses roslyn.nvim (not omnisharp)
- Formatting skipped for Razor (csharpier limitation)
- Signature help disabled per-buffer to prevent JSON errors

## Commands

### Testing Configuration
```bash
# Check for Lua syntax errors
nvim --headless -c "lua print('ok')" -c "q"

# Validate lazy.nvim can load
nvim --headless -c "Lazy health" -c "q"

# Check LSP health
nvim --headless -c "checkhealth lsp" -c "q"
```

### Plugin Management
```vim
:Lazy              " Open lazy.nvim UI
:Lazy sync         " Update all plugins
:Lazy health       " Check plugin status
:Mason             " Manage LSP servers/tools
```

### Key Plugin Commands
```vim
:Trouble diagnostics     " Open diagnostics panel
:CopilotChat             " Open AI chat
:SmartDocBlock           " Generate doc comment (<leader>sd)
```

## Development Notes

- **Snacks.nvim** (`plugins/snacks.lua`) is the primary picker/explorer - large file (~425 lines)
- **CopilotChat** (`plugins/copilot-chat.lua`) has custom DDD/Clean Code prompts
- **DAP** supports .NET (coreclr) and Node.js debugging
- **Formatting** uses conform.nvim with language-specific formatters (prettier, stylua, csharpier)
- Custom macros in `core/macros/` are language-aware (detect filetype for correct syntax)
