""" Load vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

" filetype off                  " required

call plug#begin('~/vim/plug')

" AutoTabbing plugin
Plug 'tpope/vim-sleuth'

" Ctrl-p Fuzzy file searching
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Grep but better
Plug 'mileszs/ack.vim'

" Easy manipulation of surrounding
Plug 'tpope/vim-surround'

" Allows repeating of macros
Plug 'tpope/vim-repeat'

" Line up text easily
Plug 'godlygeek/tabular'

" Color schemes
Plug 'flazz/vim-colorschemes'

" JSX Syntax Highlighting
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'

" Better Whitespace Handling
Plug 'ntpeters/vim-better-whitespace'

" Emmet
Plug 'mattn/emmet-vim'

" Comment
Plug 'tpope/vim-commentary'

" Auto Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" Search before pressing enter & highlight search
set incsearch
" set hlsearch

" Newline without entering insert mode
" nmap <S-Enter> O<Esc> doesn't work in CLI
nmap <CR> i<CR><Esc>

" Force *.md to markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd BufNewFile,BufReadPost *.mdx set filetype=markdown
" Force *.tex to latex
autocmd BufNewFile,BufReadPost *.tex set filetype=latex
" let g:tex_flavor='latex'

" Tab settings for markdown
" Width = 2 & Use spaces
" autocmd FileType markdown setlocal shiftwidth=2 expandtab
" autocmd FileType markdown setlocal tw=80 fo+=t
autocmd FileType markdown setlocal textwidth=0 wrapmargin=0 wrap linebreak columns=120

" Turn on Line Numbers
set number

" Turn on Syntax Highlighting
syntax on

" Color Scheme
colorscheme blackbeauty

" Leader key shortcuts
" Set up space as leader
let mapleader = "\<Space>"

nnoremap j gj
nnoremap k gk
nnoremap Y y$

" Open terminal in vim
noremap <Leader>t :terminal<CR>

" Tab for buffer switching
nnoremap <Tab> :bn<CR>
nnoremap <S-Tab> :bp<CR>
nnoremap <Leader>c :bw<CR>

" Copy & Paste to/from system clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p
noremap <Leader>P "+P

" CTRL-p binding for fzf.vim
" https://stackoverflow.com/questions/51093087/ignore-node-modules-with-vim-fzf
" nnoremap <C-p> :FZF<CR>
" nnoremap <C-p> :GFiles --exclude-standard --others --cached<CR>
nnoremap <expr> <C-P> (len(system('git rev-parse')) ? ':Files' : ':GFiles --exclude-standard --others --cached')."\<CR>"

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

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" CTRL-Space finish completion for COC
inoremap <silent><expr> <C-@> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

" Set tabwidth to 2
set tabstop=2
