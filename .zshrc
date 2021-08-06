source ~/.exports
source ~/.functions
ZSH_THEME="spaceship"
SPACESHIP_PROMPT_ADD_NEWLINE='false'
SPACESHIP_PROMPT_SEPARATE_LINE='false'
if [[ $USER != '' && $USER == 'root' ]] then
  ZSH_DISABLE_COMPFIX='true'
fi
plugins=(git zsh-autosuggestions extract zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh
source ~/.completions
source ~/.alias
