child_process = require 'child_process'

output_gatherer = () ->
  data = []
  getter = (new_data) -> data.push new_data
  getter.get_output = () -> data.join ''
  getter

spawn = (command, args, callback) ->
  child = child_process.spawn command, args
  stdout = output_gatherer()
  stderr = output_gatherer()
  child.stdout.on 'data', stdout
  child.stderr.on 'data', stderr
  child.on 'exit', (code) ->
    callback code, stdout.get_output(), stderr.get_output()

module.exports = spawn
