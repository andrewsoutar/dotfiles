test -r /home/user/.opam/opam-init/init.zsh && . /home/user/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

[ "$TERM" = "dumb" ] && unsetopt zle && PS1='$ ' && return

[ -z "$TMUX" ] && exec tmux attach

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle :compinstall filename '/home/user/.zshrc'

autoload -Uz compinit
compinit

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=100000
setopt appendhistory autocd extendedglob notify
unsetopt beep nomatch
bindkey -e

source ~/.zsh/antigen.zsh
antigen use oh-my-zsh
antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

source /usr/share/powerline/bindings/zsh/powerline.zsh
