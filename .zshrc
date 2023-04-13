source "$HOME/.cargo/env"
source ~/.exports
source ~/.functions
source ~/.completions
source ~/.alias
SPACESHIP_PROMPT_ADD_NEWLINE='false'
SPACESHIP_PROMPT_SEPARATE_LINE='false'
plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh
bindkey '  ' autosuggest-accept
bindkey '^ ' autosuggest-execute
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7
