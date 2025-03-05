# syntax=docker/dockerfile:1

FROM nvidia/cuda:12.8.0-devel-ubuntu24.04

LABEL org.opencontainers.image.source=https://github.com/yashanand1910/dotfiles

ARG USER=yashanand
ARG UID=1000
ARG GITHUB_KEY
ARG DOCKERHUB_KEY

ARG GO_VERSION=1.23.5
ARG NVIM_VERSION=0.10.4

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
apt-get install -y unzip
apt-get install -y python3-pip
apt-get install -y python3-venv
apt-get install -y gpg
apt-get install -y net-tools lsof
apt-get install -y locales
apt-get install -y man-db
apt-get install -y zip unzip tar
apt-get install -y gdb
EOT

# Set locale
RUN <<EOT
set -eux
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
EOT

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

# Setup user
RUN <<EOT
set -eux
groupadd -g 1000 ${USER}
useradd -rm -d /home/${USER} -s /bin/zsh -u ${UID} -g ${USER} -G sudo ${USER}
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
ENV TERM=xterm-256color
ENV PROMPT_CTX="dev-private"

# Setup tmux
RUN <<EOT
set -eux
sudo apt-get install -y tmux
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
EOT

# Setup neovim
RUN <<EOT
set -eux
curl -LO https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
EOT

# Setup NVIDIA container toolkit
RUN <<EOT
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
EOT

# Setup node (for nvim plugins)
RUN <<EOT
set -eux
curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
sudo -E bash nodesource_setup.sh
sudo apt-get install -y nodejs
rm nodesource_setup.sh
EOT

# Setup github CLI
RUN <<EOT
set -eux
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
EOT

# Setup go
RUN <<EOT
set -eux
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
rm go${GO_VERSION}.linux-amd64.tar.gz
EOT

# Setup miscelaneous
RUN <<EOT
set -eux
sudo apt-get install -y ripgrep
sudo apt-get install -y btop
sudo curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
EOT

# Setup credentials and env (since image is private)
ADD --chown=${USER}:${USER} .oh-my-zsh/custom/env.zsh .oh-my-zsh/custom/env.zsh
ADD --chown=${USER}:${USER} .ssh .ssh
ADD --chown=${USER}:${USER} .gnupg/public.key .gnupg/public.key
ADD --chown=${USER}:${USER} .gnupg/private.key .gnupg/private.key
RUN <<EOT
gpg --batch --import .gnupg/public.key
gpg --batch --import .gnupg/private.key
echo -e "5\ny\n" | gpg --batch --yes --command-fd 0 --edit-key $(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2) trust quit
docker login -u yashanand1910 -p ${DOCKERHUB_KEY}
echo ${GITHUB_KEY} > github_key
gh auth login --with-token < github_key
rm github_key
EOT

# Setup dotfiles
RUN <<EOT
mkdir code
cd code
git clone git@github.com:yashanand1910/dotfiles.git
cd -
ln -sf /home/${USER}/code/dotfiles/.config/* .config/
ln -sf /home/${USER}/code/dotfiles/.gitconfig .gitconfig
ln -sf /home/${USER}/code/dotfiles/.gitignore .gitignore
ln -sf /home/${USER}/code/dotfiles/.vimrc .vimrc
ln -sf /home/${USER}/code/dotfiles/.zshrc .zshrc
ln -sf /home/${USER}/code/dotfiles/.tmux.conf .tmux.conf
ln -sf /home/${USER}/code/dotfiles/.oh-my-zsh/* .oh-my-zsh/custom/
EOT

ADD --chown=${USER}:${USER} --chmod=755 code/dotfiles/entrypoint entrypoint

ENTRYPOINT ["./entrypoint"]
