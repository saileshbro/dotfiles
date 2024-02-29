if type compdef &>/dev/null; then
  _very_good_completion () {
    local reply
    local si=$IFS

    IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" very_good completion -- "${words[@]}"))
    IFS=$si

    if [[ -z "$reply" ]]; then
        _path_files
    else 
        _describe 'values' reply
    fi
  }
  compdef _very_good_completion very_good
fi
