fs          = require 'fs'
{build_one} = require './build'

# Seems that on Windows fs.watch invokes callback two times.
double_call_workaround = (output_path, outputs, callback) ->
  call = true
  () ->
    call = not call
    callback output_path, outputs if call

# Watch depenedencies of a target. Triger callback on change of any of
# dependencies.
watch_deps = (output_path, outputs, callback) ->
  output = outputs[output_path]
  for path in output.deps
    if not outputs[path] # Only if not an interdepedendency
      fs.watch path, persistent: true, (double_call_workaround output_path, outputs, callback)

# Watch a directory recursively and match new files against recipes.
# Callback is triggered for any target that have new deps.
dir = (path, recipes, outputs, callback) ->
  # 1. read dir
  # 2. foreach recipes
  #    dep_path(path) which gives matched output_path
  # 3. callback output_path, outputs

watch = (outputs) ->
  for own output_path, output of outputs
    watch_deps output_path, outputs, build_one

watch.help = 'Watches all inputs and rebuilds outdated targets'

module.exports = watch
