alias flutter='fvm flutter'
alias dart='fvm dart'
alias copy='clipboard'
alias flc='flutter clean'
alias brw='flutter pub run build_runner watch --delete-conflicting-outputs'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
ZSH_THEME="spaceship"
SPACESHIP_PROMPT_ADD_NEWLINE='false'
SPACESHIP_PROMPT_SEPARATE_LINE='false'
function pdelete(){
  sudo pacman -Rsun $(pacman -Qqdt)
  yay -Scc
}

if [[ $USER != '' && $USER == 'root' ]] then
  ZSH_DISABLE_COMPFIX='true'
fi
export ZSH="/home/saileshbro/.oh-my-zsh"
plugins=(git zsh-autosuggestions extract zsh-syntax-highlighting zsh-completions)
eval "$(fnm env --use-on-cd)"
source $ZSH/oh-my-zsh.sh




# tabtab source for yarn package
# uninstall by removing these lines or running `tabtab uninstall yarn`
[[ -f /home/saileshbro/.config/yarn/global/node_modules/tabtab/.completions/yarn.zsh ]] && . /home/saileshbro/.config/yarn/global/node_modules/tabtab/.completions/yarn.zsh

# EXPORTS
# *********************************
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="$PATH":"$HOME/.dotnet/tools"
export PATH="$PATH":"$HOME/.yarn/bin"
export CHROME_EXECUTABLE=$(which brave)


# completions handling
fpath+=~/.zfunc
_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")
  reply=( "${(ps:\n:)completions}" )
}

compctl -K _dotnet_zsh_complete dotnet
autoload -U compinit && compinit
zstyle ':completion:*' menu select
