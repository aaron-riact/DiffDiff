function! s:getText(lineno)
   return matchstr(getline(a:lineno), '^[<|=>]\{7}\($\| \)\zs.*$')
endfunction

function! diffdiff#DiffDiffAuto()
  let head_line = getline('.') =~# '^<\{7}' ? line('.') : search('^<\{7}', 'bnW')
  let end_line = getline('.') =~# '^>\{7}' ? line('.') : search('^>\{7}', 'nW')
  if head_line == 0 || end_line == 0
    echohl ErrorMsg | echo "No conflict markers found around cursor" | echohl None
    return
  endif
  execute head_line . ',' . end_line . 'call diffdiff#DiffDiff()'
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
    nnoremap <silent> <buffer> q <cmd>bwipeout!<cr>
  endif

  silent :put =systemlist('diff -u '.file_ance.' '.file_head.' --label '.shellescape(label_ance).' --label '.shellescape(label_head))
  silent :put =repeat([''], 3)
  silent :put =systemlist('diff -u '.file_ance.' '.file_merg.' --label '.shellescape(label_ance).' --label '.shellescape(label_endd))
  silent :put =repeat([''], 4)
  silent :put =systemlist('diff -u '.file_head.' '.file_merg.' --label '.shellescape(label_head).' --label '.shellescape(label_endd))
  call delete(file_head)
  call delete(file_ance)
  call delete(file_merg)

  setlocal nomodified
endfunction
