# sysinit.nvim

Neovim configuration for code review, agent panes, and repository work.

## Nix

Import `inputs.sysinit-nvim.homeManagerModules.default` and set `programs.sysinit-neovim.enable = true`.
The module uses the pinned source. Set `programs.sysinit-neovim.configPath` to a checkout path for local development.

The module accepts extra Neovim plugins through Home Manager. Machine paths and agent registries come from the host configuration.
The notes UI comes from agent-notes. Its README covers vim.pack, Lazy, and Nixvim installation.

## GitHub reviews

`:PRReview https://github.com/owner/repo/pull/123` opens the Octo diff and existing threads.
`:PRReview!` opens the PR discussion. Browsing does not start a pending review.

- `,gr`: start or resume your review.
- `,gc`: comment on a line or visual selection; reply inside a thread.
- `,gs`: suggest a change on selected lines.
- `,gv`: open the review submission form for approval, comments, or requested changes.
- `,gt` / `,gT`: resolve or reopen a thread.
- `,gh`: inspect PR commits.
- `,de` / `,db`: focus or toggle the file panel.
- `,gq`: close the review.

Write a comment buffer with `:w` to save it to GitHub. Submit the review explicitly with `,gv`.
Plain Diffview remains available through `:DiffviewOpen` and the existing diff keys.
Octo is pinned through Nix and uses your GitHub CLI authentication.

## Checks

Run `nix flake check` to execute the headless editor suite.
