coffee  = require 'coffee-script'

bin_line = '#!/usr/bin/env node'
npm = if process.platform is 'win32' then 'npm.cmd' else 'npm'

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
    spawn 'jsl', (jsl_args.concat ['-process', input_path]), spawn.default callback

recipe
  in:  'lib/*.js-phony'
  out: 'link-local'
  run: (callback) ->
    spawn npm, ['link'], spawn.default callback
