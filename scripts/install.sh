#!/bin/bash
# Installs the dev environment one step at a time. Shared by the Dockerfile and
# scripts/bootstrap so the image and Ubuntu hosts stay in sync.
#
# Usage: install.sh <step>...
#   root steps: packages docker-cli docker-engine nvidia nvim node go tools gh k8s
#   user steps: zsh tmux rust claude link

set -euo pipefail

GO_VERSION=${GO_VERSION:-1.27.3}
NVIM_VERSION=${NVIM_VERSION:-0.12.6}
K9S_VERSION=${K9S_VERSION:-0.51.0}
TREE_SITTER_VERSION=${TREE_SITTER_VERSION:-0.27.1}
NODE_MAJOR=${NODE_MAJOR:-24}
DOTFILES=${DOTFILES:-$HOME/code/dotfiles}

export DEBIAN_FRONTEND=noninteractive

# arch <x86_64 name> <aarch64 name>
arch() {
    case $(uname -m) in
    x86_64) echo "$1" ;;
    aarch64) echo "$2" ;;
    *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
    esac
}

clone() {
    [ -d "$2" ] || git clone --depth 1 "$1" "$2"
}

# Symlink $1 to $2, moving aside anything real that is already there
link() {
    mkdir -p "$(dirname "$2")"
    if [ -e "$2" ] && [ ! -L "$2" ]; then
        mv "$2" "$2.bak"
    fi
    ln -sfn "$1" "$2"
}

step_packages() {
    apt-get update
    apt-get install -y build-essential git zsh wget curl sudo tmux \
        python3-pip python3-venv gpg net-tools lsof locales man-db \
        zip unzip tar gzip gdb jq cmake bc ca-certificates
    locale-gen en_US.UTF-8
}

docker_repo() {
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" \
        >/etc/apt/sources.list.d/docker.list
    apt-get update
}

# CLI only, for docker-in-docker via the host socket
step_docker-cli() {
    docker_repo
    apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin
}

step_docker-engine() {
    docker_repo
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

step_nvidia() {
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |
        gpg --batch --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
            >/etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt-get update
    apt-get install -y nvidia-container-toolkit
    nvidia-ctk runtime configure --runtime=docker
}

step_nvim() {
    local a
    a=$(arch x86_64 arm64)
    rm -rf /opt/nvim-linux-*
    curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${a}.tar.gz" |
        tar -C /opt -xz
    ln -sf "/opt/nvim-linux-${a}/bin/nvim" /usr/local/bin/nvim
}

# Needed by mason (npm-based language servers), copilot.vim and avante's ACP agent
step_node() {
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash
    apt-get install -y nodejs
}

step_go() {
    rm -rf /usr/local/go
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-$(arch amd64 arm64).tar.gz" | tar -C /usr/local -xz
    ln -sf /usr/local/go/bin/go /usr/local/bin/go
}

step_tools() {
    apt-get install -y ripgrep fd-find btop
    ln -sf /usr/bin/fdfind /usr/local/bin/fd
    curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh |
        DIR=/usr/local/bin bash
    # nvim-treesitter (main) compiles parsers with the tree-sitter CLI
    curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/v${TREE_SITTER_VERSION}/tree-sitter-linux-$(arch x64 arm64).gz" |
        gunzip >/usr/local/bin/tree-sitter
    chmod 755 /usr/local/bin/tree-sitter
}

step_gh() {
    mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        >/etc/apt/sources.list.d/github-cli.list
    apt-get update
    apt-get install -y gh
}

step_k8s() {
    local a tmp
    a=$(arch amd64 arm64)
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/kubectl" "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${a}/kubectl"
    install "$tmp/kubectl" /usr/local/bin
    curl -fsSL -o "$tmp/k9s.deb" "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_linux_${a}.deb"
    apt-get install -y "$tmp/k9s.deb"
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
    rm -rf "$tmp"
}

step_zsh() {
    [ -d ~/.oh-my-zsh ] ||
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --skip-chsh --unattended --keep-zshrc
    local custom=~/.oh-my-zsh/custom
    clone https://github.com/zsh-users/zsh-autosuggestions $custom/plugins/zsh-autosuggestions
    clone https://github.com/zsh-users/zsh-syntax-highlighting $custom/plugins/zsh-syntax-highlighting
    clone https://github.com/matheus-poli/zsh-claude-code $custom/plugins/zsh-claude-code
    clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc
    grep -qs '.local/bin' $custom/env.zsh || echo "export PATH=\$PATH:\$HOME/.local/bin" >>$custom/env.zsh
}

step_tmux() {
    clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

# Also needed by pipeline.nvim's build (cargo)
step_rust() {
    curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
}

step_claude() {
    curl -fsSL https://claude.ai/install.sh | bash
}

step_link() {
    local f
    for f in "$DOTFILES"/.config/*; do
        link "$f" ~/.config/"$(basename "$f")"
    done
    for f in .gitconfig .gitignore .vimrc .zshrc .tmux.conf; do
        link "$DOTFILES/$f" ~/"$f"
    done
    link "$DOTFILES/scripts" ~/code/scripts
    for f in "$DOTFILES"/.oh-my-zsh/*; do
        link "$f" ~/.oh-my-zsh/custom/"$(basename "$f")"
    done
    for f in "$DOTFILES"/.claude/*.md; do
        link "$f" ~/.claude/"$(basename "$f")"
    done
}

for s in "$@"; do
    echo "==> $s"
    "step_$s"
done
