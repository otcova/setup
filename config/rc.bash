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

  alias ls='ls --color=auto'
fi

#####################
####### Alias #######
#####################

OTCOVA_HELP=''
function header() {
  OTCOVA_HELP+=$'\n'$blue"$1"$reset$'\n'
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
cmd 'rc         ' '# nvim ~/.otcova-setup/rc.bash' 'nvim $HOME/.otcova-setup/rc.bash'
cmd 'brc        ' '# nvim ~/.bashrc' 'nvim $HOME/.bashrc'

header 'Directories'
cmd 'h          ' '# ~' 'cd ~'
cmd 'd          ' '# ~/Desktop/' 'cd ~/Desktop/'

header 'Tmux'
cmd 'tmux-main  ' '# Main tmux session' 'tmux a -t main 2>/dev/null || tmux new -s main \; new-window \; select-window -t 0 >/dev/null'

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
cmd 'otcova           ' '# Reload rc and show help' '. ${HOME}/.otcova-setup/config/rc.bash ; echo "${OTCOVA_HELP}" | less -r'
cmd-info 'otcova-update    ' '# Update and reload'
cmd-info 'otcova-install   ' '# Sets up the rc and starts c-all'
cmd-info 'otcova-uninstall ' '# Removes ~/.otcova-setup'

unset header cmd-info cmd

#########################
####### Functions #######
#########################

function prompt-path() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$#" -ge 3 ]; then
    echo "Usage:"
    echo "  prompt-path [<prompt>] [<default>]"
    echo ""
    echo 'The resulting value is stored in $REPLY'
    echo ""
    echo "Example:"
    echo "  > prompt-str 'Enter a path' '~/.config'"
    echo "  Enter a path (~/.config):"
    return
  fi

  prompt=""
  if [ ! -z "$1" ]; then
    if [ -z "$2" ]; then
      prompt="${1}: "
    else
      prompt="${1} (${2}): "
    fi
  fi

  read -rep "$prompt"
  REPLY="${REPLY:-"$2"}"
  REPLY="${REPLY/#\~/$HOME}" # Expand ~ to home
}

function prompt-str() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$#" -ge 3 ]; then
    echo "Usage:"
    echo "  prompt-str [<prompt>] [<default>]"
    echo ""
    echo 'The resulting value is stored in $REPLY'
    echo ""
    echo "Example:"
    echo "  > prompt-str 'Enter name' 'Richard'"
    echo "  Enter name (Richard):"
    return
  fi

  prompt=""
  if [ ! -z "$1" ]; then
    if [ -z "$2" ]; then
      prompt="${1}: "
    else
      prompt="${1} (${2}): "
    fi
  fi

  read -rp "$prompt"
  REPLY="${REPLY:-"$2"}"
}

function prompt-confirm() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  prompt-confirm <prompt>"
    echo ""
    echo 'The resulting value is stored in $REPLY'
    echo ""
    echo "Example:"
    echo "  > prompt-confirm 'Are you sure'"
    echo "  Are you sure (yes)?"
    return
  fi

  read -rn 1 -p "${1} (yes)? "
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    echo 'es'
  elif [ ! -z "$REPLY" ]; then
    echo ''
    return 1
  fi
}

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
    if prompt-confirm "Override file ${blue}${1}${reset}"; then
      rm -rf "$1"
    else
      return 1
    fi
  fi
}

function link() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$#" -ge 3 ]; then
    echo "Usage:"
    echo "  link [<src>] [<dst>]"
    echo ""
    echo "<src> default value is $PWD"
    echo "<dst> default value is $HOME/Desktop/<src-basename>"
    return
  fi

  src="${1:-$PWD}"
  dst="${2:-$HOME/Desktop/$(basename -- "$src")}"

  if [ "$src" -ef "$dst" ]; then
    return # File exists and is correct, do nothing
  fi

  if ask-rm "$dst"; then
    mkdir -p "$(dirname -- "$dst")"
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

function c-all() {
  prompt-confirm "${blue}Config Tmux${reset}" && c-tmux
  prompt-confirm "${blue}Config Nvim${reset}" && c-nvim
  prompt-confirm "${blue}Config Git${reset}" && c-git
  prompt-confirm "${blue}Config Kitty${reset}" && c-kitty
}

function c-tmux() {
  link ~/.otcova-setup/config/tmux.conf ~/.tmux.conf
  git-install 'https://github.com/tmux-plugins/tpm' ~/.tmux/plugins/tpm
}

function c-nvim() {
  git-install https://github.com/LazyVim/starter ~/.config/nvim
  link ~/.otcova-setup/config/nvim.lua ~/.config/nvim/lua/plugins/otcova.lua
}

function c-kitty() {
  link ~/.otcova-setup/config/kitty ~/.config/kitty

  wget -qO- https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  link ~/.local/kitty.app/bin/kitty ~/.bin/kitty
  link ~/.local/kitty.app/bin/kitten ~/.bin/kitten
}

function c-git() {
  # Config delta (git diff)
  git config --global core.pager delta
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global merge.conflictStyle zdiff3
  git config --global delta.navigate true
  git config --global delta.side-by-side true

  # Use nvim
  git config --global core.editor nvim

  # Set user
  prompt-str "Git user.name" "$(git config --global user.name)"
  git config --global user.name "$REPLY"
  prompt-str "Git user.email" "$(git config --global user.email)"
  git config --global user.email "$REPLY"

  # Set up ssh keys
  current_ssh="$(git config --global core.sshCommand)"
  if [ ! -z "$current_ssh" ]; then
    if ! prompt-confirm "Change configured ssh '${current_ssh}'"; then
      return
    fi
  fi

  key_path=''
  if prompt-confirm 'Generate new ssh keys'; then
    prompt-path 'Enter file in which to save the key' "$HOME/.ssh/id_ed25519"
    key_path="$REPLY"
    if ! ask-rm "$key_path"; then
      return
    fi
    mkdir -p "$(dirname -- "$key_path")"
    ssh-keygen -q -t ed25519 -C "$(git config --global user.email)" -f "$key_path"
  else
    prompt-path 'Enter key path' "$HOME/.ssh/id_rsa"
    key_path="$REPLY"
  fi

  if [ -e "$key_path" ]; then
    chmod 600 "$key_path"
    git config --global core.sshCommand "ssh -i '${key_path}'"
  else
    echo "${red}[ERROR]${reset} Ssh key '$key_path' not found"
  fi
}

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

######################
######### Path #######
######################

PATH="$HOME/.otcova-setup/bin:$HOME/.bin:$PATH"

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
# if [ -z "$TMUX" ]; then
#   tmux-main
#   exit
# fi
