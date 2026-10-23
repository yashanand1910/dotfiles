# dotfiles

My dev environment: zsh (oh-my-zsh), tmux and Neovim (lazy.nvim, Mason, Treesitter, and
avante.nvim backed by Claude Code), plus Go, Rust, Node, Python, Docker and Kubernetes
tooling. It ships as a Docker image and installs the same way on Ubuntu hosts. The repo
also holds my desktop setup (Gentoo, Hyprland, kitty and friends).

Feel free to use it. Everything except the private image works without my keys.

## Layout

| Path | What |
| --- | --- |
| `.zshrc`, `.oh-my-zsh/` | Shell config, custom theme and completions (linked into `~/.oh-my-zsh/custom`) |
| `.tmux.conf` | tmux config (plugins via tpm) |
| `.config/nvim/` | Neovim config, see `init.lua` |
| `.config/{hypr,kitty,mako,tofi,btop,qutebrowser}/` | Desktop configs |
| `.gitconfig`, `.gitignore`, `.vimrc` | Misc dotfiles |
| `.claude/` | Global Claude Code instructions (linked into `~/.claude`) |
| `scripts/install.sh` | Installs the environment, one step at a time; used by both the image and hosts |
| `scripts/bootstrap`, `scripts/nuke` | Set up / tear down an Ubuntu host |
| `scripts/` (rest) | Small desktop helpers (tmux, Hyprland, boot, browser) |
| `Dockerfile`, `private.Dockerfile`, `entrypoint` | Dev images |
| `update` | Commit, push, then build and push both images |
| `gentoo/`, `etc/` | Kernel config, `make.conf`, OpenRC hooks |
| `archive/` | Configs I no longer use (i3, alacritty, wezterm, ...) |

## What gets installed

`scripts/install.sh <step>...` is the single source of truth. Versions are pinned at the
top of the script, and anything without a pin installs the latest release.

| Step | Installs |
| --- | --- |
| `packages` | Build tools, git, zsh, tmux, Python, gdb, cmake, jq, ... and the `en_US.UTF-8` locale |
| `docker-cli` / `docker-engine` | Docker CLI with buildx and compose (the image uses the host's socket) / the full engine |
| `nvidia` | NVIDIA container toolkit |
| `nvim` | Neovim release tarball |
| `node` | Node.js LTS (Mason servers, copilot.vim, avante's Claude Code agent) |
| `go` | Go |
| `tools` | ripgrep, fd, btop, lazydocker, tree-sitter CLI |
| `gh` | GitHub CLI |
| `k8s` | kubectl, k9s, helm |
| `zsh` | oh-my-zsh, zsh-autosuggestions, zsh-syntax-highlighting, zsh-claude-code, fzf |
| `tmux` | tpm |
| `rust` | rustup (stable) |
| `claude` | Claude Code |
| `link` | Symlinks this repo into `$HOME` (anything already there is moved to `*.bak`) |

The steps up to `k8s` run as root and the rest as your user.

## Docker

The public image is `yashanand1910/dev` (CUDA devel on Ubuntu 26.04).

```bash
docker run -it --name dev \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.ssh:/home/yashanand/.ssh \
    --gpus all \
    yashanand1910/dev
```

- **Docker socket** (optional): the entrypoint adds the user to a `docker` group that
  matches the socket's GID, so `docker` works inside the container.
- **`~/.ssh`** (optional): reuses your SSH keys.
- **`--gpus all`**: needs the NVIDIA container toolkit on the host. Drop it if you have no GPU.

To use your GPG keys, export them and mount them in. The entrypoint imports them and
trusts them ultimately.

```bash
gpg --export <KEY_ID> > ~/.gnupg/public.key
gpg --export-secret-keys <KEY_ID> > ~/.gnupg/private.key
docker run -it --name dev \
    -v ~/.gnupg/public.key:/home/yashanand/host-public.key \
    -v ~/.gnupg/private.key:/home/yashanand/host-private.key \
    yashanand1910/dev
```

To build the image for your own user:

```bash
docker build --build-arg USER=$(whoami) -t dev .
```

### Private image

`yashanand1910/dev-private` is the public image plus my keys and logins: SSH, GPG,
`env.zsh`, `gh` and Docker Hub. It also replaces the copied dotfiles with a real git
checkout. `update` builds it with `$HOME` as the context, so these need to exist:

- `~/.ssh/`
- `~/.gnupg/public.key` and `~/.gnupg/private.key`
- `~/.oh-my-zsh/custom/env.zsh`
- `~/.claude/`: only `projects/` (per-project memory and session transcripts) and
  `history.jsonl` are copied. The login token and caches stay out, so run `claude` once to
  log in.
- `GITHUB_KEY` and `DOCKERHUB_KEY` in the environment (passed as build secrets, so they
  don't show up in `docker history`)

## Ubuntu host

`scripts/bootstrap` runs the same install steps as the image, then copies my keys, logins
and Claude Code memory/history out of the private image:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/yashanand1910/dotfiles/stable/scripts/bootstrap)
```

- Run it as your own user; it uses sudo where it needs to.
- If Docker isn't logged in, it asks for the Docker Hub password.
- Log out and back in afterwards to pick up zsh and the `docker` group.
- It never touches the host's `~/.ssh/authorized_keys`.
- If Docker or the NVIDIA toolkit were already installed, it leaves them alone (and so
  does `nuke`).

Without access to the private image, run the steps yourself instead:

```bash
git clone https://github.com/yashanand1910/dotfiles ~/code/dotfiles
cd ~/code/dotfiles
sudo scripts/install.sh packages docker-engine nvim node go tools gh k8s
scripts/install.sh zsh tmux rust claude link
```

`scripts/nuke` removes everything `bootstrap` set up:

- keys and logins (but not `authorized_keys`), and shell history
- dotfile symlinks (restoring any `*.bak` files)
- the toolchains, the third-party apt packages and their repos
- the dev images
- the repo itself

It warns first if the repo has unpushed changes, then asks you to type `nuke` (or pass
`--yes`). Generic apt packages such as git, curl and zsh stay.

## Other machines

Only the symlinks, for any OS:

```bash
git clone https://github.com/yashanand1910/dotfiles ~/code/dotfiles
DOTFILES=~/code/dotfiles ~/code/dotfiles/scripts/install.sh link
```

This expects oh-my-zsh to be installed already (`install.sh zsh` does that). For plain
Vim, `.vimrc` uses vim-plug:

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

then run `:PlugInstall`.

## First run

- **Neovim**: lazy.nvim installs the plugins on first launch, and some build with
  `make`/cargo. Treesitter compiles its parsers and Mason installs the language servers
  in the background. Check progress with `:Lazy` and `:Mason`.
- **tmux**: press `prefix + I` to install the plugins.
- **Claude Code**: run `claude` once to log in. avante uses it through
  `scripts/claude-acp`.

## Publishing

`./update` commits and pushes the repo. It then builds and pushes `yashanand1910/dev`,
and builds and pushes `dev-private` on top of it.
