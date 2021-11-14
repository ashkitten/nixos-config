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

set completeopt=menu,menuone,noselect

lua << EOF
  -- Setup nvim-cmp.
  local cmp = require('cmp')

  cmp.setup({
    snippet = {
      expand = function(args)
        -- For `vsnip` user.
        vim.fn["vsnip#anonymous"](args.body)

        -- For `luasnip` user.
        -- require('luasnip').lsp_expand(args.body)

        -- For `ultisnips` user.
        -- vim.fn["UltiSnips#Anon"](args.body)
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      { name = 'nvim_lsp' },

      -- For vsnip user.
      { name = 'vsnip' },

      -- For luasnip user.
      -- { name = 'luasnip' },

      -- For ultisnips user.
      -- { name = 'ultisnips' },

      { name = 'buffer' },
    }
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  require('lspconfig').omnisharp.setup {
    cmd = { "omnisharp", "--languageserver" , "--hostPID", tostring(pid) };
    capabilities = capabilities,
  }
  require('lspconfig').rust_analyzer.setup {
    capabilities = capabilities,
  }

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  end
EOF

" Colorscheme
"packadd! onedark-vim
colorscheme onedark
highlight Normal guibg=None ctermbg=None
if $TERM == 'linux'
    colorscheme vividchalk
    set laststatus=0
endif
