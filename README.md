# My Linux Setup

Install it with:
```bash
git clone https://github.com/otcova/setup ~/.otcova-setup
. ~/.otcova-setup/config/rc.bash
otcova-install
```

# Features and Capabilities
```bash
> otcova
```
```python
Configure Program
c-all
c-tmux
c-nvim
c-git
c-kitty

Configure LSP
c-rust

Search
hs  <regex> # History search
fs  <regex> # File search
pss <regex> # Process search

Git Aliases
ga <msg>   # add all, commit
gc <msg>   # commit
gp         # pull, push
gs         # status
gb         # branch
gd         # diff
glog       # log
gpull      # pull
gpush      # push

Vim
v          # cd, nvim
vc         # cd ~/.config/nvim, nvim

Fast Edit
rc         # cd otcova-setup, nvim ~/.otcova-setup/config/rc.bash
brc        # nvim ~/.bashrc

Directories
h          # ~
d          # ~/Desktop/
sp         # Stack push/pop directory

Tmux
tmux-main  # Main tmux session

Otcova Setup
otcova           # Reload rc and show help
otcova-update    # Update and reload
otcova-install   # Sets up the rc and starts c-all
otcova-uninstall # Removes ~/.otcova-setup

Binaries
nvim       # Source: https://github.com/neovim/neovim/releases/tag/v0.10.2 (nvim-linux64.tar.gz)
rg         # Source: https://github.com/BurntSushi/ripgrep/releases/tag/14.1.1 (ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz)
fd         # Source: https://github.com/sharkdp/fd/releases/tag/v10.2.0 (fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz)
bat        # Source: https://github.com/sharkdp/bat/releases/tag/v0.24.0 (bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz)
fzf        # Source: https://github.com/junegunn/fzf/releases/tag/v0.57.0 (fzf-0.57.0-linux_amd64.tar.gz)
delta      # Source: https://github.com/dandavison/delta/releases/tag/0.18.2 (delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz)
lg         # Source: https://github.com/jesseduffield/lazygit/releases/tag/v0.44.1 (lazygit_0.44.1_Linux_x86_64.tar.gz)
yazi       # Source: https://github.com/sxyazi/yazi/releases/tag/v0.4.2 (yazi-x86_64-unknown-linux-gnu.zip)
```
