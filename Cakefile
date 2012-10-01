coffee  = require 'coffee-script'
{spawn} = require 'child_process'

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

output_gatherer = () ->
  data = []
  getter = (new_data) -> data.push new_data
  getter.get_output = () -> return data.join ''
  getter

recipe
  in:  'lib/*.js'
  out: 'lib/*.js-phony'
  run: (callback, output_path, input_path) ->
    jsl = spawn 'jsl', jsl_args.concat ['-process', input_path]
    stdout_gatherer = output_gatherer()
    stderr_gatherer = output_gatherer()
    jsl.stdout.on 'data', stdout_gatherer
    jsl.stderr.on 'data', stderr_gatherer
    jsl.on 'exit', (code) ->
      out_str = stdout_gatherer.get_output()
      console.log out_str if out_str
      if code
        callback stderr_gatherer.get_output()
      else
        callback()
