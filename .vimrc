let mapleader = " "

" Relative line numbers
set nu rnu

" Disable beeping
set belloff=all

" Encoding
set encoding=utf-8

" Whitespace
set wrap
set textwidth=79
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround

" Search highlight
set hlsearch incsearch
nohlsearch
nnoremap <silent> <esc> :nohls<cr>
autocmd InsertEnter * :nohls | redraw

" Use system clipboard
set clipboard=unnamedplus

" Formatting
nnoremap <tab> gg=G<c-o><c-o>zz

" Goto references (Search word)
nnoremap gr /<c-r><c-w><cr>

" Color scheme (terminal)
set t_Co=256
set background=dark
" wget -qO- 'https://raw.githubusercontent.com/morhetz/gruvbox/refs/heads/master/colors/gruvbox.vim' > ~/.vim/colors