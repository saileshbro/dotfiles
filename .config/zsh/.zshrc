eval "$(starship init zsh)"
source ~/.alias
plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh
source $XDG_DATA_HOME/cargo/env
bindkey '  ' autosuggest-accept
bindkey '^ ' autosuggest-execute
# if [ -z $TMUX ]; then; tmux; fi
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7
eval "$(fnm env --use-on-cd)"
eval "$(github-copilot-cli alias -- "$0")"


export PATH="$XDG_DATA_HOME/npm/bin:$PATH"
export PATH="/opt/homebrew/opt/ccache/libexec:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$PATH":"$HOME/.pub-cache/bin"
source <(fzf --zsh)


HISTFILE="$XDG_STATE_HOME"/zsh/history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi
[[ "$TERM_PROGRAM" == "CodeEditApp_Terminal" ]] && . "/Applications/CodeEdit.app/Contents/Resources/codeedit_shell_integration.zsh"
[[ -f /Users/saileshbro/.config/.dart-cli-completion/zsh-config.zsh ]] && . /Users/saileshbro/.config/.dart-cli-completion/zsh-config.zsh || true
