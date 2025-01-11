_d() {
  local cur=${COMP_WORDS[COMP_CWORD]}

  COMPREPLY=($(
    pushd "$DESKTOP" >/dev/null && compgen -fd "$cur"
    popd >/dev/null
  ))
}

complete -F _d -o bashdefault -o default d
