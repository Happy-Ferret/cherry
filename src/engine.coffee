fs = require 'fs'
_  = require 'underscore'

translate_input_pattern = (pattern) ->
  new RegExp "^#{pattern.replace /\*./g, (match) -> "([^#{match[1]}./]+)\\#{match[1]}"}$"

translate_output_pattern = (pattern) ->
  count = 1
  pattern.replace /\*/g, (match) -> "$#{count++}"

scan_dir = (path) ->
  files = fs.readdirSync path
  paths = ((path + '/' + name).replace('./', '') for name in files)
  paths.concat(scan_dir path for path in paths when fs.statSync(path).isDirectory() ...)

dep_tree = (callback, recipes, paths, outputs = {}) ->
  new_paths = []
  for recipe in recipes when typeof recipe.run is 'function'
    input_pattern  = translate_input_pattern recipe.in
    output_pattern = translate_output_pattern recipe.out
    matching_paths = paths.filter (path) -> input_pattern.test(path)

    # Group all inputs by their outputs.
    for input_path in matching_paths
      output_path = input_path.replace input_pattern, output_pattern
      new_paths.push output_path

      if not outputs[output_path]
        outputs[output_path] = recipe: recipe, deps: [], nexts: [], awaiting: []
      output = outputs[output_path]

      deps = [input_path, (recipe.dep? input_path) or []...]

      # Interdepencies are discovered here:
      for dep in deps
        if outputs[dep]
          outputs[dep].nexts.push output_path
          output.awaiting.push dep

      output.deps.push deps...

  if new_paths.length > 0
    dep_tree callback, recipes, new_paths, outputs
  else
    callback outputs

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

rm = (path) ->
  console.log "Deleting #{path}"
  fs.unlink path, (err) -> if err then console.error err.stack or err

clean = (outputs) ->
  rm output_path for own output_path of outputs when fs.existsSync output_path

purify = (recipes, paths) ->
  matching_paths = []
  for recipe in recipes
    output_pattern = translate_input_pattern recipe.out
    matching_paths = _.union matching_paths, paths.filter (path) -> output_pattern.test(path)

  rm path for path in matching_paths

module.exports =
  scan_dir: scan_dir
  dep_tree: dep_tree
  build:    build
  clean:    clean
  purify:   purify
