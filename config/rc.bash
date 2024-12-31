#!/bin/sh

######################
######### Path #######
######################

PATH="$HOME/.otcova-setup/bin:$HOME/.bin:$PATH:$HOME/.otcova-setup/scripts:$HOME/.otcova-setup/config/scripts"

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

  alias ls='ls --color=auto'
fi

#####################
####### Alias #######
#####################

OTCOVA_HELP=''
function header() {
  [ -n "$OTCOVA_HELP" ] && OTCOVA_HELP+=$'\n'
  OTCOVA_HELP+=$blue"$1"$reset$'\n'
}
function cmd-info() {
  OTCOVA_HELP+="$1"$green"$2"$reset$'\n'
}
function cmd() {
  cmd-info "$1" "$2"
  aliasName=($1)
  alias "${aliasName[0]}"="$3"
}

header 'Configure Program'
cmd-info 'c-all'
cmd-info 'c-tmux'
cmd-info 'c-nvim'
cmd-info 'c-git'
cmd-info 'c-kitty'

header 'Configure LSP'
cmd-info 'c-rust'

header 'Search'
cmd 'hs <regex> ' '# History search' 'cat ~/.bash_history | rg'
cmd 'fs <regex> ' '# File search' 'rg --files | rg'

header 'Git Aliases'
cmd 'ga <msg>   ' '# add all, commit' 'git add -A && git commit --message'
cmd 'gc <msg>   ' '# commit' 'git commit --message'
cmd 'gp         ' '# pull, push' 'git pull --ff-only && git push'
cmd 'gs         ' '# status' 'git status && git pull --ff-only'
cmd 'gb         ' '# branch' 'git branch'
cmd 'gd         ' '# diff' 'git diff'
cmd 'glog       ' '# log' 'git log --pretty="format:%C(yellow)%h %Cblue%>(12)%ad %Cgreen%<(7)%aN%Cred%d %Creset%s" --date="relative"'
cmd 'gpull      ' '# pull' 'git pull'
cmd 'gpush      ' '# push' 'git push'

header 'Vim'
cmd-info 'v          ' '# cd, nvim'

header 'Fast Edit'
cmd 'setup      ' '# nvim ~/.otcova-setup' 'nvim $HOME/.otcova-setup'
cmd 'rc         ' '# nvim ~/.otcova-setup/config/rc.bash' 'nvim $HOME/.otcova-setup/config/rc.bash'
cmd 'brc        ' '# nvim ~/.bashrc' 'nvim $HOME/.bashrc'

header 'Directories'
cmd 'h          ' '# ~' 'cd ~'
cmd 'd          ' '# ~/Desktop/' 'cd ~/Desktop/'

header 'Tmux'
cmd-info 'tmux-main  ' '# Main tmux session'

header 'Binaries'
cmd-info 'nvim       ' '# Source: https://github.com/neovim/neovim/releases/tag/v0.10.2 (nvim-linux64.tar.gz)'
cmd-info 'rg         ' '# Source: https://github.com/BurntSushi/ripgrep/releases/tag/14.1.1 (ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz)'
cmd-info 'fd         ' '# Source: https://github.com/sharkdp/fd/releases/tag/v10.2.0 (fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz)'
cmd-info 'bat        ' '# Source: https://github.com/sharkdp/bat/releases/tag/v0.24.0 (bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz)'
cmd-info 'fzf        ' '# Source: https://github.com/junegunn/fzf/releases/tag/v0.57.0 (fzf-0.57.0-linux_amd64.tar.gz)'
cmd-info 'delta      ' '# Source: https://github.com/dandavison/delta/releases/tag/0.18.2 (delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz)'
cmd-info 'lg         ' '# Source: https://github.com/jesseduffield/lazygit/releases/tag/v0.44.1 (lazygit_0.44.1_Linux_x86_64.tar.gz)'
cmd-info 'yazi       ' '# Source: https://github.com/sxyazi/yazi/releases/tag/v0.4.2 (yazi-x86_64-unknown-linux-gnu.zip)'

header 'Otcova Setup'
cmd-info 'otcova           ' '# Reload rc and show help'
cmd-info 'otcova-update    ' '# Update and reload'
cmd-info 'otcova-install   ' '# Sets up the rc and starts c-all'
cmd-info 'otcova-uninstall ' '# Removes ~/.otcova-setup'

unset header cmd-info cmd

#########################
####### Functions #######
#########################

function v() {
  if [ -f "$1" ]; then
    nvim "$1"
  else
    cd "$1"
    nvim .
  fi
}

function tmux-main() {
  if [ -z "$TMUX" ]; then
    if ! tmux a -t main 2>/dev/null; then
      tmux new -s main \; new-window \; select-window -t 0 >/dev/null
    fi
  fi
}

##############################
####### Configurations #######
##############################

function _otcova-add-rc-hook() {
  config_line='. ~/.otcova-setup/config/rc.bash'
  rc_hook_comment='# Source the otcova setup rc here'

  rc_hook_comment_found=false

  for rc_file_name in .bashrc .zshrc .tcshrc; do
    rc_file="${HOME}/${rc_file_name}"

    if grep -Fxq "$rc_hook_comment" "$rc_file" 2>/dev/null; then
      rc_hook_comment_found=true
      sed -i "s|^$rc_hook_comment$|$config_line|" "$rc_file"
    fi
  done

  # If no rc_hook_comment_found, add the config_line to the currect rc file
  if ! "$rc_hook_comment_found"; then
    case "$0" in
    *zsh*) rc_file="${HOME}/.zshrc" ;;
    *tcsh*) rc_file="${HOME}/.tcshrc" ;;
    *) rc_file="${HOME}/.bashrc" ;;
    esac

    if ! grep -Fxq "$config_line" "$rc_file"; then
      echo "$config_line" >>"$rc_file"
    fi
  fi
}

function _otcova-remove-rc-hook() {
  config_line='. ~/.otcova-setup/config/rc.bash'
  rc_hook_comment='# Source the otcova setup rc here'

  for rc_file_name in .bashrc .zshrc .tcshrc; do
    rc_file="${HOME}/${rc_file_name}"
    if [ -e "${rc_file}" ]; then
      sed -i "s|^$config_line$|$rc_hook_comment|" "$rc_file"
    fi
  done
}

function otcova() {
  . ${HOME}/.otcova-setup/config/rc.bash

  # update README.md with new possibly new $OTCOVA_HELP
  new_help="$(echo "$OTCOVA_HELP" | sed 's/\x1b\[[0-9;]*m//g')"

  sed -i '/```python/,$d' ~/.otcova-setup/README.md # Delete old_help
  echo '```python' >>~/.otcova-setup/README.md
  echo "$new_help" >>~/.otcova-setup/README.md
  echo '```' >>~/.otcova-setup/README.md

  echo "$OTCOVA_HELP" | less -r
}

function otcova-update() {
  git -C ~/.otcova-setup pull

  _otcova-remove-rc-hook
  . "${HOME}/.otcova-setup/config/rc.bash"
  _otcova-add-rc-hook
}

function otcova-install() {
  _otcova-add-rc-hook
  c-all
}

function otcova-uninstall() {
  rm -rf ~/.otcova-setup

  config_line='. ~/.otcova-setup/config/rc.bash'

  for rc_file_name in .bashrc .zshrc .tcshrc; do
    rc_file="${HOME}/${rc_file_name}"
    if [ -e "${rc_file}" ]; then
      grep -xvF "$config_line" "$rc_file" >"${rc_file}.grep.temp"
      mv "${rc_file}.grep.temp" "$rc_file"
    fi
  done
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
bind '"\C-s": clear-screen'

#################################
####### Load Autocomplete #######
#################################

function _lazy_autocomplete() {
  . ~/.otcova-setup/autocomplete/"$1".bash
  "_$1" "$@"
}

for command in fd rg bat yazi; do
  complete -F _lazy_autocomplete -o bashdefault -o default $command
done

#####################
####### Fixes #######
#####################

# Fix Ctrl-S Freeze
stty -ixon

# Fix WSL Wayland
if [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  ln -s /mnt/wslg/runtime-dir/wayland-0 "/run/user/$UID" 2>/dev/null
  ln -s /mnt/wslg/runtime-dir/wayland-0.lock "/run/user/$UID" 2>/dev/null
fi

######################################
####### Open tmux main session #######
######################################

if [ "$TERM" = "xterm-kitty" ]; then
  tmux-main
fi
