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
" Easy Tables enable with TableModeEnable
Plugin 'dhruvasagar/vim-table-mode'
" Easy manipulation of surrounding
Plugin 'tpope/vim-surround'
" Java autocompletion
" Plugin 'artur-shaik/vim-javacomplete2'

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

" config for javacomplete2
" autocmd Filetype java setlocal omnifunc=javacomplete#Complete

" Set ignored files for Ctrl-P
set wildignore+=*.class,*.swp,node_modules

" Newline without entering insert mode
" nmap <S-Enter> O<Esc> doesn't work in CLI
nmap <CR> i<CR><Esc>

" Force *.md to markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Tab settings for markdown
" Width = 2 & Use spaces
autocmd FileType markdown setlocal shiftwidth=2 expandtab
autocmd FileType markdown setlocal tw=80 fo+=t

" Turn on Line Numbers
set number

" Turn on Syntax Highlighting
syntax on

" Color Scheme
colorscheme desert

" Leader key shortcuts
" Set up space as leader
let mapleader = "\<Space>"
" Tab for next buffer
nnoremap <Tab> :bn<CR>
" Shift-Tab for next buffer
nnoremap <S-Tab> :bp<CR>
" Copy to system clipboard
noremap <Leader>y "+y
" Paste from system clipboard
noremap <Leader>p "+p
noremap <Leader>P "+P



" Remove whitespace on file save
:silent autocmd BufWritePre * :%s/\s\+$//ge

" Change current directory to directory of buffer
set autochdir
