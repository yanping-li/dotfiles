
"  If you don't understand a setting in here, just type ':h setting'.
 
" This must be first, because it changes other options as a side effect.
set nocompatible

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
set clipboard=unnamed

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

" Show the current mode
set showmode

" Show the filename in the window titlebar
set title

" Show the (partial) command as it's being typed
set showcmd

" Start scrolling 2 lines before the horizontal window border
set scrolloff=2

" set at the end of .vimrc file
set secure

" Automatic commands
if has("autocmd")
    " Enable file type detection and do language-dependent indenting.
    filetype plugin indent on
    " Treat .json files as .js
    autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
    " Treat .md files as Markdown
    autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

