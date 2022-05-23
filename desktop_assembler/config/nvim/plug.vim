""Plug
call plug#begin(stdpath('data') . '/plugged')
"color
Plug 'morhetz/gruvbox'
Plug 'arcticicestudio/nord-vim'
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
Plug 'dylanaraps/wal.vim'

"status lines
Plug 'kyazdani42/nvim-web-devicons' "dependency of barbar
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'

"completion
"Plug 'ycm-core/YouCompleteMe'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}

"misc
Plug 'ryanoasis/vim-devicons'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-fugitive'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
call plug#end()

"Misc options
let g:limelight_paragraph_span = 1
let g:colorizer_nomap = 1
let bufferline = {}
let bufferline.auto_hide = v:true
"let bufferline.icons = v:false
