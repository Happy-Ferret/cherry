coffee = require 'coffee-script'
fs     = require 'fs'

bin_line = '#!/usr/bin/env node'
npm = if process.platform is 'win32' then 'npm.cmd' else 'npm'

recipe
  in:  'src/cherry.coffee'
  out: 'lib/cherry.js'
  also: ['lib']
  run: (flow (take 1),
             (read 'utf8'),
             (compile (src) -> "#{bin_line}\n#{coffee.compile src}"),
             (save 'utf8'))

recipe
  in:  'src/*.coffee'
  out: 'lib/*.js'
  also: ['lib']
  run: (flow (take 1), (read 'utf8'), (compile coffee.compile), (save 'utf8'))

recipe
  in:  'lib/*.js'
  out: 'npm link'
  run: (deps, callback) ->
    spawn npm, ['link'], spawn.default callback
