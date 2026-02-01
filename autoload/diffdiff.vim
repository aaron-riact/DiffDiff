function! s:getText(lineno)
   return matchstr(getline(a:lineno), '^[<|=>]\{7}\($\| \)\zs.*$')
endfunction

function! diffdiff#DiffDiff() range
  let diff = getline(a:firstline, a:lastline)
  let head_mark = match(diff, '^<\{7}<\@!')
  let ance_mark = match(diff, '^|\{7}|\@!', head_mark+1)
  let merg_mark = match(diff, '^=\{7}=\@!', ance_mark+1)
  let endd_mark = match(diff, '^>\{7}>\@!', merg_mark+1)

  if endd_mark == -1
    let endd_mark = 0 "exclude end marker
  endif

  let label_head = s:getText(a:firstline + head_mark)
  let label_ance = 'common' "s:getText(a:firstline + ance_mark)
  let label_endd = s:getText(a:firstline + endd_mark)

  let file_head = tempname()
  let file_ance = tempname()
  let file_merg = tempname()

  call writefile(diff[head_mark+1:ance_mark-1], file_head)
  call writefile(diff[ance_mark+1:merg_mark-1], file_ance)
  call writefile(diff[merg_mark+1:endd_mark-1], file_merg)

  if exists('t:_DiffDiffbufnr') && bufwinnr(t:_DiffDiffbufnr) > 0
    exe bufwinnr(t:_DiffDiffbufnr)."wincmd W"
    exe 'normal ggdG'
  else
    vnew
    setlocal filetype=diff
    let t:_DiffDiffbufnr = bufnr('%')
  endif

  silent :execute 'r !diff -u '.file_ance.' '.file_head.' --label "'.label_ance.'" --label "'.label_head .'"'
  silent :execute 'r !echo "\n\n\n"'
  silent :execute 'r !diff -u '.file_ance.' '.file_merg.' --label "'.label_ance.'" --label "'.label_endd .'"'

  setlocal nomodified
  nnoremap <silent> <buffer> q :bw<cr>
endfunction
