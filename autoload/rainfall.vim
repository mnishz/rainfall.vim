scriptencoding utf-8

" 現在の雨の強さによって傘のアイコンを出す
"     1 mm 以下、傘 1 個
"     2 mm 以下、傘 2 個
"     2 mm 超え、傘 3 個

let g:rainfall#char = '☂'
let g:rainfall#url = 'https://tenki.jp/amedas/3/16/44132.html'

let s:last_datetime = ''
let s:amedas_updated = v:false
let s:winid = 0
let s:timerid = 0

function rainfall#enable() abort
  if s:timerid == 0
    let s:last_datetime = ''
    call s:show_rainfall(0)
    " 5 分ごとに見に行く
    let s:timerid = timer_start(5 * 60 * 1000, function('s:show_rainfall'), {'repeat': -1})
    if !has('vim_starting') | echo 'enabled' | endif
  else
    echo 'already enabled'
  endif
endfunction

function rainfall#disable() abort
  if s:timerid != 0
    call timer_stop(s:timerid)
    let s:timerid = 0
    call rainfall#close()
    echo 'disabled'
  else
    echo 'already disabled'
  endif
endfunction

function rainfall#close() abort
  if s:winid != 0
    call popup_close(s:winid)
    let s:winid = 0
  endif
endfunction

function s:show_rainfall(timer) abort
  let s:amedas_updated = v:false
  let l:job = job_start(
        \ ['curl', g:rainfall#url],
        \ {'out_cb': function('s:parse_and_show_new_rainfall')})
endfunction

function s:parse_and_show_new_rainfall(ch, msg) abort
  if a:msg =~# 'amedas-point-datetime' && a:msg !=# s:last_datetime
    " 前回見た時刻から更新されている
    let s:last_datetime = a:msg
    let s:amedas_updated = v:true
  endif
  if s:amedas_updated && a:msg =~# '10分値'
    " 結果を更新
    let l:rainfall = str2float(a:msg[match(a:msg, "[0-9.]*mm"):match(a:msg, 'mm')-1])
    if l:rainfall == 0.0
      call rainfall#close()
    else
      let l:text = ''
      if l:rainfall <= 1.0
        let l:text = g:rainfall#char
      elseif l:rainfall <= 2.0
        let l:text = g:rainfall#char .. g:rainfall#char
      else
        let l:text = g:rainfall#char .. g:rainfall#char .. g:rainfall#char
      endif
      let s:winid = popup_create(l:text, {
            \ 'border': [],
            \ 'padding': [0, 1, 0, 1],
            \ 'line': &lines-5,
            \ 'col': &columns-5,
            \ 'pos': 'botright',
            \ })
    endif
    let s:amedas_updated = v:false
  endif
endfunction
