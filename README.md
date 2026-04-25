
# The Linux Otcova Setup

A lightweight terminal setup that does not require sudo.

```bash
git clone https://github.com/otcova/setup ~/.otcova-setup
. ~/.otcova-setup/config/bashrc
i-otcova

# Append init to bashrc
echo ". ~/.otcova-setup/config/bashrc" >> ~/bash.rc
```


## Quick Directory Change
```bash
dc [path] # cd ~/Documents[/path]
dk [path] # cd ~/Desktop[/path]
dw [path] # cd ~/Downloads[/path]
.. [path] # cd ..[/path]
```

## Quick Git

```bash
gc <msg>  # git commit --message <msg>
gac <msg> # git add -A && git commit --message <msg>
gap <msg> # git add -A && git commit --message <msg> && git push

gs        # git status (and fetch if upstream)
gl        # git log (with a compact format)
gd        # git diff HEAD
```

## Quick Edit

```bash
v        # nvim (fallback to vim)
rc       # v ~/.bashrc

vimc     # v ~/.vimrc
nvimc    # cd ~/.config/nvim && v ~/.config/nvim/init.lua
tmuxc    # v ~/.tmux.conf

p <path> # Open Project ~/Documents/<path> into tmux + v
```

## Quick App Setup


```bash
i- <tab>  # See all options

i-bat     # cat with syntax highlighting
i-delta   # Good source diff
i-exa     # Better ls with icons
i-git     # Setup git user and ssh key
i-java    # Install sdkman
i-kanata  # Keyboard remapper
i-kitty   # Terminal emulator
i-node    # Intall node-js and npm with nvm
i-nvim    # Install latest nvim release
i-otcova  # Link font and configs to USER
i-rg      # Better grep
i-rust    # Install rustup
i-sshd    # ssh server instruction
i-tmux    # Install tmux appimage
i-vim     # Install vim colorscheme
```

## Bash utils


```bash
alias <a>=<b>   # Command completion of <a> will correspond to <b>
loop <cmd>      # Run <cmd> repeatedly
o <path>        # Open with default application
s               # source ~/.bashrc
sudoedit <path> # Use vim for write protected files
```

```bash
hs   # Bash History Search
fs   # File Search
pss  # Process Search
```
