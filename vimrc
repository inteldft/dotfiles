if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
syntax on
set expandtab
set number
set showcmd
set lazyredraw
set showmatch
set incsearch
inoremap fd <esc>

func Backspace()
  if col('.') == 1
    if line('.')  != 1
      return  "\<ESC>kA\<Del>"
    else
      return ""
    endif
  else
    return "\<Left>\<Del>"
  endif
endfunc

inoremap <BS> <c-r>=Backspace()<CR>
