mkdir -p "${XDG_STATE_HOME:-"${HOME}/.local/state"}"
HISTFILE="${XDG_STATE_HOME:-"${HOME}/.local/state"}"/bash_history

if [ -n "$PS1" ]; then
    PS1="[\u@\h \W]\\$ "
fi
