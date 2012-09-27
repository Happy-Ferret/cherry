coffee = require 'coffee-script'

recipe
  in:  'src/*.coffee'
  out: 'lib/*.js'
  run: (flow (read 'utf8'), (compile coffee.compile), (save 'utf8'))
  dep: ->
