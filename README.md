# sysinit.nvim

Neovim configuration for code review, agent panes, and repository work.

## Nix

Import `inputs.sysinit-nvim.homeManagerModules.default` and set `programs.sysinit-neovim.enable = true`.
The module uses the pinned source. Set `programs.sysinit-neovim.configPath` to a checkout path for local development.

The module accepts extra Neovim plugins through Home Manager. Machine paths and agent registries come from the host configuration.
The notes UI comes from agent-notes. Its README covers vim.pack, Lazy, and Nixvim installation.

## Checks

Run `nix flake check` to execute the headless editor suite.
