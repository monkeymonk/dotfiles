" Enable true color support
if !has('gui_running') && &term =~ '\%(screen\|tmux\)'
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors
set background=dark

" Cursor styles for different modes
let &t_SI = "\<esc>[5 q"  " blinking I-beam in insert mode
let &t_SR = "\<esc>[3 q"  " blinking underline in replace mode
let &t_EI = "\<esc>[ q"   " default cursor otherwise

" Line numbers
set relativenumber
set number

" Enable filetype plugins and indentation
filetype plugin on
filetype indent on

" Auto-reload files changed outside of Vim
set autoread
au FocusGained,BufEnter * silent! checktime

" :W for sudo save (fixes permission-denied errors)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Display cursor position
set ruler

" Command bar height
set cmdheight=1

" Allow hidden buffers
set hidden

" Backspace behavior
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Search behavior
set ignorecase       " Ignore case
set smartcase        " Smart case
set hlsearch         " Highlight search
set incsearch        " Incremental search
set lazyredraw       " Faster macros
set magic            " Enhanced regex

" Matching brackets
set showmatch
set mat=2            " Blink duration

" Silence error bells
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Enhanced completion menu
set wildmenu

" Improved margin for folds
set foldcolumn=1

" Enable syntax highlighting
syntax on

" Auto select best regex engine
set regexpengine=0

" Colorscheme manually configured for Catppuccin Mocha
" Mocha Palette:
" https://github.com/catppuccin/catppuccin
" Rosewater: #f5e0dc
" Flamingo:  #f2cdcd
" Pink:      #f5c2e7
" Mauve:     #cba6f7
" Red:       #f38ba8
" Maroon:    #eba0ac
" Peach:     #fab387
" Yellow:    #f9e2af
" Green:     #a6e3a1
" Teal:      #94e2d5
" Sky:       #89dceb
" Sapphire:  #74c7ec
" Blue:      #89b4fa
" Lavender:  #b4befe
" Text:      #cdd6f4
" Subtext1:  #bac2de
" Subtext0:  #a6adc8
" Overlay2:  #9399b2
" Overlay1:  #7f849c
" Overlay0:  #6c7086
" Surface2:  #585b70
" Surface1:  #45475a
" Surface0:  #313244
" Base:      #1e1e2e
" Mantle:    #181825
" Crust:     #11111b

" Set background and default text color
highlight Normal       guifg=#cdd6f4 guibg=#1e1e2e
highlight NonText      guifg=#585b70 guibg=NONE
highlight LineNr       guifg=#585b70 guibg=NONE
highlight CursorLineNr guifg=#f9e2af guibg=NONE
highlight Comment      guifg=#7f849c guibg=NONE cterm=italic gui=italic
highlight Constant     guifg=#fab387 guibg=NONE
highlight String       guifg=#a6e3a1 guibg=NONE
highlight Character    guifg=#f38ba8 guibg=NONE
highlight Number       guifg=#f9e2af guibg=NONE
highlight Boolean      guifg=#f38ba8 guibg=NONE
highlight Float        guifg=#f9e2af guibg=NONE
highlight Identifier   guifg=#89b4fa guibg=NONE
highlight Function     guifg=#b4befe guibg=NONE
highlight Statement    guifg=#cba6f7 guibg=NONE
highlight Conditional  guifg=#cba6f7 guibg=NONE
highlight Repeat       guifg=#cba6f7 guibg=NONE
highlight Label        guifg=#fab387 guibg=NONE
highlight Operator     guifg=#89b4fa guibg=NONE
highlight Keyword      guifg=#cba6f7 guibg=NONE
highlight Exception    guifg=#f38ba8 guibg=NONE
highlight PreProc      guifg=#f9e2af guibg=NONE
highlight Include      guifg=#cba6f7 guibg=NONE
highlight Define       guifg=#f9e2af guibg=NONE
highlight Macro        guifg=#fab387 guibg=NONE
highlight PreCondit    guifg=#f9e2af guibg=NONE
highlight Type         guifg=#89dceb guibg=NONE
highlight StorageClass guifg=#89dceb guibg=NONE
highlight Structure    guifg=#89dceb guibg=NONE
highlight Typedef      guifg=#89dceb guibg=NONE
highlight Special      guifg=#89b4fa guibg=NONE
highlight SpecialChar  guifg=#f38ba8 guibg=NONE
highlight Tag          guifg=#f38ba8 guibg=NONE
highlight Delimiter    guifg=#cdd6f4 guibg=NONE
highlight SpecialComment guifg=#7f849c guibg=NONE cterm=italic gui=italic
highlight Debug        guifg=#f38ba8 guibg=NONE
highlight Underlined   guifg=#89b4fa guibg=NONE cterm=underline gui=underline
highlight Ignore       guifg=#585b70 guibg=NONE
highlight Error        guifg=#f38ba8 guibg=#11111b
highlight Todo         guifg=#f9e2af guibg=NONE cterm=bold gui=bold

" Visual selection highlight
highlight Visual       guibg=#45475a guifg=NONE

" Search highlight
highlight Search       guibg=#fab387 guifg=#11111b
highlight IncSearch    guibg=#f38ba8 guifg=#11111b

" Easy navigation between buffers
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" Return to last edit position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Always show status line
set laststatus=2

" Custom status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

" Display 'PASTE MODE' in status line if enabled
function! HasPaste()
 if &paste
        return 'PASTE MODE  '
 endif
 return ''
endfunction
