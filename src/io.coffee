bagpipe = new (require 'bagpipe') 10
fs = require 'fs'

Object.keys(fs).forEach (name) ->
  delegate = fs[name].bind(fs)
  exports[name] =
    if name.indexOf('Sync') >= 0
      delegate
    else
      (args...) -> bagpipe.push delegate, args...
