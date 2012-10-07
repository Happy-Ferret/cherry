coffee  = require 'coffee-script'

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

jsl_args = ['-nologo', '-nosummary', '-nofilelisting',
            '-conf', 'node_modules/coffee-script/extras/jsl.conf']

recipe
  in:  'lib/*.js'
  out: 'lib/*.js-phony'
  run: (callback, output_path, input_path) ->
    spawn 'jsl', (jsl_args.concat ['-process', input_path]), (code, stdout, stderr) ->
      console.log stdout if stdout
      if code
        callback stderr
      else
        callback()
