# Public image plus keys and credentials. Build context is $HOME (see update).
# No `# syntax=` line: the external frontend resolves FROM against the registry,
# skipping a freshly built local yashanand1910/dev.
FROM yashanand1910/dev:latest

ARG USER=yashanand

ENV PROMPT_CTX="dev-private"

# Setup credentials and env (since image is private)
ADD --chown=${USER}:${USER} .oh-my-zsh/custom/env.zsh .oh-my-zsh/custom/env.zsh
ADD --chown=${USER}:${USER} .ssh .ssh
ADD --chown=${USER}:${USER} .gnupg/public.key .gnupg/public.key
ADD --chown=${USER}:${USER} .gnupg/private.key .gnupg/private.key
RUN --mount=type=secret,id=github_key,uid=1000 --mount=type=secret,id=dockerhub_key,uid=1000 <<EOT
set -eux
gpg --batch --import .gnupg/public.key
gpg --batch --import .gnupg/private.key
printf "5\ny\n" | gpg --batch --yes --command-fd 0 --edit-key $(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2) trust quit
docker login -u yashanand1910 --password-stdin < /run/secrets/dockerhub_key
gh auth login -h github.com -p ssh --skip-ssh-key --with-token < /run/secrets/github_key
EOT

# Claude Code memory (projects/*/memory), session transcripts and prompt history.
# Bind-mounted so the rest of ~/.claude (login token, caches) stays out of the image
RUN --mount=type=bind,source=.claude,target=/tmp/claude <<EOT
set -eux
for p in projects history.jsonl; do
    [ ! -e /tmp/claude/$p ] || sudo cp -r /tmp/claude/$p .claude/
done
sudo chown -R ${USER}:${USER} .claude
EOT

# Replace the copied dotfiles with a real checkout (symlinks keep pointing here)
RUN rm -rf code/dotfiles && git clone git@github.com:yashanand1910/dotfiles.git code/dotfiles
