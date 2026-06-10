# sudo
alias sudo="sudo -i"

# grep
alias grep="grep -sn --color=auto"

# git
alias gd="vi +DiffviewOpen"
alias gs="vi +DiffviewFileHistory"

# rm
alias rm="rm -I -v"

# ls
alias ls="ls --group-directories-first --color=auto -h"
alias la="ll -a"

# vim
alias vi=nvim
alias vim=vi
alias svi="sudo -E nvim"
alias svim=svi

# python
alias py=python
alias python=python3
alias pyenv="source ~/venv/bin/activate"

# gentoo
alias e="sudo emerge"
alias eq="sudo equery"
alias uc="sudo dispatch-conf"
alias eix="sudo eix"
alias es="sudo eselect"

# less
alias less="less -i --use-color"

# kernel
alias kconfig='cat /proc/config.gz | gunzip | less'

# lazydocker
alias lazydocker="TERM=xterm lazydocker"

# kubernetes
alias kc="kubectl"
alias k9s="k9s -A --logoless"

# pnpm
export PNPM_HOME="/home/ubuntu/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# The next line updates PATH for Nebius CLI.
if [ -f '/home/yashanand/.nebius/path.zsh.inc' ]; then source '/home/yashanand/.nebius/path.zsh.inc'; fi
# The next line enables shell command completion for Nebius CLI.
if [ -f '/home/yashanand/.nebius/completion.zsh.inc' ]; then source '/home/yashanand/.nebius/completion.zsh.inc'; fi

# gemini
alias gm="NODE_NO_WARNINGS=1 gemini"
