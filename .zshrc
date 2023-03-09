eval "$(fnm env --shell=zsh)"
eval "$(starship init zsh)"
eval "$(rbenv init - zsh)"
source "$HOME/.cargo/env"
source ~/.exports
source ~/.functions
SPACESHIP_PROMPT_ADD_NEWLINE='false'
SPACESHIP_PROMPT_SEPARATE_LINE='false'
if [[ $USER != '' && $USER == 'root' ]]; then
  ZSH_DISABLE_COMPFIX='true'
fi
plugins=(git zsh-autosuggestions extract zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh
source ~/.completions
source ~/.alias

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
## [Completion] 
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/saileshbro/.dart-cli-completion/zsh-config.zsh ]] && . /Users/saileshbro/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]
## keybindings for zsh-sutosuggestions
bindkey '  ' autosuggest-accept
bindkey '^ ' autosuggest-execute
