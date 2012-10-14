_ = require 'underscore'

interdep = (deps, output_path, outputs) ->
  output = outputs[output_path]

  for dep in deps
    if (outputs[dep]?.nexts?.indexOf output_path) is -1
      outputs[dep].nexts.push output_path
      output.awaiting.push dep

  for own other_output_path, other_output of outputs
    if (other_output.deps.indexOf output_path) isnt -1 and (other_output.awaiting.indexOf output_path) is -1
      output.nexts.push other_output_path
      other_output.awaiting.push output_path

dep_path = (callback, recipe, input_path, outputs) ->
  output_path = input_path.replace recipe.in_pattern, recipe.out_pattern

  is_new = not outputs[output_path]
  if is_new
    outputs[output_path] =
      path:     output_path
      recipe:   recipe
      deps:     []
      nexts:    []
      awaiting: []

  output = outputs[output_path]

  alsos = for also in recipe.also_patterns
    input_path.replace recipe.in_pattern, also

  deps = [input_path].concat alsos

  gather_deps = (error, new_deps) ->
    if error
      console.error "Error while getting deps for #{input_path} with recipe:", recipe
      console.error error.stack || error

    if new_deps instanceof Array
      deps.push new_deps...
    else if new_deps
      deps.push new_deps

    output.deps = _.uniq _.flatten [output.deps, deps]
    interdep deps, output_path, outputs
    callback is_new, output_path

  if typeof recipe.dep is 'function'
    try
      recipe.dep (_.clone deps), gather_deps
    catch err
      gather_deps err
  else
    gather_deps()

dep_tree = (callback, recipes, input_paths, outputs = {}) ->
  to_go = 0

  check = (is_new, output_path) ->
    --to_go
    if is_new
      scan output_path
    if to_go is 0
      callback outputs

  scan = (paths...) ->
    for recipe in recipes
      for path in paths when recipe.in_pattern.test(path)
        ++to_go
        process.nextTick dep_path.bind null, check, recipe, path, outputs

  scan input_paths...

module.exports = dep_tree
