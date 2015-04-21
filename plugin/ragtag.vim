" ragtag.vim - Ghetto XML/HTML mappings (formerly allml.vim)
" Author:       Tim Pope <http://tpo.pe/>
" Version:      2.0
" GetLatestVimScripts: 1896 1 :AutoInstall: ragtag.vim

if exists("g:loaded_ragtag") || &cp || v:version < 700
  finish
endif
let g:loaded_ragtag = 1

if !exists('g:html_indent_inctags')
  let g:html_indent_inctags = 'body,head,html,tbody,p,li,dt,dd'
endif
if !exists('g:html_indent_autotags')
  let g:html_indent_autotags = 'wbr'
endif
if !exists('g:html_indent_script1')
  let g:html_indent_script1 = 'inc'
endif
if !exists('g:html_indent_style1')
  let g:html_indent_style1 = 'inc'
endif

augroup ragtag
  autocmd!
  autocmd BufReadPost * if ! did_filetype() && getline(1)." ".getline(2).
        \ " ".getline(3) =~? '<\%(!DOCTYPE \)\=html\>' | setf html | endif
  autocmd FileType *html*,wml,jsp,gsp,mustache,smarty         call s:Init()
  autocmd FileType php,asp*,cf,mason,eruby,liquid,jst,eelixir call s:Init()
  autocmd FileType xml,xslt,xsd,docbk                         call s:Init()
  autocmd InsertLeave * call s:Leave()
  autocmd CursorHold * if exists("b:loaded_ragtag") | call s:Leave() | endif
augroup END

inoremap <silent> <Plug>ragtagHtmlComplete <C-R>=<SID>htmlEn()<CR><C-X><C-O><C-P><C-R>=<SID>htmlDis()<CR><C-N>

" Public interface, for if you have your own filetypes to activate on
function! RagtagInit()
  call s:Init()
endfunction

function! AllmlInit()
  call s:Init()
endfunction

function! s:isFiletype(ft)
  return index(split(&filetype, '\.'), a:ft) >= 0
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
    imap <script> <buffer> <SID>doctype <SID>html5
  endif

  imap <silent> <buffer> <C-X># <C-R>=<SID>charsetTag()<CR>
  inoremap <silent> <buffer> <SID>HtmlComplete <C-R>=<SID>htmlEn()<CR><C-X><C-O><C-P><C-R>=<SID>htmlDis()<CR><C-N>
  imap     <buffer> <C-X>H <SID>HtmlComplete
  inoremap <silent> <buffer> <C-X>$ <C-R>=<SID>javascriptIncludeTag()<CR>
  inoremap <silent> <buffer> <C-X>@ <C-R>=<SID>stylesheetTag()<CR>
  inoremap <silent> <buffer> <C-X><Space> <Esc>ciW<Lt><C-R>"<C-R>=<SID>tagextras()<CR>></<C-R>"><Esc>F<i
  inoremap <silent> <buffer> <C-X><CR> <Esc>ciW<Lt><C-R>"<C-R>=<SID>tagextras()<CR>><CR></<C-R>"><Esc>O
  if exists("&omnifunc")
    inoremap <silent> <buffer> <C-X>/ <Lt>/<C-R>=<SID>htmlEn()<CR><C-X><C-O><C-R>=<SID>htmlDis()<CR><C-R>=<SID>reindent()<CR>
    if exists(":XMLns")
      XMLns xhtml10s
    endif
  else
    inoremap <silent> <buffer> <C-X>/ <Lt>/><Left>
  endif
  let g:surround_{char2nr("p")} = "<p>\n\t\r\n</p>"
  let g:surround_{char2nr("d")} = "<div\1div: \r^[^ ]\r &\1>\n\t\r\n</div>"
  imap <buffer> <C-X><C-_> <C-X>/
  imap <buffer> <SID>ragtagOopen    <C-X><Lt><Space>
  imap <buffer> <SID>ragtagOclose   <Space><C-X>><Left><Left>
  if s:isFiletype('php')
    inoremap <buffer> <C-X><Lt> <?php
    inoremap <buffer> <C-X>>    ?>
    inoremap <buffer> <SID>ragtagOopen    <?php<Space>echo<Space>
    let b:surround_45 = "<?php \r ?>"
    let b:surround_61 = "<?php echo \r ?>"
  elseif s:isFiletype('htmltt') || s:isFiletype('tt2html')
    inoremap <buffer> <C-X><Lt> [%
    inoremap <buffer> <C-X>>    %]
    let b:surround_45  = "[% \r %]"
    let b:surround_61  = "[% \r %]"
    if !exists("b:surround_101")
      let b:surround_101 = "[% \r %]\n[% END %]"
    endif
  elseif s:isFiletype('mustache')
    inoremap <buffer> <SID>ragtagOopen    {{<Space>
    inoremap <buffer> <SID>ragtagOclose   <Space>}}<Left><Left>
    inoremap <buffer> <C-X><Lt> {{
    inoremap <buffer> <C-X>>    }}
    let b:surround_45 = "{{ \r }}"
    let b:surround_61 = "{{ \r }}"
  elseif s:isFiletype('django') || s:isFiletype('htmldjango') || s:isFiletype('liquid') || s:isFiletype('htmljinja')
    inoremap <buffer> <SID>ragtagOopen    {{<Space>
    inoremap <buffer> <SID>ragtagOclose   <Space>}}<Left><Left>
    inoremap <buffer> <C-X><Lt> {%
    inoremap <buffer> <C-X>>    %}
    let b:surround_45 = "{% \r %}"
    let b:surround_61 = "{{ \r }}"
  elseif s:isFiletype('mason')
    inoremap <buffer> <SID>ragtagOopen    <&<Space>
    inoremap <buffer> <SID>ragtagOclose   <Space>&><Left><Left>
    inoremap <buffer> <C-X><Lt> <%
    inoremap <buffer> <C-X>>    %>
    let b:surround_45 = "<% \r %>"
    let b:surround_61 = "<& \r &>"
  elseif s:isFiletype('cf')
    inoremap <buffer> <SID>ragtagOopen    <cfoutput>
    inoremap <buffer> <SID>ragtagOclose   </cfoutput><Left><C-Left><Left>
    inoremap <buffer> <C-X><Lt> <cf
    inoremap <buffer> <C-X>>    >
    let b:surround_45 = "<cf\r>"
    let b:surround_61 = "<cfoutput>\r</cfoutput>"
  elseif s:isFiletype('smarty')
    inoremap <buffer> <SID>ragtagOopen    {
    inoremap <buffer> <SID>ragtagOclose   }
    inoremap <buffer> <C-X><Lt> {
    inoremap <buffer> <C-X>>    }
    let b:surround_45 = "{\r}"
    let b:surround_61 = "{\r}"
  else
    inoremap <buffer> <SID>ragtagOopen    <%=<Space>
    inoremap <buffer> <C-X><Lt> <%
    inoremap <buffer> <C-X>>    %>
    let b:surround_45 = "<% \r %>"
    let b:surround_61 = "<%= \r %>"
  endif
  imap <script> <buffer> <C-X>= <SID>ragtagOopen<SID>ragtagOclose<Left>
  imap <script> <buffer> <C-X>+ <C-V><NL><Esc>I<SID>ragtagOopen<Esc>A<SID>ragtagOclose<Esc>F<NL>s
  " <%\n\n%>
  if s:isFiletype('cf')
    inoremap <buffer> <C-X>] <cfscript><CR></cfscript><Esc>O
  elseif s:isFiletype('mason')
    inoremap <buffer> <C-X>] <%perl><CR></%perl><Esc>O
  elseif s:isFiletype('html') || s:isFiletype('xhtml') || s:isFiletype('xml')
    imap     <buffer> <C-X>] <script<C-R>=<SID>javascriptType()<CR>><CR></script><Esc>O
  else
    imap     <buffer> <C-X>] <C-X><Lt><CR><C-X>><Esc>O
  endif
  " <% %>
  if s:isFiletype('eruby') || s:isFiletype('jst')
    inoremap  <buffer> <C-X>- <%<Space><Space>%><Esc>2hi
    inoremap  <buffer> <C-X>_ <C-V><NL><Esc>I<%<Space><Esc>A<Space>%><Esc>F<NL>s
  elseif s:isFiletype('cf')
    inoremap  <buffer> <C-X>- <cf><Left>
    inoremap  <buffer> <C-X>_ <cfset ><Left>
  elseif s:isFiletype('smarty')
    imap <buffer> <C-X>- <C-X><Lt><C-X>><Esc>i
    imap <buffer> <C-X>_ <C-V><NL><Esc>I<C-X><Lt><Esc>A<C-X>><Esc>F<NL>s
  else
    imap <buffer> <C-X>- <C-X><Lt><Space><Space><C-X>><Esc>2hi
    imap <buffer> <C-X>_ <C-V><NL><Esc>I<C-X><Lt><Space><Esc>A<Space><C-X>><Esc>F<NL>s
  endif
  " Comments
  if s:isFiletype('aspperl') || s:isFiletype('aspvbs')
    imap <buffer> <C-X>' <C-X><Lt>'<Space><Space><C-X>><Esc>2hi
    imap <buffer> <C-X>" <C-V><NL><Esc>I<C-X><Lt>'<Space><Esc>A<Space><C-X>><Esc>F<NL>s
    let b:surround_35 = maparg("<C-X><Lt>","i")."' \r ".maparg("<C-X>>","i")
  elseif s:isFiletype('jsp') || s:isFiletype('gsp')
    inoremap <buffer> <C-X>'     <Lt>%--<Space><Space>--%><Esc>4hi
    inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<%--<Space><Esc>A<Space>--%><Esc>F<NL>s
    let b:surround_35 = "<%-- \r --%>"
  elseif s:isFiletype('cf')
    inoremap <buffer> <C-X>'     <Lt>!---<Space><Space>---><Esc>4hi
    inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<!---<Space><Esc>A<Space>---><Esc>F<NL>s
    setlocal commentstring=<!---%s--->
    let b:surround_35 = "<!--- \r --->"
  elseif s:isFiletype('html') || s:isFiletype('xml') || s:isFiletype('xhtml')
    inoremap <buffer> <C-X>'     <Lt>!--<Space><Space>--><Esc>3hi
    inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<!--<Space><Esc>A<Space>--><Esc>F<NL>s
    let b:surround_35 = "<!-- \r -->"
  elseif s:isFiletype('django') || s:isFiletype('htmldjango') || s:isFiletype('htmljinja')
    inoremap <buffer> <C-X>'     {#<Space><Space>#}<Esc>2hi
    inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<C-X>{#<Space><Esc>A<Space>#}<Esc>F<NL>s
    let b:surround_35 = "{# \r #}"
  elseif s:isFiletype('liquid')
    inoremap <buffer> <C-X>'     {%<Space>comment<Space>%}{%<Space>endcomment<Space>%}<Esc>15hi
    inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<C-X>{%<Space>comment<Space>%}<Esc>A{%<Space>endcomment<Space>%}<Esc>F<NL>s
    let b:surround_35 = "{% comment %}\r{% endcomment %}"
  elseif s:isFiletype('smarty')
    inoremap <buffer> <C-X>'     {*<Space><Space>*}<Esc>2hi
    inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<C-X>{*<Space><Esc>A<Space>*}<Esc>F<NL>s
    let b:surround_35 = "{* \r *}"
  else
    imap <buffer> <C-X>' <C-X><Lt>#<Space><Space><C-X>><Esc>2hi
    imap <buffer> <C-X>" <C-V><NL><Esc>I<C-X><Lt>#<Space><Esc>A<Space><C-X>><Esc>F<NL>s
    let b:surround_35 = maparg("<C-X><Lt>","i")."# \r ".maparg("<C-X>>","i")
  endif
  imap <buffer> <C-X>%           <Plug>ragtagUrlEncode
  imap <buffer> <C-X>&           <Plug>ragtagXmlEncode
  imap <buffer> <C-V>%           <Plug>ragtagUrlV
  imap <buffer> <C-V>&           <Plug>ragtagXmlV
  if !exists("b:did_indent")
    if s:subtype() == "xml"
      runtime! indent/xml.vim
    else
      runtime! indent/html.vim
    endif
  endif
  if exists("g:html_indent_tags") && g:html_indent_tags !~ '\\|p\>'
    let g:html_indent_tags = g:html_indent_tags.'\|p\|li\|dt\|dd'
    let g:html_indent_tags = g:html_indent_tags.'\|article\|aside\|audio\|bdi\|canvas\|command\|datalist\|details\|figcaption\|figure\|footer\|header\|hgroup\|mark\|meter\|nav\|output\|progress\|rp\|rt\|ruby\|section\|summary\|time\|video'
  endif
  set indentkeys+=!^F
  let b:surround_indent = 1
  silent doautocmd User Ragtag
  silent doautocmd User ragtag
endfunction

function! s:Leave()
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

function! s:reindent()
  if (len(&indentexpr) || &cindent)
    return "\<C-F>"
  endif
  return ""
endfun

function! s:doctypeSeek()
  if !exists("b:ragtag_doctype_index")
    if exists("b:allml_doctype_index")
      let b:ragtag_doctype_index = b:allml_doctype_index
    elseif s:isFiletype('xhtml') || s:isFiletype('eruby')
      let b:ragtag_doctype_index = 10
    elseif !s:isFiletype('xml')
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
  if (top =~ '<?xml\>' && &ft !~? 'html') || &ft =~? '^\%(xml\|xsd\|xslt\|docbk\)$'
    return "xml"
  elseif top =~? '\<xhtml\>'
    return 'xhtml'
  elseif top =~? '<!DOCTYPE html>'
    return 'html5'
  elseif top =~? '[^<]\<html\>'
    return "html"
  elseif s:isFiletype('xhtml')
    return "xhtml"
  elseif exists("b:loaded_ragtag")
    return "html5"
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
