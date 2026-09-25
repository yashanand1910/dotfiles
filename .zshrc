# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="nicoulaj"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode auto  # update automatically without asking

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Completion speedup dump files (see https://www.reddit.com/r/zsh/comments/fqpidr/removing_zcompdump_file_creation/)
ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# zsh-claude-code: Alt+\ turns the typed request into a command. The default
# ^X is a prefix for many completion widgets, so zle stalls KEYTIMEOUT on
# every press to disambiguate. Explain stays on Alt+E. Sonnet measured both
# faster AND more careful than haiku for one-liners.
ZSH_CLAUDE_SUGGEST_KEY='^[\'

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    vi-mode
    git
    fzf
    zsh-autosuggestions
    zsh-claude-code
    zsh-syntax-highlighting  # must stay last
)

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# nicoulaj defaults to xterm-256 colors ($FG[071] etc.), which terminals never
# remap — only ANSI 0-15 follow the kitty/tokyonight palette. Override with
# base-16 codes so the prompt tracks whatever theme the terminal has loaded.
PROMPT_SUCCESS_COLOR=$'\e[32m'   # green   -> tokyonight #9ece6a
PROMPT_FAILURE_COLOR=$'\e[31m'   # red     -> tokyonight #f7768e
PROMPT_VCS_INFO_COLOR=$'\e[90m'  # br-black-> tokyonight #414868

source "$ZSH"/oh-my-zsh.sh

# Strip the path off nicoulaj's left prompt — keep only the ❯ (❯❯❯ as root).
# Inside a repo the right prompt already carries repo/branch context; outside
# one, nvcsformats moves %~ into the right prompt so the path is never lost.
zstyle ':vcs_info:*:*' nvcsformats "" "%~"
PROMPT="%(0?.%{$PROMPT_SUCCESS_COLOR%}.%{$PROMPT_FAILURE_COLOR%})${SSH_TTY:+[%n@%m]}%{$FX[bold]%}%(!.$PROMPT_ROOT_END.$PROMPT_DEFAULT_END)%{$FX[no-bold]%}%{$FX[reset]%} "

# Snappier Esc in vi-mode (default 40 = 400ms). Not lower than 15: multi-key
# sequences like the vi-mode 'vv' need the window to register.
KEYTIMEOUT=15

# History: omz defaults are 50k/10k with dupes; keep everything, once
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Load Angular CLI autocompletion.
# source <(ng completion script)

# For error "signing failed: Inappropriate ioctl for device"
# ref: https://stackoverflow.com/questions/57591432/gpg-signing-failed-inappropriate-ioctl-for-device-on-macos-with-maven
export GPG_TTY=$(tty)

# Start tmux if not already
# if [ -z "$TMUX" ]; then
#     tmux new-session -A
# fi

# Notify when a command running >=15s finishes while I'm not looking at it.
# NOTE: kitty's notify_on_cmd_finish relies on OSC 133 prompt marks which tmux
# does not forward to the outer terminal, so it never fires inside tmux — hence
# this shell-level equivalent.
if command -v notify-send >/dev/null; then
    zmodload zsh/datetime
    autoload -Uz add-zsh-hook

    CMD_NOTIFY_THRESHOLD=15
    # interactive/long-by-design programs that should never trigger a notification
    CMD_NOTIFY_IGNORE=(nvim vim vi less man ssh mosh k9s btop htop top lazydocker lazygit fzf tmux watch journalctl tail claude)

    # hyprctl needs HYPRLAND_INSTANCE_SIGNATURE, which shells inside tmux don't
    # inherit (tmux server predates/outlives the compositor session) — recover
    # it from the hypr runtime dir.
    __cmd_notify_hyprctl() {
        local rt=${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr sig
        # the env signature goes stale when Hyprland restarts under a
        # long-lived tmux server, and hyprctl exits 0 even when it can't
        # connect — only trust a signature whose IPC socket exists
        for sig in "$HYPRLAND_INSTANCE_SIGNATURE" ${(f)"$(ls -t $rt 2>/dev/null)"}; do
            if [[ -n $sig && -S $rt/$sig/.socket.sock ]]; then
                HYPRLAND_INSTANCE_SIGNATURE=$sig hyprctl "$@" 2>/dev/null
                return
            fi
        done
        return 1
    }

    __cmd_notify_preexec() {
        __cmd_notify_start=$EPOCHSECONDS
        __cmd_notify_cmd=$1
    }

    __cmd_notify_precmd() {
        [[ -z $__cmd_notify_start ]] && return
        local elapsed=$(( EPOCHSECONDS - __cmd_notify_start ))
        local cmd=$__cmd_notify_cmd
        unset __cmd_notify_start __cmd_notify_cmd
        (( elapsed < CMD_NOTIFY_THRESHOLD )) && return

        local -a words; words=(${(z)cmd})
        local first=${words[1]:t}
        [[ $first == sudo && -n ${words[2]} ]] && first=${words[2]:t}
        [[ -n ${CMD_NOTIFY_IGNORE[(r)$first]} ]] && return

        local pane=$TMUX_PANE sess=
        [[ -n $pane ]] && sess=$(tmux display -p -t "$pane" '#{session_name}' 2>/dev/null)

        # suppress when already looking at this pane: it is the active pane of
        # its session AND the focused Hyprland window is the kitty window
        # showing that session (kitty titles are '#S: #W' via tmux set-titles)
        if [[ -n $pane ]]; then
            local visible=$(tmux display -p -t "$pane" \
                '#{&&:#{session_attached},#{&&:#{window_active},#{pane_active}}}' 2>/dev/null)
            local focused_title=$(__cmd_notify_hyprctl activewindow -j | jq -r '.title' 2>/dev/null)
            [[ $visible == 1 && $focused_title == "$sess: "* ]] && return
        fi

        # -A implies --wait, so run in a disowned subshell to not block the prompt.
        # Clicking the notification jumps to the pane and focuses the kitty
        # window whose tmux client shows that session.
        (
            action=$(notify-send -a tmux -t 10000 -A default=Open "Done in ${elapsed}s" "[$sess] ${cmd:0:100}")
            [[ $action == default && -n $pane ]] || exit 0
            tmux select-pane -t "$pane" 2>/dev/null
            tmux select-window -t "$pane" 2>/dev/null
            # if no kitty window shows this session, bring it up on the client
            # that last displayed it (@home_client, maintained by tmux hooks);
            # fall back to the most recently used client
            if ! tmux list-clients -F '#{session_name}' 2>/dev/null | grep -qxF "$sess"; then
                client=$(tmux show-option -t "$sess" -qv @home_client 2>/dev/null)
                tmux list-clients -F '#{client_name}' 2>/dev/null | grep -qxF "$client" || client=
                [[ -z $client ]] && client=$(tmux list-clients -F '#{client_activity} #{client_name}' 2>/dev/null \
                    | sort -rn | head -n1 | cut -d' ' -f2)
                [[ -n $client ]] && tmux switch-client -c "$client" -t "$pane" 2>/dev/null
            fi
            # find the kitty window now titled '$sess: ...' (retry: the title
            # takes a moment to catch up after switch-client)
            addr=
            for _ in 1 2 3 4 5; do
                sleep 0.2
                addr=$(__cmd_notify_hyprctl clients -j | jq -r --arg t "$sess: " \
                    '[.[] | select(.class=="kitty" and (.title|startswith($t)))][0].address // empty' 2>/dev/null)
                [[ -n $addr ]] && break
            done
            # Under the Lua config `hyprctl dispatch X` evaluates X as Lua, so the
            # old "focuswindow address:0x..." string is a syntax error.
            [[ -n $addr ]] && __cmd_notify_hyprctl dispatch \
                "hl.dsp.focus({ window = 'address:$addr' })"
        ) >/dev/null 2>&1 &!
    }

    add-zsh-hook preexec __cmd_notify_preexec
    add-zsh-hook precmd __cmd_notify_precmd
fi

# LINUX-ONLY CONFIG (non-macOS)
if [[  "$(uname)" == "Linux" ]]; then
    # Lima BEGIN (for VM only)
    # Make sure iptables and mount.fuse3 are available
    PATH="$PATH:/usr/sbin:/sbin"
    export PATH
    # Lima END

    # Start display server
    # if [[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]]; then
    #     exec startx
    #     # dbus-run-session Hyprland
    # fi
    # neofetch
fi
