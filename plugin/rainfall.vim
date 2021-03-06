scriptencoding utf-8

if exists('g:loaded_rainfall')
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
let g:rainfall#location_number = get(g:, 'rainfall#location_number', 44132)

command RainfallEnable call rainfall#enable()
command RainfallDisable call rainfall#disable()
command RainfallClose call rainfall#close()

RainfallEnable

let &cpo = s:save_cpo
unlet s:save_cpo
