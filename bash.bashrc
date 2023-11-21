#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ $DISPLAY ]] && shopt -s checkwinsize

PS1='[\u@\h \W]\$ '

case ${TERM} in
  Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*)
    PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')

    ;;
  screen*)
    PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
    ;;
esac

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

alias myip='curl ipinfo.io/io'
alias grep='grep --color=auto'
alias ineedmirrors="reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
alias ll="ls -la --color=auto"
alias ip='ip -color=auto'
export LESS='-R --use-color -Dd+r$Du+b$'
alias ls='ls --color=auto'

# AutoCD
shopt -s autocd

#command help
source /usr/share/doc/pkgfile/command-not-found.bash
