# sysinit.nvim

Neovim configuration for the sysinit project.

## Structure

- `init.lua` - Entry point
- `lua/sysinit/` - Plugin configurations and utilities
- `after/` - Post-plugin configurations
- `queries/` - TreeSitter query files

## Installation

### Via sysinit

This repository is automatically cloned to `~/.config/nvim` by the sysinit home-manager module during system setup:

```bash
nix run nixpkgs#nh -- darwin switch .
```

### Standalone

Quick installation with Neovim binary and config:

```bash
curl -fsSL https://raw.githubusercontent.com/roshbhatia/sysinit.nvim/main/install.sh | bash
```

Or clone manually:

```bash
git clone https://github.com/roshbhatia/sysinit.nvim.git ~/.config/nvim
cd ~/.config/nvim
nvim
```

Installation script options:

```bash
# Install both neovim and config (default)
./install.sh

# Install config only (if neovim is already installed)
./install.sh --config-only

# Install neovim only (skip config)
./install.sh --nvim-only
```

## Updates

After the initial setup, updates are pulled automatically during home-manager activation.

To manually update:

```bash
cd ~/.config/nvim && git pull origin main
```
