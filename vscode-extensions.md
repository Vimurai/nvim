# Required VSCode Extensions

Install these to match your Neovim setup.

## Core (Required)

```bash
# Vim emulation
code --install-extension vscodevim.vim

# Theme (matches your Tokyo Night)
code --install-extension enkia.tokyo-night

# Icon theme
code --install-extension pkief.material-icon-theme
```

## Language Support

```bash
# C# / .NET
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.csdevkit
code --install-extension csharpier.csharpier-vscode

# TypeScript/JavaScript (built-in, but these help)
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode

# Vue
code --install-extension Vue.volar

# Python
code --install-extension ms-python.python
code --install-extension ms-python.black-formatter
code --install-extension ms-python.isort

# Go
code --install-extension golang.go

# Lua
code --install-extension sumneko.lua
code --install-extension JohnnyMorganz.stylua
```

## Git (matches gitsigns + snacks git)

```bash
code --install-extension eamodio.gitlens
code --install-extension mhutchie.git-graph
code --install-extension kahole.lazygit
```

## Productivity (matches your plugins)

```bash
# Harpoon-like bookmarks
code --install-extension alefragnani.numbered-bookmarks

# Todo comments (matches todo-comments.nvim)
code --install-extension Gruntfuggly.todo-tree

# Copilot (matches copilot + copilot-chat)
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat

# Spell check (matches snacks spell toggle)
code --install-extension streetsidesoftware.code-spell-checker
```

## Quick Install All

```bash
code --install-extension vscodevim.vim
code --install-extension enkia.tokyo-night
code --install-extension pkief.material-icon-theme
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.csdevkit
code --install-extension csharpier.csharpier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension Vue.volar
code --install-extension ms-python.python
code --install-extension ms-python.black-formatter
code --install-extension golang.go
code --install-extension sumneko.lua
code --install-extension JohnnyMorganz.stylua
code --install-extension eamodio.gitlens
code --install-extension mhutchie.git-graph
code --install-extension kahole.lazygit
code --install-extension alefragnani.numbered-bookmarks
code --install-extension Gruntfuggly.todo-tree
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension streetsidesoftware.code-spell-checker
```

## Installation

1. Copy `vscode-settings.json` to:
   - macOS: `~/Library/Application Support/Code/User/settings.json`
   - Linux: `~/.config/Code/User/settings.json`

2. Copy `vscode-keybindings.json` to:
   - macOS: `~/Library/Application Support/Code/User/keybindings.json`
   - Linux: `~/.config/Code/User/keybindings.json`

Or use symlinks:
```bash
ln -sf ~/.config/nvim/vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -sf ~/.config/nvim/vscode-keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
```
