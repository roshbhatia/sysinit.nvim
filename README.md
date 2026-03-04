# sysinit.nvim

Neovim configuration for the sysinit project.

## Structure

- `init.lua` - Entry point
- `lua/sysinit/` - Plugin configurations and utilities
- `after/` - Post-plugin configurations
- `queries/` - TreeSitter query files

## Installation

This repository is automatically cloned to `~/.config/nvim` by the sysinit home-manager module during system setup.

To manually clone:

```bash
git clone https://github.com/roshbhatia/sysinit.nvim.git ~/.config/nvim
```

## Updates

After the initial setup, updates are pulled automatically during home-manager activation.

To manually update:

```bash
cd ~/.config/nvim && git pull origin main
```
