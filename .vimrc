
"  If you don't understand a setting in here, just type ':h setting'.
 
" This must be first, because it changes other options as a side effect.
set nocompatible

filetype off                  " required
" Change mapleader
let mapleader=","

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" filesystem tree
Plugin 'scrooloose/nerdtree'
autocmd StdinReadPre * let s:std_in=1
" uncomment below to start NERDTree on vim startup
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
map <C-n> :NERDTreeToggle<CR>
map <Leader>n :NERDTree %:p:h<CR>

Plugin 'Valloric/YouCompleteMe'

Plugin 'jiangmiao/auto-pairs'

" quick google search
Plugin 'szw/vim-g'

Plugin 'vim-scripts/DrawIt'

Plugin 'tpope/vim-eunuch'

Plugin 'vim-scripts/DeleteTrailingWhitespace'

" all lanugage support
Plugin 'sheerun/vim-polyglot'

" change surroundins - cs/ds/ysiw/yss
Plugin 'tpope/vim-surround'

" do syntax check
Plugin 'scrooloose/syntastic'

" fuzzy file find
Plugin 'kien/ctrlp.vim'

" vim cscope
"Plugin 'vim-scripts/cscope.vim'

" vim indent object for Python
Plugin 'michaeljsmith/vim-indent-object'

" vim-go
Plugin 'fatih/vim-go'
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
" use quickfix list instead of location list
let g:go_list_type = "quickfix"

" Supress go version warning
let g:go_version_warning = 0

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


" SET COLOR
" number of color
set t_Co=16
" set background color (ANSI)
set t_AB=[%?%p1%{8}%<%t%p1%{40}%+%e%p1%{92}%+%;%dm
" set foreground color (ANSI)
set t_AF=[%?%p1%{8}%<%t%p1%{30}%+%e%p1%{82}%+%;%dm
" set background color
set t_Sb=[4%p1%dm
" set foreground color
set t_Sf=[3%p1%dm

" colurscheme, ~/.vim/colors/desert.vim
color desert

" Use the OS clipboard by default (on versions compiled with `+clipboard`)
" Only when TMUX is not used, see below:
" https://stackoverflow.com/questions/11404800/fix-vim-tmux-yank-paste-on-unnamed-register
if $TMUX == ''
    set clipboard+=unnamed
endif

" Enhance command-line completion
set wildmenu

" Allow backspace in insert mode
set backspace=indent,eol,start

" Optimize for fast terminal connections.
" This helps when using copy/paste with the mouse in an xterm and other terminals.
set ttyfast

" Use UTF-8 without BOM
set encoding=utf-8 nobomb

" Don't add empty newlines at the end of files
set binary
set noeol

" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
    set undodir=~/.vim/undo
endif

" Disable line numbers
set nonumber

" Enable syntax highlighting
syntax on

" Highlight current line
"set cursorline

" Make tab as wide as 4 spaces
set tabstop=4

" expand TAB into spaces
set expandtab

" 100 characters per line
set textwidth=100

" c style indent
set cindent

" 4 spaces indent
set shiftwidth=4

" Don't display trailing whitespace
set nolist
set listchars=tab:>-,trail:.,extends:>,precedes:<

" Highlight searches
set hlsearch

" Ignore case of searches, overwrite 'ignorecase' if search pattern contain upper case characters
set ignorecase
set smartcase

" Highlight dynamically as pattern is typed
set incsearch

" no wrap
set nowrap

" Always show status line
set laststatus=2

" Disable error bells
set noerrorbells

" Don't reset cursor to start of line when moving around (CTRL-D, CTRL-U, CTRL-F, CTRL-B ...).
set nostartofline

" Show the cursor position in status line
set ruler

" Don't show intro message when starting vim
set shortmess=atI

" Toggle paste mode
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

" Show the current mode
set showmode

" Show the filename in the window titlebar
set title

" Show the (partial) command as it's being typed
set showcmd

" Start scrolling 2 lines before the horizontal window border
set scrolloff=2

" When splitting a window, put the new window below/right of current one
set splitbelow
set splitright

" set at the end of .vimrc file
set secure

" Automatic commands
if has("autocmd")
    " Enable file type detection and do language-dependent indenting.
    filetype on
    " Treat .json files as .js
    autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
    " Treat .md files as Markdown
    autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

" Open QuickFix window automatically after performing grep
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
augroup END

" Prevent the 'Press ENTER or type command to continue' after performing grep.
command! -nargs=+ Grep execute 'silent grep!' <q-args> | cw | redraw!

