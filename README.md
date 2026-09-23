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

Press `Space o` for the Octo group in WhichKey. `Space` is `<leader>`.

| Keys | Action |
| --- | --- |
| `Space op` / `Space oo` | List PRs / open the current branch's PR |
| `Space od` | Browse the PR diff and existing threads |
| `Space or` | Start or resume your review |
| `Space oc` | Comment on a line or visual selection; reply inside a thread |
| `Space os` | Suggest a change on selected lines |
| `Space ov` | Open the review submission form |
| `Space oa` | Approve from the PR overview; submit approval inside the form |
| `Space ot` / `Space oT` | Resolve or reopen a thread |
| `Space oh` | Inspect PR commits |
| `Space oe` / `Space ob` | Focus or toggle the file panel |
| `Space om` | Toggle the file's viewed state |
| `Space ow` / `Space oy` | Open the PR in the browser / copy its URL from the overview |
| `Space oq` | Close the review or submission form |

Inside the submission form, `Space oc` submits a comment review and `Space ox`
requests changes. `Space oa` submits approval. These keys act in normal mode;
press Escape after writing the review body. Approval from the overview asks
for an optional comment; Escape cancels it.

Keep Octo's native `[q` / `]q` file navigation, `[t` / `]t` thread navigation,
and `gf` to open the source file. Context actions are buffer-local.

Write a comment buffer with `:w` to save it to GitHub. Submit the review explicitly with `Space ov`.
Plain Diffview remains available through `:DiffviewOpen` and the existing diff keys.
Octo is pinned through Nix and uses your GitHub CLI authentication.

## Checks

Run `nix flake check` to execute the headless editor suite.
