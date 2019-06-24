scriptencoding utf-8

" 現在の雨の強さによって傘のアイコンを出す
"     1 mm 以下、傘 1 個
"     2 mm 以下、傘 2 個
"     2 mm 超え、傘 3 個

" parameters
let g:rainfall#char = '☂'
let g:rainfall#url = 'https://tenki.jp/amedas/3/16/44132.html'


let s:winid = 0
let s:timerid = 0


function rainfall#enable() abort
  if s:timerid == 0
    call s:create_rainfall_job(0)
    " 5 分ごとに見に行く
    let s:timerid = timer_start(5 * 60 * 1000, function('s:create_rainfall_job'), {'repeat': -1})
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


let s:parsed_data = {
      \ 'datetime': '',
      \ 'amount_str': '',
      \ }


function s:create_rainfall_job(timer) abort
  " initialization
  let s:parsed_data.datetime = ''
  let s:parsed_data.amount_str = ''
  let l:job = job_start(['curl', g:rainfall#url], {
        \ 'out_cb': function('s:parse_data'),
        \ 'close_cb': function('s:show_rainfall'),
        \ })
endfunction


function s:parse_data(ch, msg) abort
  if a:msg =~# 'amedas-point-datetime'
    let s:parsed_data.datetime = a:msg
  endif
  if a:msg =~# '10分値'
    let s:parsed_data.amount_str = a:msg[match(a:msg, "[0-9.]*mm"):match(a:msg, 'mm')-1]
  endif
endfunction


function s:show_rainfall(ch) abort
  let l:location = s:parsed_data.datetime[match(s:parsed_data.datetime, "<h2>")+4:match(s:parsed_data.datetime, '(')-1]
  let l:amount = str2float(s:parsed_data.amount_str)
  if empty(s:parsed_data.datetime) || empty(l:location) || (s:parsed_data.amount_str !=# '0.0' && l:amount == 0.0)
    call s:show_message('error')
  else
    if l:amount == 0.0
      call rainfall#close()
    else
      let l:text = ''
      if l:amount <= 1.0
        let l:text = g:rainfall#char
      elseif l:amount <= 2.0
        let l:text = g:rainfall#char .. g:rainfall#char
      else
        let l:text = g:rainfall#char .. g:rainfall#char .. g:rainfall#char
      endif
      call s:show_message(l:location .. ': ' .. l:text)
    endif
  endif
endfunction


function s:show_message(msg) abort
  if s:winid == 0
    let s:winid = popup_create(a:msg, {
          \ 'border': [],
          \ 'padding': [0, 1, 0, 1],
          \ 'line': &lines-5,
          \ 'col': &columns-5,
          \ 'pos': 'botright',
          \ })
  else
    call popup_settext(s:winid, a:msg)
  endif
endfunction
