coffee = require 'coffee-script'

bin_line = '#!/usr/bin/env node'

recipe
  in:  'src/cherry.coffee'
  out: 'lib/cherry.js'
  run: (flow (read 'utf8'),
             (compile (src) -> "#{bin_line}\n#{coffee.compile src}"),
             (save 'utf8'))

recipe
  in:  'src/*.coffee'
  out: 'lib/*.js'
  run: (flow (read 'utf8'), (compile coffee.compile), (save 'utf8'))
