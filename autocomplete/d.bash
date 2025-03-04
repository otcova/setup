_d() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($(
    pushd "$DESKTOP" >/dev/null && compgen -dS "/" -- "$cur"
    popd >/dev/null
  ))
}

complete -F _d -o nospace -o bashdefault -o default d
