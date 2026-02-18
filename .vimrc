set nocompatible 
syntax enable
filetype plugin on
set exrc
set hidden
set noerrorbells
set scrolloff=7
set smartcase
set ignorecase
set expandtab
set smartindent
set shiftwidth=4
set tabstop=4 softtabstop=4
set number relativenumber incsearch
set backspace=indent,eol,start " For macOS
set wildmenu
set nowrap
set noswapfile
set hlsearch

let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
" let g:netrw_list_hide=netrw_gitignore#Hide()

let g:tex_flavor='latex' 
let g:vimtex_view_method = 'skim' 
let g:vimtex_view_skim_sync = 1 
let g:vimtex_view_skim_activate = 1 

" BEGIN INITIAL CONFIGURATION

" Vim gutter
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes
highlight SignColumn guibg=NONE
highlight GitGutterAdd    guifg=#00aa00 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1

" For JSON comments
autocmd FileType json syntax match Comment +\/\/.\+$+

let test#vim#term_position = "topleft 15"
let test#strategy = "vimterminal"

" END INITIAL CONFIGURATION

" BEGIN KEYBINDS

let mapleader = " " " map leader to space

noremap <leader>h :noh<CR>

" open vimrc
noremap <leader>Ci :tabnew ~/.vimrc<CR>

noremap <leader>w :w<CR>
noremap <leader>W :wa<CR>
noremap <leader>q :q<CR>
noremap <leader>Q :qa<CR>
noremap <leader>c :bp<bar>sp<bar>bn<bar>bd<CR>

" terminal
noremap <leader>T :terminal<CR>

" file explorer
noremap <leader>E :30vs .<CR>

" erorrs
noremap <leader>lt :Errors<CR>

" goto definition (using tags)
noremap gd <C-]>

" hide search highlights
noremap <silent> <leader>h :noh<CR>

" scroll half page down and recenter
noremap <C-d> <C-d>zz 

" scroll half page up and recenter
noremap <C-u> <C-u>zz 

" Jump to end of line in insert mode
inoremap <C-e> <C-o>A
" Jump to start of line in insert mode
inoremap <C-a> <C-o>I

" swap current word
noremap <leader>R :%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>

" buffer cycle
noremap <silent> <S-l> :bnext<CR>
noremap <silent> <S-h> :bprev<CR>
" navigate between split buffers
noremap <silent> <C-k> <C-w>k
noremap <silent> <C-j> <C-w>j
noremap <silent> <C-h> <C-w>h
noremap <silent> <C-l> <C-w>l
"buffer resize
noremap <C-Up> :resize -2<CR>
noremap <C-Down> :resize +2<CR>
noremap <C-Left> :vertical resize -2<CR>
noremap <C-Right> :vertical resize +2<CR>

" delete without yanking
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" yank to end of line
nnoremap Y y$

" replace currently selected text with default register without yanking it
vnoremap <leader>p "_dP

" Testing
noremap <silent> <leader>tt :TestNearest<CR>
noremap <silent> <leader>tf :TestFile<CR>
noremap <silent> <leader>ta :TestSuite<CR>
noremap <silent> <leader>tl :TestLast<CR>
noremap <silent> <leader>tv :TestVisit<CR>

" fzf
noremap <silent> <Leader>f :GFiles<CR>
noremap <silent> <Leader>sf :Files<CR>
noremap <silent> <Leader>sg :Rg<CR>
noremap <silent> <Leader>sc :Colors<CR>
noremap <silent> <Leader>sh :Helptags<CR>
noremap <silent> <Leader>ss :BLines<CR>

" git
noremap <silent> <Leader>gc :Commits<CR>
noremap <silent> <Leader>gs :G<CR>
noremap <silent> <Leader>ga :G add %<CR>
noremap <silent> <Leader>gA :G add .<CR>
noremap <silent> <Leader>gCC :G commit -c HEAD<CR>
noremap <silent> <Leader>gCN :G commit<CR> 
noremap <silent> <Leader>gP :G -c push.default=current push<cr>
noremap <silent> <Leader>gp :G -c push.default=current pull<cr>
noremap <silent> <Leader>gL :Gclog<cr>
noremap <silent> <Leader>gb :G blame<cr>
noremap <silent> <Leader>gd :Gvdiffsplit<cr>

" END KEYBINDS

call plug#begin()

" BEGIN LIST OF PLUGINS

" Plug 'jalvesaq/Nvim-R', {'branch': 'stable'}
" Plug 'lervag/vimtex'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mattn/emmet-vim'
" Plug 'pangloss/vim-javascript'
Plug 'jiangmiao/auto-pairs'
Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
Plug 'turbio/bracey.vim'
" Plug 'puremourning/vimspector'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-surround' 
" Plug 'vim-test/vim-test'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" XXX: Switch to ALE or smth
Plug 'vim-syntastic/syntastic'

" Themes:
Plug 'ghifarit53/tokyonight-vim'
Plug 'arzg/vim-colors-xcode'
Plug 'wojciechkepka/vim-github-dark'
Plug 'tribela/vim-transparent'

" END LIST OF PLUGINS

call plug#end()

" BEGIN ADDITIONAL CONFIGURATION

" This is only necessary if you use "set termguicolors".
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" enable true colors support
set termguicolors     

" tokyonight
let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1

set background=dark
colorscheme tokyonight

" brighten line numbers
highlight LineNr guifg=#FFFFFF
highlight LineNrBelow guifg=#737aa2
highlight LineNrAbove guifg=#737aa2

" transparent bg
" autocmd vimenter * hi Normal guibg=NONE ctermbg=NONE
let g:transparent_groups = ['Normal', 'Comment', 'Constant', 'Special', 'Identifier',
                            \ 'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String',
                            \ 'Function', 'Conditional', 'Repeat', 'Operator', 'Structure',
                            \ 'LineNr', 'NonText', 'SignColumn', 'CursorLineNr', 'EndOfBuffer']
" GitSigns
let g:transparent_groups += ['GitGutterAdd', 'GitGutterChange', 'GitGutterDelete']

" terminal buffer sizing
autocmd TerminalOpen * if &buftype == 'terminal' | resize 10 | endif

" airline settings
let g:airline_theme = "tokyonight"
let g:airline#extensions#tabline#enabled = 1           " enable airline tabline                                                           
let g:airline#extensions#tabline#show_close_button = 0 " remove 'X' at the end of the tabline                                            
let g:airline#extensions#tabline#tabs_label = ''       " can put text here like BUFFERS to denote buffers (I clear it so nothing is shown)
let g:airline#extensions#tabline#buffers_label = ''    " can put text here like TABS to denote tabs (I clear it so nothing is shown)      
" let g:airline#extensions#tabline#fnamemod = ':t'       " disable file paths in the tab                                                    
" let g:airline#extensions#tabline#show_tab_count = 0    " dont show tab numbers on the right                                                           
" let g:airline#extensions#tabline#show_buffers = 0      " dont show buffers in the tabline                                                 
let g:airline#extensions#tabline#tab_min_count = 2     " minimum of 2 tabs needed to display the tabline                                  
let g:airline#extensions#tabline#buffer_min_count = 2
" let g:airline#extensions#tabline#show_splits = 0       " disables the buffer name that displays on the right of the tabline               
" let g:airline#extensions#tabline#show_tab_nr = 0       " disable tab numbers                                                              
" let g:airline#extensions#tabline#show_tab_type = 0     " disables the weird ornage arrow on the tabline

" syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" END ADDITIONAL CONFIGURATION
