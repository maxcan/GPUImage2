set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
" Vundle stuff
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'tpope/vim-markdown'
Bundle 'nono/vim-handlebars'
Bundle 'tpope/vim-fugitive'
" Bundle 'wincent/Command-T'
Bundle 'scrooloose/syntastic'
Bundle 'kshenoy/vim-signature'
Bundle 'airblade/vim-gitgutter'
Bundle 'kien/ctrlp.vim'
Bundle 'Valloric/YouCompleteMe'
Bundle 'jnurmine/Zenburn'
Bundle 'mattn/zencoding-vim'
Bundle 'Twinside/vim-haskellConceal'
Bundle 'pbrisbin/html-template-syntax'

" Bundle 'eagletmt/ghcmod-vim'
" Bundle 'pbrisbin/html-template-syntax'
" Bundle 'Shougo/neocomplcache'
" Bundle 'Shougo/neocomplcache-snippets-complete'
" Bundle 'honza/snipmate-snippets'
" Bundle 'tomtom/tlib_vim'
" Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'kchmck/vim-coffee-script'
Bundle 'altercation/vim-colors-solarized'
Bundle 'wgibbs/vim-irblack'
Bundle 'Lokaltog/vim-powerline'
Bundle 'Shougo/vimproc'
Bundle 'groenewege/vim-less'
Bundle 'digitaltoad/vim-jade'
Bundle 'epeli/slimux'
" Bundle 'jpalardy/vim-slime'
Bundle 'terryma/vim-multiple-cursors'
Bundle 'leafgarland/typescript-vim'
" Bundle 'skammer/vim-css-color'
Bundle 'dhruvasagar/vim-table-mode'

" let g:slime_target = "tmux"

" For control-p

set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
let g:ctrlp_working_path_mode = 'r'
let g:ctrlp_switch_buffer = 'v'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.((git|hg|svn|node_modules|cabal-dev|hsenv)|node_modules)$',
  \ 'file': '\v\.(exe|so|dll|o|hi)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

set mouse=a

nnoremap ' `
nnoremap ` '
" let mapleader = " "
let mapleader = '\'
inoremap jj <Esc>
cnoremap jj <C-c>
" Syntastic stuff
let g:syntastic_auto_loc_list=1
let g:syntastic_auto_jump=0
set nobackup
set noswapfile

" typescript stuff
au FileType json setlocal equalprg=python\ -m\ json.tool
au Bufenter *.ts setlocal smartindent
au Bufenter *.ts setlocal cinkeys=0{,0},0),0#,!^F,o,O,e
" let g:SlimuxUseNodeReplForCoffee = 1

com W w
com Wa wa
com WA wa
vnoremap <Leader>ss :SlimuxREPLSendSelection<CR>
noremap <Leader>sl :SlimuxREPLSendLine<CR>
noremap <Leader>sc :SlimuxREPLConfigure<CR>

imap <Leader>v :set paste<cr>o
imap <Leader>V :set nopaste<cr>
map <Leader>v :set paste<cr>o
map <Leader>V :set nopaste<cr>
set statusline=%<%f\ B%n\ %y%h%m%r%=%b\ 0x%B\ \ %l,%c%V\ %P
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set hi=1000
set relativenumber
map <Home> :w\|:bp<CR>
map <End> :w\|:bn<CR>
map <Leader>vr :vertical resize  
map <Leader><Left> <Left>
map <Leader><Right> <Right>
map <Leader><Down> <Down>
map <Leader><Up> <Up>
map <D-Left> <Left>
map <D-Right> <Right>
map <D-Down> <Down>
map <D-Up> <Up>
"----  Haskell stuf PROJECT 
command! Hasktags !find Com -name "*.hs" | xargs hasktags -c
map <Leader>8 o--------  --------F i
abbr impt import          
abbr imqu import qualified
abbr imdt import qualified Data.Text                   as T
abbr imbs import qualified Data.ByteString             as B
abbr imbl import qualified Data.ByteString.Lazy        as BL
abbr imbs import qualified Data.ByteString.Char8       as C8
abbr imbl import qualified Data.ByteString.Char8.Lazy  as C8L
abbr imcc import qualified Data.ISO3166_CountryCodes   as CC
abbr imdl import qualified Data.List                   as DL
abbr imds import qualified Data.Set                    as DS
abbr imdy import qualified Data.Maybe                  as DY
abbr imdm import qualified Data.Map                    as DM
abbr imde import qualified Data.Either                 as DE
abbr rrt redirect RedirectTemporary
imap <Leader>oc -- _OLDCODE 0>>>>j0i
map <Leader>oc 00I-- _OLDCODE 0>>>>j
abbr drv deriving (Show, Eq, Ord, Data, Typeable, Read)
"swap tuples:
"map <Leader>st F(wdwf)i, pF(ldf,
"----  END EKC PROJECT 
set guioptions=g
"let &cpo=s:cpo_save
color ir_black
set autoindent
set ignorecase
set hlsearch
set incsearch
set autowrite
set shiftwidth=2
set softtabstop=2


au BufRead *.hs setlocal softtabstop=4
au Bufenter *.hs setlocal shiftwidth=4

set expandtab

set backspace=indent,eol,start
"Window navigation
" On linux, we need the <M-.. on OSX, its <D-..  just keep both. its easier
imap <M-Left> <Left>
imap <M-Right> <Right>
imap <M-Down> <Down>
imap <M-Up> <Up>
map <M-Left> <Left>
map <M-Right> <Right>
map <M-Down> <Down>
map <M-Up> <Up>
imap <D-Up>    <Up>
imap <D-Down>  <Down>
imap <D-Right> <Right>
imap <D-Left>  <Left>
map <D-Up> <Up>
map <D-Down> <Down>
map <D-Right> <Right>
map <D-Left> <Left>

map <Leader>w :set nowrap<CR>
map <Leader>W :set wrap<CR>

"todo list
map <Leader>vtd :vimgrep TODO **/*.%:e<CR>
map <Leader>fi :set foldmethod=indent<CR>
map <Leader>v_ :vimgrep " _[A-Z]" **/*.%:e<CR>
map <Leader>vg :vimgrep // **/*.%:e<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
map <Leader>lg :lvimgrep //" **/*.%:e<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
imap <Leader>cl  console.log('');  // _DEBUG<Esc>F'i
imap <Leader>p <Esc>:CtrlP<cr>
map <Leader>p :CtrlP<cr>
imap <Leader>b <Esc>:CtrlPBuffer<cr>
map <Leader>b :CtrlPBuffer<cr>
" imap <Leader>B <Esc>:CommandT<cr>
" map <Leader>B :CommandT<cr>
"let $BASH_ENV="/Users/mxcantor/.profile"
"let $PATH="/opt/local/bin:/opt/local/sbin:/Users/mxcantor/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin"
au BufRead *.julius set filetype=javascript
au Bufenter *.julius set filetype=javascript

  " configure browser for haskell_doc.vim
  let g:haddock_browser = "/Applications/Safari.app/Contents/MacOS/Safari"
  
"Better mapping for sparkit
au BufEnter *.html inoremap \s <Esc><C-e>

filetype plugin indent on
syntax on

