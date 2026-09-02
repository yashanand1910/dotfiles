# syntax=docker/dockerfile:1

FROM nvidia/cuda:12.8.0-devel-ubuntu24.04

LABEL org.opencontainers.image.source=https://github.com/yashanand1910/dotfiles

ARG USER=yashanand
ARG UID=1000

ARG GO_VERSION=1.24.3
ARG NVIM_VERSION=0.11.2
ARG K9S_VERSION=0.50.12

# Install packages
RUN <<EOT
set -eux
apt-get update
apt-get install -y build-essential
apt-get install -y git
apt-get install -y zsh
apt-get install -y wget
apt-get install -y curl
apt-get install -y sudo
apt-get install -y tmux
apt-get install -y python3-pip
apt-get install -y python3-venv
apt-get install -y gpg
apt-get install -y net-tools lsof
apt-get install -y locales
apt-get install -y man-db
apt-get install -y zip unzip tar
apt-get install -y gdb
apt-get install -y jq
apt-get install -y cmake
apt-get install -y bc
EOT

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Setup docker (CLI only for docker-in-docker)
RUN <<EOT
set -eux
apt-get install -y ca-certificates
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce-cli
EOT

# Setup NVIDIA container toolkit
RUN <<EOT
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt-get update
apt-get install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
EOT

# Setup neovim
RUN <<EOT
set -eux
if [ $(uname -m) = "aarch64" ]; then
    ARCH=arm64
elif [ $(uname -m) = "x86_64" ]; then
    ARCH=x86_64
else
    echo "Unsupported architecture: $(uname -m)"
    exit 1
fi
curl -LO https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${ARCH}.tar.gz
rm -rf /opt/nvim
tar -C /opt -xzf nvim-linux-${ARCH}.tar.gz
ln -s /opt/nvim-linux-${ARCH}/bin/nvim /usr/local/bin/nvim
rm nvim-linux-${ARCH}.tar.gz
EOT

# Setup node (for nvim plugins)
RUN <<EOT
set -eux
curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt-get install -y nodejs
rm nodesource_setup.sh
EOT

# Setup go
RUN <<EOT
set -eux
if [ $(uname -m) = "aarch64" ]; then
    ARCH=arm64
elif [ $(uname -m) = "x86_64" ]; then
    ARCH=amd64
else
    echo "Unsupported architecture: $(uname -m)"
    exit 1
fi
wget https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz
ln -s /usr/local/go/bin/go /usr/local/bin/go
rm go${GO_VERSION}.linux-${ARCH}.tar.gz
EOT

# Setup miscelaneous
RUN <<EOT
set -eux
apt-get install -y ripgrep
apt-get install -y btop
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
EOT

# Setup github CLI
RUN <<EOT
set -eux
(type -p wget >/dev/null || (apt update && apt-get install wget -y)) \
&& mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& apt update \
&& apt install gh -y
EOT

# Setup kubectl
RUN <<EOT
if [ $(uname -m) = "aarch64" ]; then
    ARCH=arm64
elif [ $(uname -m) = "x86_64" ]; then
    ARCH=amd64
else
    echo "Unsupported architecture: $(uname -m)"
    exit 1
fi
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
install kubectl /usr/local/bin
rm kubectl
wget https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_linux_${ARCH}.deb
apt install -y ./k9s_linux_${ARCH}.deb
rm k9s_linux_${ARCH}.deb
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh
EOT

# Setup user
RUN <<EOT
set -eux
usermod -l ${USER} ubuntu
groupmod -n ${USER} ubuntu
usermod -d /home/${USER} -m ${USER}
usermod -c "${USER}" -g ${USER} -G sudo -s /bin/zsh ${USER}
echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${USER}
EOT
USER ${USER}
WORKDIR /home/${USER}

# Setup zsh
RUN <<EOT
set -eux
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --skip-chsh --unattended --keep-zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/loiccoyle/zsh-github-copilot ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-github-copilot
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --no-update-rc
echo "export PATH=\$PATH:/home/${USER}/.local/bin" >> ~/.oh-my-zsh/custom/env.zsh
rm -r ~/.oh-my-zsh/custom/themes
EOT
ENV TERM xterm-256color
ENV PROMPT_CTX "dev"

# Setup tmux
RUN <<EOT
set -eux
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
EOT

# Setup dotfiles
ADD --chown=${USER}:${USER} .config .config
ADD --chown=${USER}:${USER} .gitconfig .gitconfig
ADD --chown=${USER}:${USER} .gitignore .gitignore
ADD --chown=${USER}:${USER} .vimrc .vimrc
ADD --chown=${USER}:${USER} .zshrc .zshrc
ADD --chown=${USER}:${USER} .tmux.conf .tmux.conf
ADD --chown=${USER}:${USER} .oh-my-zsh/* .oh-my-zsh/custom

ADD --chown=${USER}:${USER} --chmod=755 entrypoint entrypoint

# TODO: add apt autoremove, purge etc

ENTRYPOINT ["./entrypoint"]
