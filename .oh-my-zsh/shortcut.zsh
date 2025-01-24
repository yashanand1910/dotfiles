# sudo
alias sudo="sudo -E"

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
