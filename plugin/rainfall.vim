scriptencoding utf-8

if exists('g:loaded_rainfall')
  finish
endif
let g:loaded_rainfall = 1

let s:save_cpo = &cpo
set cpo&vim

command RainfallEnable call rainfall#enable()
command RainfallDisable call rainfall#disable()
command RainfallClose call rainfall#close()

RainfallEnable

let &cpo = s:save_cpo
unlet s:save_cpo
