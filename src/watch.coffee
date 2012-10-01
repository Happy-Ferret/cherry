fs = require 'fs'

watch = (output_path, outputs, callback) ->
  output = outputs[output_path]
  for path in output.deps
    if not outputs[path] # Only if not an interdepedendency
      fs.watch path, persistent: true, () ->
        callback output_path, outputs

module.exports = watch
