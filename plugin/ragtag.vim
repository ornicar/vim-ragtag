" ragtag.vim - Ghetto XML/HTML mappings (formerly allml.vim)
" Author:       Tim Pope <vimNOSPAM@tpope.org>
" Version:      2.0
" GetLatestVimScripts: 1896 1 :AutoInstall: ragtag.vim

if exists("g:loaded_ragtag") || &cp
  finish
endif
let g:loaded_ragtag = 1

if has("autocmd")
  augroup ragtag
    autocmd!
    autocmd FileType *html*,wml,xml,xslt,xsd,jsp    call s:Init()
    autocmd FileType php,asp*,cf,mason,eruby,liquid call s:Init()
  augroup END
endif

inoremap <silent> <Plug>ragtagHtmlComplete <C-R>=<SID>htmlEn()<CR><C-X><C-O><C-P><C-R>=<SID>htmlDis()<CR><C-N>

" Public interface, for if you have your own filetypes to activate on
function! RagtagInit()
  call s:Init()
endfunction

function! AllmlInit()
  call s:Init()
endfunction

function! s:Init()
  let b:loaded_ragtag = 1
  if s:subtype() == "xml"
    imap <script> <buffer> <SID>doctype <SID>xmlversion
  elseif exists("+omnifunc")
    inoremap <silent> <buffer> <SID>doctype  <C-R>=<SID>htmlEn()<CR><!DOCTYPE<C-X><C-O><C-P><C-R>=<SID>htmlDis()<CR><C-N><C-R>=<SID>doctypeSeek()<CR>
  elseif s:subtype() == "xhtml"
    imap <script> <buffer> <SID>doctype <SID>xhtmltrans
  else
    imap <script> <buffer> <SID>doctype <SID>htmltrans
  endif

  if exists("&omnifunc")
    inoremap <silent> <buffer> <C-X>/ <Lt>/<C-R>=<SID>htmlEn()<CR><C-X><C-O><C-R>=<SID>htmlDis()<CR><C-F>
    if exists(":XMLns")
      XMLns xhtml10s
    endif
  else
    inoremap <silent> <buffer> <C-X>/ <Lt>/><Left>
  endif
  let g:surround_{char2nr("p")} = "<p>\n\t\r\n</p>"
  let g:surround_{char2nr("d")} = "<div\1div: \r^[^ ]\r &\1>\n\t\r\n</div>"
  imap <buffer> <C-X><C-_> <C-X>/
  if !exists("b:did_indent")
    if s:subtype() == "xml"
      runtime! indent/xml.vim
    else
      runtime! indent/html.vim
    endif
  endif
  " Pet peeve.  Do people still not close their <p> and <li> tags?
  if exists("g:html_indent_tags") && g:html_indent_tags !~ '\\|p\>'
    let g:html_indent_tags = g:html_indent_tags.'\|p\|li\|dt\|dd'
  endif
  set indentkeys+=!^F
  let b:surround_indent = 1
  silent doautocmd User ragtag
endfunction

function! s:length(str)
  return strlen(substitute(a:str,'.','.','g'))
endfunction

function! s:repeat(str,cnt)
  let cnt = a:cnt
  let str = ""
  while cnt > 0
    let str = str . a:str
    let cnt = cnt - 1
  endwhile
  return str
endfunction

function! s:doctypeSeek()
  if !exists("b:ragtag_doctype_index")
    if exists("b:allml_doctype_index")
      let b:ragtag_doctype_index = b:allml_doctype_index
    elseif &ft == 'xhtml' || &ft =~ '\<eruby\>'
      let b:ragtag_doctype_index = 10
    elseif &ft != 'xml'
      let b:ragtag_doctype_index = 7
    endif
  endif
  let index = b:ragtag_doctype_index - 1
  return (index < 0 ? s:repeat("\<C-P>",-index) : s:repeat("\<C-N>",index))
endfunction


function! s:htmlEn()
  let b:ragtag_omni = &l:omnifunc
  let b:ragtag_isk = &l:isk
  " : is for namespaced xml attributes
  setlocal omnifunc=htmlcomplete#CompleteTags isk+=:
  return ""
endfunction

function! s:htmlDis()
  if exists("b:ragtag_omni")
    let &l:omnifunc = b:ragtag_omni
    unlet b:ragtag_omni
  endif
  if exists("b:ragtag_isk")
    let &l:isk = b:ragtag_isk
    unlet b:ragtag_isk
  endif
  return ""
endfunction

function! s:subtype()
  let top = getline(1)."\n".getline(2)
  if (top =~ '<?xml\>' && &ft !~? 'html') || &ft =~? '^\%(xml\|xsd\|xslt\)$'
    return "xml"
  elseif top =~? '\<xhtml\>'
    return 'xhtml'
  elseif top =~ '[^<]\<html\>'
    return "html"
  elseif &ft == "xhtml" || &ft == '\<eruby\>'
    return "xhtml"
  elseif exists("b:loaded_ragtag")
    return "html"
  else
    return ""
  endif
endfunction

function! s:closetagback()
  if s:subtype() == "html"
    return ">\<Left>"
  else
    return " />\<Left>\<Left>\<Left>"
  endif
endfunction

function! s:closetag()
  if s:subtype() == "html"
    return ">"
  else
    return " />"
  endif
endfunction
