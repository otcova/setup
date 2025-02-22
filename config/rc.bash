#!/bin/bash

######################
######### Path #######
######################

export PATH="$HOME/.otcova-setup/bin:$HOME/.otcova-setup/.bin:$PATH:$HOME/.otcova-setup/scripts"

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
  export reset=$'\e[0m'
  export black=$'\e[1;30m'
  export red=$'\e[1;31m'
  export green=$'\e[1;32m'
  export yellow=$'\e[1;33m'
  export blue=$'\e[1;34m'
  export purple=$'\e[1;35m'
  export cyan=$'\e[1;36m'
  export white=$'\e[1;37m'

  alias ls='ls --color=auto'
fi
unalias l 2>/dev/null

#####################
####### Alias #######
#####################

OTCOVA_HELP=''
function header() {
  [ -n "$OTCOVA_HELP" ] && OTCOVA_HELP+=$'\n'
  OTCOVA_HELP+=$blue"$1"$reset$'\n'
}
function cmd() {
  OTCOVA_HELP+="$1"$green"$2"$reset$'\n'
  if [ -n "$3" ]; then
    aliasName=($1)
    alias "${aliasName[0]}"="$3"
  fi
}

header 'Configure Program'
cmd 'c-all'
cmd 'c-tmux'
cmd 'c-nvim'
cmd 'c-git'
cmd 'c-kitty'

header 'Show help'
cmd 'h-git'
cmd 'h-bash'

header 'Configure LSP'
cmd 'c-rust'

header 'Search'
cmd 'hs  <regex> ' '# History search' 'cat ~/.bash_history | rg'
cmd 'fs  <regex> ' '# File search' 'rg --files | rg'
cmd 'pss <regex> ' '# Process search' 'ps -A | rg'

header 'Git Aliases'
cmd 'ga <msg>   ' '# add all, commit' 'git add -A && git commit --message'
cmd 'gc <msg>   ' '# commit' 'git commit --message'
cmd 'gp         ' '# pull, push' 'git pull --ff-only && git push'
cmd 'gs         ' '# status' 'git status && git pull --ff-only'
cmd 'gb         ' '# branch' 'git branch'
cmd 'gd         ' '# diff' 'git diff'
cmd 'gl         ' '# log' 'git log --pretty="format:%C(yellow)%h %Cblue%>(12)%ad %Cgreen%<(7)%aN%Cred%d %Creset%s" --date="relative"'
cmd 'gpull      ' '# pull' 'git pull'
cmd 'gpush      ' '# push' 'git push'

header 'Vim'
cmd 'v          ' '# cd, nvim'
cmd 'vc         ' '# cd ~/.config/nvim, nvim' 'sp ~/.config/nvim/ && nvim lua/plugins/otcova.lua'

header 'Fast Edit'
cmd 'rc         ' '# cd otcova-setup, nvim ~/.otcova-setup/config/rc.bash' 'sp "$HOME/.otcova-setup" && nvim ./config/rc.bash'
cmd 'brc        ' '# nvim ~/.bashrc' 'nvim $HOME/.bashrc'

header 'Directories'
cmd 'd          ' '# ~/Desktop/'
cmd 'o          ' '# ~/.otcova-setup/' 'cd ~/.otcova-setup'
cmd 'sp         ' '# Stack push/pop directory'

header 'Tmux'
cmd 'tmux-main  ' '# Main tmux session'

header 'Otcova Setup'
cmd 'otcova           ' '# Reload rc and show help'
cmd 'otcova-update    ' '# Update and reload'
cmd 'otcova-install   ' '# Sets up the rc and starts c-all'
cmd 'otcova-uninstall ' '# Removes ~/.otcova-setup'

header 'Binaries'
cmd 'nvim       ' '# Source: https://github.com/neovim/neovim/releases/tag/v0.10.2 (nvim-linux64.tar.gz)'
cmd 'rg         ' '# Source: https://github.com/BurntSushi/ripgrep/releases/tag/14.1.1 (ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz)'
cmd 'fd         ' '# Source: https://github.com/sharkdp/fd/releases/tag/v10.2.0 (fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz)'
cmd 'bat        ' '# Source: https://github.com/sharkdp/bat/releases/tag/v0.24.0 (bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz)'
cmd 'fzf        ' '# Source: https://github.com/junegunn/fzf/releases/tag/v0.57.0 (fzf-0.57.0-linux_amd64.tar.gz)'
cmd 'delta      ' '# Source: https://github.com/dandavison/delta/releases/tag/0.18.2 (delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz)'
cmd 'lg         ' '# Source: https://github.com/jesseduffield/lazygit/releases/tag/v0.44.1 (lazygit_0.44.1_Linux_x86_64.tar.gz)'
cmd 'yazi       ' '# Source: https://github.com/sxyazi/yazi/releases/tag/v0.4.2 (yazi-x86_64-unknown-linux-gnu.zip)'

unset header cmd

#########################
####### Functions #######
#########################

function v() {
  if [ -f "$1" ]; then
    nvim "$1"
  else
    pushd "$1" >/dev/null
    nvim .
  fi
}

function d() {
  cd "$DESKTOP"
  [ -n "$1" ] && cd "$1"
}

function sp() {
  if [ -z "$1" ]; then
    popd >/dev/null
  elif [ ! "$PWD" -ef "$1" ]; then
    pushd "$1" >/dev/null
  fi
}

function tmux-main() {
  if [ -n "$(command -v tmux)" ]; then
    if [ -z "$TMUX" ]; then
      if ! tmux a -t main 2>/dev/null; then
        tmux new -s main \; new-window \; select-window -t 0 >/dev/null
      fi
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

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  PS1='\n'$blue'\h'$reset':'$green'\w'$blue'${PS1_GIT}'$reset'\n> '
else
  PS1='\n'$green'\w'$blue'${PS1_GIT}'$reset'\n> '
fi

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\C-s": clear-screen'

#################################
####### Start a ssh-agent #######
#################################
if ! ps "$SSH_AGENT_PID" >/dev/null 2>&1; then
  # Try to load a currently running ssh-agent
  SSH_AGENT_ENV="$HOME/.ssh/agent-environment"
  . "$SSH_AGENT_ENV" >/dev/null 2>&1

  if ! ps "$SSH_AGENT_PID" >/dev/null 2>&1; then
    # Start a new ssh-agent
    ssh-agent >"$SSH_AGENT_ENV"
    chmod 600 "$SSH_AGENT_ENV"
    . "$SSH_AGENT_ENV" >/dev/null 2>&1
  fi
fi

#################################
####### Load Autocomplete #######
#################################

if [ -n "$(command -v complete)" ]; then
  function _lazy_autocomplete() {
    . ~/.otcova-setup/autocomplete/"$1".bash
    "_$1" "$@"
  }

  for command in fd rg bat yazi d; do
    complete -F _lazy_autocomplete -o bashdefault -o default $command
  done
fi

#####################
####### Fixes #######
#####################

# Fix Ctrl-S Freeze
stty -ixon

# WSL Fixes
if [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  # Fix Wayland
  ln -s /mnt/wslg/runtime-dir/wayland-0 "/run/user/$UID" 2>/dev/null
  ln -s /mnt/wslg/runtime-dir/wayland-0.lock "/run/user/$UID" 2>/dev/null

  DESKTOP="/mnt/c/Users/$(cmd.exe /c "<nul set /p=%UserName%" 2>/dev/null)/Desktop"
else
  DESKTOP="$(xdg-user-dir DESKTOP 2>/dev/null)" || DESKTOP="$HOME/Desktop"
fi

######################################
####### Open tmux main session #######
######################################

if [ "$TERM" = "xterm-kitty" ]; then
  tmux-main
fi
