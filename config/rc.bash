#!/bin/bash

#######################################
####### Continue if Interactive #######
#######################################

case $- in
*i*) ;;
*) return ;;
esac

######################
####### Colors #######
######################

if [ "$(tput colors)" -ge 8 ]; then
  reset=$'\e[0m'
  black=$'\e[1;30m'
  red=$'\e[1;31m'
  green=$'\e[1;32m'
  yellow=$'\e[1;33m'
  blue=$'\e[1;34m'
  purple=$'\e[1;35m'
  cyan=$'\e[1;36m'
  white=$'\e[1;37m'
fi

#####################
####### Alias #######
#####################

help=''
function header() {
  help+=$'\n'$blue"$1"$reset$'\n'
}
function cmd-info() {
  help+="$1"$green"$2"$reset$'\n'
}
function cmd() {
  cmd-info "$1" "$2"
  aliasName=($1)
  alias "${aliasName[0]}"="$3"
}

header 'Setup Program Configurations'
cmd-info 'config-all'
cmd-info 'config-tmux'
cmd-info 'config-nvim'
cmd-info 'config-git'
cmd-info 'config-kitty'

header 'Grep Aliases'
cmd 'hs <regex>  ' '# History search' 'cat ~/.bash_history | rg'
cmd 'fs <regex>  ' '# File search' 'rg --files | rg'

header 'Git Aliases'
cmd 'ga     ' '# add, commit' 'git add . && git commit --message'
cmd 'gp     ' '# pull, push' 'git pull && git push'
cmd 'gs     ' '# status' 'git status'
cmd 'gb     ' '# branch' 'git branch'
cmd 'glog   ' '# log' 'git log --pretty="format:%C(yellow)%h %Cblue%>(12)%ad %Cgreen%<(7)%aN%Cred%d %Creset%s" --date="relative"'
cmd 'gpull  ' '# pull' 'git pull'
cmd 'gpush  ' '# push' 'git push'

header 'Vim'
cmd-info 'v      ' '# cd, nvim'

header 'Fast Edit'
cmd 'setup  ' '# v ~/.otcova-setup' "nvim $HOME/.otcova-setup"
cmd 'rc     ' '# v ~/.otcova-setup/rc.bash' "nvim $HOME/.otcova-setup/rc.bash"

header 'Directories'
cmd 'h      ' '# ~' 'cd ~'
cmd 'd      ' '# ~/Desktop/' 'cd ~/Desktop/'

header 'Tmux'
cmd 'tmux-main ' '# Main tmux session' 'tmux new -As main'

header 'Binaries'
cmd-info 'nvim   ' '# Source: https://github.com/neovim/neovim/releases/tag/v0.10.2 (nvim-linux64.tar.gz)'
cmd-info 'rg     ' '# Source: https://github.com/BurntSushi/ripgrep/releases/tag/14.1.1 (ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz)'
cmd-info 'fd     ' '# Source: https://github.com/sharkdp/fd/releases/tag/v10.2.0 (fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz)'
cmd-info 'bat    ' '# Source: https://github.com/sharkdp/bat/releases/tag/v0.24.0 (bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz)'

alias otcova=". ${HOME}/.otcova-setup/config/rc.bash && echo '${help}' | less -r"
unset header cmd-info cmd help

#########################
####### Functions #######
#########################

function ask-rm() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  ask-rm <path>"
    echo ""
    echo "Asks for confirmation and then 'rm -rf <path>'"
    echo "If <path> does not exists, it does nothing"
    return
  fi

  if [ -e "$1" ] || [ -L "$1" ]; then
    read -rn 1 -p 'Override file '$blue"$1"$reset'? '
    if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
      echo 'es'
      rm -rf "$1"
    else
      echo ''
      return 1
    fi
  fi
}

function link() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage:"
    echo "  link [<src>] [<dst>]"
    echo ""
    echo "<src> default value is $PWD"
    echo "<dst> default value is $HOME/Desktop/"
    return
  fi

  src="${1:-$PWD}"
  dst="${2:-$HOME/Desktop}"

  if [ -d "$dst" ]; then
    dst+='/'
    dst+=$(basename "$src")
  fi

  if [ "$src" -ef "$dst" ]; then
    return # File exists and is correct, do nothing
  fi

  if ask-rm "$dst"; then
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
  fi
}

function v() {
  if [ -f "$1" ]; then
    nvim "$1"
  else
    cd "$1"
    nvim .
  fi
}

function git-install() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  git-install <repo-url> <dst>"
    echo ""
    echo "It will"
    echo "  - git pull  $green# If <dst> is a git repository with origin <repo-url>$reset"
    echo "  - ask-rm <dst>, git clone $green  # If <dst> is not a git repository with origin <repo-url>$reset"
    return
  fi

  if [ "$(git -C "$2" remote get-url origin 2>/dev/null)" = "$1" ]; then
    git pull
  else
    ask-rm "$2"
    git clone "$1" "$2"
  fi
}

##############################
####### Configurations #######
##############################

function config-all() {
  echo "${blue}Tmux${reset}"
  config-tmux
  echo "${blue}Nvim${reset}"
  config-nvim
  echo "${blue}Kitty${reset}"
  config-kitty
}

function config-tmux() {
  link ~/.otcova-setup/config/tmux.conf ~/.tmux.conf
  git-install 'https://github.com/tmux-plugins/tpm' ~/.tmux/plugins/tpm
}

function config-nvim() {
  git-install https://github.com/LazyVim/starter ~/.config/nvim
  link ~/.otcova-setup/config/nvim.lua ~/.config/nvim/lua/plugins/otcova.lua
}

function config-kitty() {
  wget -qO- https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  link ~/.local/kitty.app/bin/kitty ~/.bin/kitty
  link ~/.local/kitty.app/bin/kitten ~/.bin/kitten

  link ~/.otcova-setup/config/kitty.conf ~/.config/kitty/kitty.conf
}

function config-git() {
  echo "TODO: gen keys"
  echo "TODO: set default editor"
  echo "TODO: set user"
  echo "TODO: install delta"
}

function _otcova-add-rc-hook() {
  config_line=". '${HOME}/.otcova-setup/config/rc.bash'"

  case "$0" in
  *zsh*) rc_file="${HOME}/.zshrc" ;;
  *tcsh*) rc_file="${HOME}/.tcshrc" ;;
  *) rc_file="${HOME}/.bashrc" ;;
  esac

  if [ -e "$rc_file" ]; then
    if ! grep -q "$config_line" "$rc_file"; then
      echo "$config_line" >>"$rc_file"
    fi
  else
    echo "$config_line" >"$rc_file"
  fi
}

function _otcova-remove-rc-hook() {
  config_line=". '${HOME}/.otcova-setup/config/rc.bash'"

  for rc_file_name in .bashrc .zshrc .tcshrc; do
    rc_file="${HOME}/${rc_file_name}"
    if [ -e "${rc_file}" ]; then
      grep -Fvx "${config_line}" "${rc_file}" >"${rc_file}.tmp"
      mv "${rc_file}.tmp" "${rc_file}"
    fi
  done
}

function otcova-update() {
  git -C ~/.otcova-setup pull

  _otcova-remove-rc-hook
  . "${HOME}/.otcova-setup/config/rc.bash"
  _otcova-add-rc-hook
}

######################
####### Prompt #######
######################

if [ -n "$(command -v __git_ps1)" ]; then
  PROMPT_COMMAND='PS1_GIT=$(__git_ps1 " (%s)")'
fi
PS1='\n'$green'\w'$blue'${PS1_GIT}'$reset'\n> '

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#################################
####### Load Autocomplete #######
#################################

function _lazy_autocomplete() {
  . ~/.otcova-setup/autocomplete/"$1".bash
  "_$1" "$@"
}

for command in fd rg bat; do
  complete -F _lazy_autocomplete -o bashdefault -o default $command
done

######################
######### Path #######
######################

PATH="$HOME/.otcova-setup/bin:$HOME/.bin:$PATH"

#########################
####### WSL Fixes #######
#########################

if [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  ln -s /mnt/wslg/runtime-dir/wayland-0 /run/user/* 2>/dev/null
  ln -s /mnt/wslg/runtime-dir/wayland-0.lock /run/user/* 2>/dev/null
fi

######################################
####### Open tmux main session #######
######################################

if [ -z "$TMUX" ]; then
  tmux-main
  exit
fi
