fs = require 'fs'
_  = require 'underscore'

gen_final_callback = (output_path, outputs) -> (err) ->
  output = outputs[output_path]
  if err
    console.error "Error while building #{output_path}", err.stack or err
  else
    console.log "Built #{output_path}"
    for next_path in output.nexts
      next = outputs[next_path]
      next.awaiting = _.without next.awaiting, output_path
      build_one next_path, outputs

build_one = (output_path, outputs) ->
  output = outputs[output_path]
  if output.awaiting.length is 0
    console.log "Building #{output_path} from #{output.deps.join(', ')}"
    callback = gen_final_callback output_path, outputs
    output.recipe.run callback, output_path, output.deps... # TODO: try catch
  else
    console.log "Target #{output_path} is waiting for #{output.awaiting.join ', '}"

build = (outputs) ->
  for own output_path of outputs
    build_one output_path, outputs

module.exports = build
