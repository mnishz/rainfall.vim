scriptencoding utf-8


let s:winid = 0
let s:timerid = 0
let s:last_msg = ''


function rainfall#enable() abort
  if s:timerid == 0
    let s:last_msg = ''
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
    " close の場合は s:last_msg を保持したまま単に閉じる
    " 内容が更新されたときだけ s:update_message() が再表示する
    call popup_close(s:winid)
    let s:winid = 0
  endif
endfunction


let s:parsed_data = {
      \ 'location': '',
      \ 'amount': 0.0,
      \ }


function s:create_rainfall_job(timer) abort
  " initialization
  let s:parsed_data.location = ''
  let l:job = job_start(['curl', 'https://www.data.jma.go.jp/obd/stats/data/mdrr/pre_rct/alltable/pre1h00_rct.csv'], {
        \ 'out_cb': function('s:parse_data'),
        \ 'close_cb': function('s:show_rainfall'),
        \ })
endfunction


function s:parse_data(ch, msg) abort
  if a:msg =~# '^' .. g:rainfall#location_number .. ','
    let l:list = split(iconv(a:msg, 'sjis', 'utf-8'), ',')
    let s:parsed_data.location = l:list[2][:match(l:list[2], '（')-1]
    let s:parsed_data.amount = str2float(l:list[9])
  endif
endfunction


function s:show_rainfall(ch) abort
  if empty(s:parsed_data.location)
    call s:update_message('error')
    return
  endif

  if s:parsed_data.amount == 0.0
    " 降水量が 0 のときは 0 であることを保持したうえで、s:update_message() に消してもらう
    call s:update_message('')
  else
    let l:text = ''
    if s:parsed_data.amount <= 1.0
      let l:text = g:rainfall#mark
    elseif s:parsed_data.amount <= 2.0
      let l:text = g:rainfall#mark .. g:rainfall#mark
    else
      let l:text = g:rainfall#mark .. g:rainfall#mark .. g:rainfall#mark
    endif
    call s:update_message(s:parsed_data.location .. ': ' .. l:text)
  endif
endfunction


function s:update_message(msg) abort
  if a:msg !=# s:last_msg
    let s:last_msg = a:msg
    if empty(a:msg)
      call rainfall#close()
    else
      if s:winid == 0
        let s:winid = popup_create(a:msg, {
              \ 'border': [],
              \ 'padding': [0, 1, 0, 1],
              \ 'line': &lines-5,
              \ 'col': &columns-5,
              \ 'pos': 'botright',
              \ 'drag': 1,
              \ 'close': 'button',
              \ 'tabpage': -1
              \ })
      else
        call popup_settext(s:winid, a:msg)
      endif
    endif
  endif
endfunction
