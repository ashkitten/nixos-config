" Line numbers
set number

" Default encoding
set encoding=utf-8

" Enable mouse
set mouse=a

" Tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" Automatically reread files that haven't been edited yet if they are changed
set autoread

" Line breaks on words
set wrap linebreak nolist

" Display invisible tab characters as >---
set list
set listchars=tab:>-

" Start scrolling when we reach 1/6 of the way from the end of the terminal
autocmd BufEnter,WinEnter,VimResized *,*.* let &scrolloff = winheight(win_getid()) / 8

" Disable bell
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

" Persistent undo
set undofile
set undodir=$HOME/.local/share/nvim/undo
set undolevels=1000
set undoreload=10000

" Live substitutions
set inccommand=split

" Split below and right
set splitright
set splitbelow

" Don't insert the comment leader when hitting o or O
autocmd FileType * setlocal formatoptions-=o

" Terminal
tnoremap <C-w> <C-\><C-n><C-w>
augroup terminal_insert
    autocmd!
    autocmd BufEnter term://* startinsert
    autocmd BufLeave term://* stopinsert
augroup END

" Map Q to replay instead of ex mode
nmap Q @

" Two escapes in a row will clear the search highlight
nmap <Esc><Esc> :noh<CR>

" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
\     'rust': ['rls'],
\     'cpp': ['clangd'],
\ }

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" Supertab complete from top to bottom
let g:SuperTabDefaultCompletionType = "<c-n>"

" NERDTree configs
map <silent> <Tab> :NERDTreeToggle<CR>
let g:NERDTreeMinimalUI = 1
let g:NERDTreeQuitOnOpen = 1

" Call neomake when writing a buffer
autocmd! BufWritePost * Neomake

" True color support
set termguicolors

" Lightline config
let g:lightline = {
\ 'colorscheme': 'one',
\     'active': {
\         'left': [
\             [ 'mode', 'paste' ],
\             [ 'gitbranch', 'readonly', 'filename', 'modified' ],
\         ]
\     },
\     'component_function': {
\         'gitbranch': 'fugitive#head',
\     },
\ }
" Don't show mode, it's already in the status line
autocmd BufEnter * set noshowmode

" firenvim config
let g:firenvim_config = {
\     'localSettings': {
\         '.*': {
\             'takeover': 'never',
\         },
\     }
\ }

" Use nasm syntax for assembly by default
let asmsyntax="nasm"

" Colorscheme
packadd! onedark-vim
colorscheme onedark
highlight Normal guibg=None ctermbg=None
if $TERM == 'linux'
    colorscheme vividchalk
    set laststatus=0
endif
