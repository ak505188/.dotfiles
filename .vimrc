" Vundle
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" AutoTabbing plugin
Plugin 'tpope/vim-sleuth'
" Ctrl-p Fuzzy file searching
Plugin 'ctrlpvim/ctrlp.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Brief help on Vundle
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Set ignored files for Ctrl-P
set wildignore+=*.class,*.swp,node_modules

" Newline without entering insert mode
" nmap <S-Enter> O<Esc> doesn't work in CLI
nmap <CR> o<Esc>

" Tab Settings
" Set tab width
" set tabstop=2
" Set indent width
" set shiftwidth=2
" Expand tabs to spaces
" set expandtab

" Force *.md to markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Tab settings for markdown
" Width = 2 & Use spaces
autocmd FileType markdown setlocal shiftwidth=2 expandtab

" Turn on Line Numbers
set number

" Turn on Syntax Highlighting
syntax on

" Color Scheme
colorscheme desert

