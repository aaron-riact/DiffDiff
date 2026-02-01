function! diffdiff#DiffDiff()
  let diff = @0
  let [head, rest] = split(diff, '||||||| \p*\n')
  let [ance, merg] = split(rest, '=======\n', 1)

  if head=~'<<<<<<< \p*\n'
    let [_, head]  = split(head, '<<<<<<< \p*\n', 1)
  endif

  if merg=~'>>>>>>> \p*\n'
    let [merg, _]  = split(merg, '>>>>>>> \p*\n', 1)
  endif

  let file_head = tempname()
  let file_ance = tempname()
  let file_merg = tempname()

  call writefile(split(head, '\n'), file_head)
  call writefile(split(ance, '\n'), file_ance)
  call writefile(split(merg, '\n'), file_merg)

  if exists('t:_DiffDiffbufnr') && bufwinnr(t:_DiffDiffbufnr) > 0
    exe bufwinnr(t:_DiffDiffbufnr)."wincmd W"
    exe 'normal ggdG'
  else
    vnew
    setlocal filetype=diff
    let t:_DiffDiffbufnr = bufnr('%')
  endif

  silent :execute 'r !diff -u '.file_ance.' '.file_head.' --label common --label HEAD'
  silent :execute 'r !echo "\n\n\n"'
  silent :execute 'r !diff -u '.file_ance.' '.file_merg.' --label common --label merg'
  call delete(file_head)
  call delete(file_ance)
  call delete(file_merg)

  setlocal nomodified
  nnoremap <silent> <buffer> q :bw<cr>
endfunction
