# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

umask 0022

# update PATH before checking for an interactive shell
export PATH=/opt/homebrew/bin::$PATH

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

export PATH=/opt/homebrew/opt/gnu-getopt/bin:/sbin:/usr/sbin:$HOME/.local/bin:$PATH
export PAGER="less -R"
export EDITOR=nvim
export SYSTEMD_PAGER='less -r'
export HISTTIMEFORMAT="%D %T "

. ~/.proxyrc

# stupidly fun prompt
fg_default='\e[39m'; fg_black='\e[30m'; fg_red='\e[31m'; fg_green='\e[32m'; fg_yellow='\e[33m'; fg_blue='\e[34m'; fg_magenta='\e[35m'; fg_cyan='\e[36m'; fg_light_gray='\e[37m'; fg_dark_gray='\e[90m'; fg_light_red='\e[91m'; fg_light_green='\e[92m'; fg_light_yellow='\e[93m'; fg_light_blue='\e[94m'; fg_light_magenta='\e[95m'; fg_light_cyan='\e[96m'; fg_white='\e[97m'; bg_default='\e[49m'; bg_black='\e[40m'; bg_red='\e[41m'; bg_green='\e[42m'; bg_yellow='\e[43m'; bg_blue='\e[44m'; bg_magenta='\e[45m'; bg_cyan='\e[46m'; bg_light_gray='\e[47m'; bg_dark_gray='\e[100m'; bg_light_red='\e[101m'; bg_light_green='\e[102m'; bg_light_yellow='\e[103m'; bg_light_blue='\e[104m'; bg_light_magenta='\e[105m'; bg_light_cyan='\e[106m'; bg_white='\e[107m'

function __prompt_command {
  local rc="$?"

  git_branch=$(git branch 2> /dev/null | \
    sed -e '/^[^*]/d' -e 's/^\* //')
# kube_context="$(oq -i yaml -r '."current-context"' .kube/config)"
# faster
  kube_context="$(gsed -nr 's/^current-context: (.*)/\1/p' ~/.kube/config)"
  kube_ns=$(oq -i yaml -r '."current-context" as $cc | .contexts[] | select(.name == $cc) | .context.namespace' ~/.kube/config)

  case $rc in
    0) rc_emo="😃";;
    1) rc_emo="🤮 ";;
    2) rc_emo="🐚🔥";;
    126) rc_emo="🤪 ";;
    127) rc_emo="😨";;
    128) rc_emo="👿";;
    *)
      if [[ $rc -gt 128 ]] && [[ $rc -le 160 ]]; then
        signal=$(($rc - 128))
        case $signal in
          1) rc_emo="🔌 HUP";;
          2) rc_emo="🚫 INT";;
          3) rc_emo="💥 QUIT";;
          4) rc_emo="🚷 ILL";;
          5) rc_emo="🥁 TRAP";;
          6) rc_emo="🙀 ABRT";;
          9) rc_emo="☠️ KILL";;
          11) rc_emo="💣 SEGV";;
          13) rc_emo="🪠 PIPE";;
          14) rc_emo="⏰ ALRM";;
          15) rc_emo="🔪 TERM";;
          *) rc_emo="😶 unknown signal";;
        esac
      else
        rc_emo="👎 $rc"
      fi;;
  esac

  PS1=$(printf "$rc_emo\n\n$fg_light_cyan\w $fg_light_red$git_branch$fg_light_yellow $kube_context/$kube_ns$fg_default\n\\$ ")
}

PROMPT_COMMAND=__prompt_command

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

alias ls='ls -Fh --color'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
source /opt/homebrew/etc/bash_completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
  if [ -n "$(which aws_completer)" ]; then
          complete -C aws_completer aws
  fi
  if [ -n "$(which terraform)" ]; then
    complete -C $(which terraform) terraform
    alias t=terraform
    complete -C $(which terraform) t
  fi
  if [ -n "$(which kubectl)" ]; then
    source <(kubectl completion bash)
  fi
  if [ -n "$(which helm)" ]; then
    source <(helm completion bash)
  fi
  if [ -n "$(which op)" ]; then
    source <(op completion bash)
  fi
  if [ -n "$(which eksctl)" ]; then
    source <(eksctl completion bash)
  fi
  if [ -n "$(which gh)" ]; then
    source <(gh completion bash)
  fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# tabtab source for packages
[ -f ~/.config/tabtab/bash/__tabtab.bash ] && . ~/.config/tabtab/bash/__tabtab.bash || true
eval "$(/opt/homebrew/bin/brew shellenv)"
export PNPM_HOME="/Users/alex/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
