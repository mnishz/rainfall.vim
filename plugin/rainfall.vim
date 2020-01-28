scriptencoding utf-8

if exists('g:loaded_rainfall') || !executable('curl')
  finish
endif
let g:loaded_rainfall = 1

let s:save_cpo = &cpo
set cpo&vim

" 現在の雨の強さによって傘のアイコンを出す
"     1 mm 以下、傘 1 個
"     2 mm 以下、傘 2 個
"     2 mm 超え、傘 3 個

" parameters
let g:rainfall#mark = get(g:, 'rainfall#mark', '☂')
let g:rainfall#url = get(g:, 'rainfall#url', 'https://tenki.jp/amedas/3/16/44132.html')

command RainfallEnable call rainfall#enable()
" command RainfallDisable call rainfall#disable()
command RainfallDisableToday call rainfall#disable_today()
command RainfallClose call rainfall#close()

if !rainfall#is_disabled_today()
  RainfallEnable
endif

let &cpo = s:save_cpo
unlet s:save_cpo
