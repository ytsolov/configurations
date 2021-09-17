" .vimrc file

" Avoid loading this file twice
"if exists("loaded_user_vimrc")
"  finish
"endif
let loaded_user_vimrc = 1

" When started as "evim", evim.vim will already have done these settings.
" if v:progname =~? "evim"
"   finish
" endif

set autoindent                  " use the indent of previous line for newly created one.
set noautowrite                 " do not automatically save when changing buffers.
set nocompatible                " use Vim settings, rather Vi settings.
set expandtab                   " use spaces instead of tabs.
set incsearch                   " do incremental searching.
set nohidden                    " when changing buffer you won't be forced to save or discard.
set nolist                      " shows symbols for tabs and endlines.
set hlsearch                    " highlight searched word.
set magic                       " enable special meaning of some characters.
set number                      " line numbering.
set ruler                       " show the cursor position all the time.
set showcmd                     " display incomplete commands in the lowwer right corner.
set showmatch                   " cursor shows matching ")" and "}".
set showmode                    " Editor mode is displayed on bottom of screen.
set nowrap                      " wrap text when it's longer than the screen.
set nocursorcolumn              " highlight current column.
set wildmenu                    " autocomplition show.
set splitbelow                  " put the new buffer below the current one.
set splitright                  " put the new buffer on the right of the current one.
set norelativenumber            " don't like it

set tabstop=4                   " tab scope of characters.
set shiftwidth=4                " <<, >> operator.
set history=100                 " keep 50 lines of command line history.
set backspace=indent,eol,start  " allow backspacing over everything in insert mode.
set fdm=syntax                  " syntax highlighting items specify folds.
set path+=**                    " when using :tabf search and in sub-directories.
set fileformat=unix             " set the file format to be always UNIX.
set sidescroll=5                " set horizontal scrolling to be done by selected comuns.
set scrolloff=3                 " lines to scroll when nearing the end of visible.
set matchpairs+=<:>

colorscheme desert
"colorscheme peachpuff
"colorscheme zellner

set grepprg=grep\ -n\ $*\ --include=*.{c,cpp,C,cxx,h,hpp,ipp,py,go,cs,js,json,txt}\ /dev/null
set tags+=./tags
set tags+=;home


" This tells Vim to keep a backup copy of a file when overwriting it.  But not
" on the VMS system, since it keeps old versions of files already.  The backup
" file will have the same name as the original file with "~" added.  See |07.4|
" if has("vms")
  set nobackup
" else
"   set backup
" endif


" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=v
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2
  syntax enable
  "syntax on
endif

if has("gui_running")
  set gfn=Monospace\ 8.5
  set guioptions-=T     " Toolbar
  set guioptions-=m     " Menu
  set guioptions-=e     " Show vim tabs
  set guioptions+=c     " Show console dialogs instead of pop up.
  set cursorline        " highlight current line
endif


let scriptnames_output = ''
redir => scriptnames_output
silent scriptnames
redir END

let mscripts = {}
let lscripts = []
for line in split(scriptnames_output, "\n")
    " Only do non-blank lines.
    if line =~ '\S'
        " Get the first number in the line.
        let nr = matchstr(line, '\d\+')
        " Get the file name, remove the script number " 123: ".
        let name = substitute(line, '.\+:\s*', '', '')
        " Add an item to the Dictionary
        let mscripts[nr] = name
        call add(lscripts, name)
    endif
endfor
unlet scriptnames_output
let plugin_vundle=0
for [key, value] in items(mscripts)
    if value =~ 'Vundle.vim'
        let plugin_vundle=1
    endif
endfor
if plugin_vundle == 0
    "This is in case of first time adding vundle
    if isdirectory($HOME . "/.vim/bundle/Vundle.vim")
        let plugin_vundle=1
    endif
endif

let s:use_vundle = plugin_vundle
if s:use_vundle == 1
    filetype off                  " required

    " set the runtime path to include Vundle and initialize
    set rtp+=$HOME/.vim/bundle/Vundle.vim
    call vundle#begin()
    " alternatively, pass a path where Vundle should install plugins
    "call vundle#begin('~/some/path/here')

    "#Plugin 'file://$HOME/.vim/bundle/YouCompleteMe'
    Plugin 'https://github.com/ycm-core/YouCompleteMe.git'

    "" " let Vundle manage Vundle, required
    "" Plugin 'gmarik/Vundle.vim'

    "" " The following are examples of different formats supported.
    "" " Keep Plugin commands between vundle#begin/end.
    "" " plugin on GitHub repo
    "" Plugin 'tpope/vim-fugitive'
    "" " plugin from http://vim-scripts.org/vim/scripts.html
    "" Plugin 'L9'
    "" " Git plugin not hosted on GitHub
    "" Plugin 'git://git.wincent.com/command-t.git'
    "" " git repos on your local machine (i.e. when working on your own plugin)
    "" Plugin 'file:///home/gmarik/path/to/plugin'
    "" " The sparkup vim script is in a subdirectory of this repo called vim.
    "" " Pass the path to set the runtimepath properly.
    "" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
    "" " Avoid a name conflict with L9
    "" Plugin 'user/L9', {'name': 'newL9'}

    " All of your Plugins must be added before the following line
    call vundle#end()            " required
endif

if executable("go")
    " Execute: go get -u golang.org/x/lint/golint
    if isdirectory($GOPATH . "/src/golang.org/x/lint/misc/vim")
        set rtp+=$GOPATH/src/golang.org/x/lint/misc/vim
        "autocmd BufWritePost,FileWritePost *.go execute 'Lint' | lwindow
    endif
endif


" This switches on three very clever mechanisms:
" 1. Filetype detection.
"    Whenever you start editing a file, Vim will try to figure out what kind of
"    file this is.  When you edit "main.c", Vim will see the ".c" extension and
"    recognize this as a "c" filetype.  When you edit a file that starts with
"    "#!/bin/sh", Vim will recognize it as a "sh" filetype.
"    The filetype detection is used for syntax highlighting and the other two
"    items below.
"    See |filetypes|.
"
" 2. Using filetype plugin files
"    Many different filetypes are edited with different options.  For example,
"    when you edit a "c" file, it's very useful to set the 'cindent' option to
"    automatically indent the lines.  These commonly useful option settings are
"    included with Vim in filetype plugins.  You can also add your own, see
"    |write-filetype-plugin|.
"
" 3. Using indent files
"    When editing programs, the indent of a line can often be computed
"    automatically.  Vim comes with these indent rules for a number of
"    filetypes.  See |:filetype-indent-on| and 'indentexpr'.
filetype plugin indent on

" This makes Vim break text to avoid lines getting longer than 78 characters.
" But only for files that have been detected to be plain text.  There are
" actually two parts here.  "autocmd FileType text" is an autocommand.  This
" defines that when the file type is set to "text" the following command is
" automatically executed.  "setlocal textwidth=78" sets the 'textwidth' option
" to 78, but only locally in one file.
"autocmd FileType text setlocal textwidth=78

let s:use_clang_complete=0
if s:use_clang_complete == 1
    """"""""""""""""""""""""""""""""""""""""""""""""""
    " clang_complete
    let g:clang_use_library          = 1
    let g:clang_complete_auto        = 1
    let g:clang_complete_copen       = 1
    let g:clang_hl_errors            = 0 "Don't enable by default, bacuase it hides errors.
    let g:clang_periodic_quickfix    = 0 "Don't enable by default, bacuase it hides errors.
    let g:clang_trailing_placeholder = 1 "Check work.
    let g:clang_close_preview        = 1
    let g:clang_complete_macros      = 1
    let g:clang_complete_patterns    = 1
    let g:clang_snippets             = 0
    let g:clang_snippets_engine      = ""
    let g:clang_user_options         = "-std=c++11"
    let g:clang_debug                = 1

    if hostname() == "circles"
      let g:clang_library_path         ="/usr/local/lib64/"
      "let g:clang_library_path         ="/usr/lib64/llvm"
    endif

    " Enable/Disable g:clang_hl_errors & g:clang_periodic_quickfix
    map <C-C> :let g:clang_hl_errors=!g:clang_hl_errors <CR> :let g:clang_periodic_quickfix=g:clang_hl_errors <CR> :echo 'Clang check:' g:clang_hl_errors <CR>
    map <C-q> :call g:ClangUpdateQuickFix() <CR>
else
    let g:clang_complete_loaded = 1
endif

let s:use_youcompleteme=1
if s:use_youcompleteme == 1
    let g:ycm_min_num_of_chars_for_completion = 2
    let g:ycm_auto_trigger                    = 1
    let g:ycm_error_symbol                    = 'E>'
    let g:ycm_warning_symbol                  = 'W>'
    let g:ycm_always_populate_location_list   = 1
    let g:ycm_server_keep_logfiles            = 1
    let g:ycm_autoTrigger                     = 1
    if filereadable('./.ycm_extra_conf.py')
        let g:ycm_global_ycm_extra_conf           = ''
    else
        let g:ycm_global_ycm_extra_conf           = '/home/ytsolov/.ycm_extra_conf.py'
    endif
    "let g:ycm_server_use_vim_stdout = 1
    let g:ycm_server_log_level = 'info'
    nnoremap <C-q> :YcmForceCompileAndDiagnostics<CR>
    nnoremap <leader>inc       :YcmCompleter GoToInclude<CR>
    nnoremap <leader>decl      :YcmCompleter GoToDeclaration<CR>
    nnoremap <leader>def       :YcmCompleter GoToDefinition<CR>
    nnoremap <leader>impl      :YcmCompleter GoToImplementation<CR>
    nnoremap <leader>type      :YcmCompleter GoToType<CR>
    nnoremap <leader>go        :YcmCompleter GoTo<CR>
    nnoremap <leader>gettype   :YcmCompleter GetType<CR>
    nnoremap <leader>getparent :YcmCompleter GetParent<CR>
    nnoremap <leader>fix       :YcmCompleter FixIt<CR>
    nnoremap <leader>format    :YcmCompleter Format<CR>

    let s:gowinview={}
    autocmd BufWritePre *.go let s:gowinview=winsaveview() | execute 'YcmCompleter Format'
    "autocmd BufWritePost *.go cwindow | call winrestview(s:gowinview)
endif

let s:use_pydiction=0
if s:use_pydiction == 1
    let g:pydiction_location = '/home/ytsolov/work/pydiction/complete-dict'
    let g:pydiction_menu_height = 20
endif

let s:use_jedi_vim=1
if s:use_jedi_vim == 1
endif

""""""""""""""""""""""""""""""""""""""""""""""""""
" TUTOR for commads
"1. To search case sensitive or insesitive:
"set ic   - disable case sensitivity
"set ignorecase
"set noic - enable case sensitivity
"set noignorecase
"set wrapscan  - when search hits bottom/top of file it stops
"scriptnames  - shows all files than can have VIM scripts

" Set colorscheme only for diff mode
" Color schemes are in: /usr/share/vim/vim72/colors
" if &diff
"    set t_Co=256
"    set backgroud=dark
"    colorscheme peaksea
" else
"    colorscheme YOUR_OTHER_COLOR_SCHEME_OF_CHOICE
" endif

autocmd FileType c,cpp set cindent | set foldmethod=syntax
autocmd FileType go set noexpandtab
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType make set noexpandtab
autocmd FileType cmake set expandtab | set foldmethod=indent
autocmd FileType python set expandtab | set foldmethod=indent

" Delete trailing whitespace and tabs at the end of each line
command! DeleteTrailingWs :%s/\(\s\|\t\)\+$//e

function! PrepareBufferBeforeClose()
    let l:_crow=line(".")
    let l:_ccol=col(".")
    DeleteTrailingWs
    call cursor(l:_crow,l:_ccol)
endfunction

"autocmd BufWritePre *.c, *.cpp, *.h, *.hpp, *.ipp call PrepareBufferBeforeClose()
"autocmd BufWritePre *.cpp, *.h, *.hpp, *.ipp call PrepareBufferBeforeClose()


if &bin
  au BufReadPost * %!xxd
  au BufWritePre * %!xxd -r
endif

" Speed up vim. The slowest command found with :syntime on; :syntime off; :syntime report
"syntax clear cppRawString
"syntax clear cCppString
"syntax clear cString

