fs = require 'fs'

# Seems that on Windows fs.watch invokes callback two times.
double_call_workaround = (output_path, outputs, callback) ->
  call = true
  () ->
    call = not call
    callback output_path, outputs if call

watch = (output_path, outputs, callback) ->
  output = outputs[output_path]
  for path in output.deps
    if not outputs[path] # Only if not an interdepedendency
      fs.watch path, persistent: true, (double_call_workaround output_path, outputs, callback)

module.exports = watch
