" --- 1. Plugin Management (Vim-Plug) ---
" install.sh will auto install vim-plug, define packages here
call plug#begin('~/.vim/plugged')

" File Explorer (NERDTree) - Ctrl+n to toggle
" Plug 'preservim/nerdtree'
" Status line (Airline)
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Git Integration (show file changes)
Plug 'airblade/vim-gitgutter'
" Auto pairs for brackets/quotes
" Plug 'jiangmiao/auto-pairs'
" Commenter (Select then Leader+c+space)
" Plug 'preservim/nerdcommenter'
" Seamless navigation between Vim and Tmux (Required)
Plug 'christoomey/vim-tmux-navigator'
" Syntax Check (Async)
Plug 'dense-analysis/ale'

call plug#end()

" --- 2. Basic Preferences ---
set nocompatible            " Disable vi compatibility
set encoding=utf-8
set number                  " Show line numbers
set relativenumber          " Show relative line numbers (easier jumping)
set cursorline              " Highlight current line
set expandtab               " Convert tabs to spaces
set tabstop=4               " Tab width
set shiftwidth=4
set autoindent
set smartindent
set mouse=a                 " Enable mouse support
set clipboard=unnamed       " Share system clipboard (Linux/Mac)
syntax on                   " Enable syntax highlighting

" --- 3. Key Mappings ---
let mapleader = ","         " Set Leader key to comma

" Ctrl+n toggle NERDTree
map <C-n> :NERDTreeToggle<CR>

" Airline Settings
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1 " Show tabs