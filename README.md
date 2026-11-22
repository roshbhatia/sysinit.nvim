# sysinit.nvim

Neovim configuration for code review and repository work.

## Nix

Import `inputs.sysinit-nvim.homeManagerModules.default` and set `programs.sysinit-neovim.enable = true`.
The module uses the pinned source. Set `programs.sysinit-neovim.configPath` to a checkout path for local development.

The module accepts extra Neovim plugins through Home Manager.

## GitHub reviews

Run `:Atlas review https://github.com/owner/repo/pull/123` to open the PR.
Press `Space a r` to pick a PR in the current repository, or `Space a p`
to browse GitHub pull requests. `Space a n` opens local review notes.

Atlas shows the diff, threads, and review actions in one view. Its GitHub
provider uses GitHub CLI authentication. Use `:DiffviewOpen` for local
working-tree diffs.

## Checks

Run `nix flake check` to execute the headless editor suite.
