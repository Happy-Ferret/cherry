translate_input_pattern = (pattern) ->
  new RegExp "^#{pattern.replace /\*./g, (match) -> "([^#{match[1]}./]+)\\#{match[1]}"}$"

translate_output_pattern = (pattern) ->
  count = 1
  pattern.replace /\*/g, (match) -> "$#{count++}"

scan_dir = (path) ->
  files = fs.readdirSync path
  paths = ((path + '/' + name).replace('./', '') for name in files)
  paths.concat(scan_dir path for path in paths when fs.statSync(path).isDirectory() ...)

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
    output.recipe.compile callback, output_path, output.deps... # TODO: try catch
  else
    console.log "Target #{output_path} is waiting for #{output.awaiting.join ', '}"

# TODO: getting deps by get_deps should be integrated here before recursion
group_outputs_inputs = (recipes, paths, outputs = {}) ->
  new_paths = []
  for recipe in recipes when typeof recipe.compile is 'function'
    input_pattern  = translate_input_pattern recipe.pattern
    output_pattern = translate_output_pattern recipe.save_as
    matching_paths = paths.filter (path) -> input_pattern.test(path)

    # Group all inputs by their outputs.
    for input_path in matching_paths
      output_path = input_path.replace input_pattern, output_pattern
      new_paths.push output_path
      if not outputs[output_path]
        outputs[output_path] = recipe: recipe, deps: [], nexts: [], awaiting: []
      outputs[output_path].deps.push input_path

  if new_paths.length > 0
    group_outputs_inputs recipes, new_paths, outputs
  else
    outputs

get_recipe_deps = (recipe, input_paths) ->
  _.uniq if typeof recipe.get_deps is 'function'
    input_paths.concat (recipe.get_deps input_path for input_path in input_paths)...
  else
    input_paths

get_outputs_deps = (outputs) ->
  for own output_path, output of outputs
    deps = output.deps = get_recipe_deps output.recipe, output.deps # TODO: try catch
    # Interdepencies are discovered here:
    for dep in deps
      if outputs[dep]
        outputs[dep].nexts.push output_path
        output.awaiting.push dep
  outputs

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
    output_pattern = translate_input_pattern recipe.save_as
    matching_paths = _.union matching_paths, paths.filter (path) -> output_pattern.test(path)

  rm path for path in matching_paths
