" Vundle
" To install Vundle run
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
" To install
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
Plugin 'VundleVim/Vundle.vim'
" AutoTabbing plugin
Plugin 'tpope/vim-sleuth'
" Ctrl-p Fuzzy file searching
" Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'junegunn/fzf'
" Grep but better
Plugin 'mileszs/ack.vim'
" Easy Tables enable with TableModeEnable
Plugin 'dhruvasagar/vim-table-mode'
" Easy manipulation of surrounding
Plugin 'tpope/vim-surround'
" Asynchronous syntax checking\
Plugin 'w0rp/ale'
" Allows repeating of macros
Plugin 'tpope/vim-repeat'
" Line up text easily
Plugin 'godlygeek/tabular'
" Typescript
Plugin 'leafgarland/typescript-vim'
" Color schemes
Plugin 'flazz/vim-colorschemes'
" JSX Syntax Highlighting
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'

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
set wildignore+=*.class,*.swp,node_modules,*.pyc

" Newline without entering insert mode
" nmap <S-Enter> O<Esc> doesn't work in CLI
nmap <CR> i<CR><Esc>

" Force *.md to markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
" Force *.tex to latex
autocmd BufNewFile,BufReadPost *.tex set filetype=latex
" let g:tex_flavor='latex'

" Tab settings for markdown
" Width = 2 & Use spaces
autocmd FileType markdown setlocal shiftwidth=2 expandtab
autocmd FileType markdown setlocal tw=80 fo+=t

" Turn on Line Numbers
set number

" Turn on Syntax Highlighting
syntax on

" Color Scheme
" colorscheme desert
colorscheme DevC++

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
" Tabular shortcut
nnoremap <Leader>t :Tabularize /=<CR>
" CTRL-p binding for fzf.vim
nnoremap <C-p> :FZF<CR>
" Bindings for ack.vim
nnoremap <Leader>a :Ack!<Space>
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

autocmd FileType typescript :set makeprg=tsc

" Remove whitespace on file save if not markdown
fun! StripTrailingWhiteSpace()
  " don't strip on these filetypes
  if &ft =~ 'markdown'
    return
  endif
  %s/\s\+$//e
endfun
autocmd bufwritepre * :call StripTrailingWhiteSpace()

" Persistent undo
" Directory must be made manually
set undofile
set undodir=$HOME/.vim/undo

set undolevels=1000
set undoreload=10000

" changed buffers are automatically saved
set autowriteall

" set :bw to Leader C
nnoremap <Leader>c :bw<CR>
