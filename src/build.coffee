_                 = require 'underscore'
{needs_recompile} = require './discovery'

done = (output_path, outputs) ->
  output = outputs[output_path]
  build_nexts output_path, outputs

build_nexts = (output_path, outputs) ->
  output = outputs[output_path]
  for next_path in output.nexts
    next = outputs[next_path]
    next.awaiting = _.without next.awaiting, output_path
    build_one next_path, outputs

gen_final_callback = (output_path, outputs) -> (err) ->
  output = outputs[output_path]
  if err
    console.error "Error while building #{output_path}", err.stack or err
  else
    console.log "Built #{output_path}"
    done output_path, outputs

build_one = (output_path, outputs) ->
  output = outputs[output_path]

  output.building = true

  if output.awaiting.length isnt 0
    console.log "Target #{output_path} is waiting for #{output.awaiting.join ', '}"
    return

  needs_recompile output_path, output.deps..., (err, recompile) ->
    if err
      console.error "Error while checking dates of deps for #{output_path}:"
      console.error err.stack or err
      return

    if not recompile
      console.log "Target #{output_path} is already up to date."
      done output_path, outputs
    else
      console.log "Building #{output_path} from #{output.deps.join(', ')}"
      callback = gen_final_callback output_path, outputs
      try
        output.recipe.run.call output, output.deps, callback
      catch error
        callback error

build = (outputs) ->
  for own output_path of outputs
    build_one output_path, outputs

module.exports = build
