# syntax=docker/dockerfile:1

FROM nvidia/cuda:13.4.3-devel-ubuntu26.04

LABEL org.opencontainers.image.source=https://github.com/yashanand1910/dotfiles

ARG USER=yashanand
ARG UID=1000

# Install steps live in scripts/install.sh, shared with scripts/bootstrap
COPY --chmod=755 scripts/install.sh /usr/local/lib/dotfiles/install.sh
ENV PATH=/usr/local/lib/dotfiles:$PATH

RUN install.sh packages
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN install.sh docker-cli
RUN install.sh nvidia
RUN install.sh nvim
RUN install.sh node
RUN install.sh go
RUN install.sh tools
RUN install.sh gh
RUN install.sh k8s

# Setup user
RUN <<EOT
set -eux
usermod -l ${USER} ubuntu
groupmod -n ${USER} ubuntu
usermod -d /home/${USER} -m ${USER}
usermod -c "${USER}" -g ${USER} -G sudo -s /bin/zsh ${USER}
echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER}
EOT
USER ${USER}
WORKDIR /home/${USER}

RUN install.sh zsh
ENV TERM=xterm-256color
ENV PROMPT_CTX="dev"

RUN install.sh tmux
RUN install.sh rust
RUN install.sh claude

# Setup dotfiles (symlinked from ~/code/dotfiles, like on a host)
COPY --chown=${USER}:${USER} . code/dotfiles
RUN install.sh link

COPY --chown=${USER}:${USER} --chmod=755 entrypoint entrypoint

ENTRYPOINT ["./entrypoint"]
