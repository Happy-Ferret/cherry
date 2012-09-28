fs           = require 'fs'
_            = require 'underscore'
{in_pattern} = require './discovery'

rm = (path) ->
  console.log "Deleting #{path}"
  fs.unlink path, (err) -> if err then console.error err.stack or err

clean = (outputs) ->
  rm output_path for own output_path of outputs when fs.existsSync output_path

purify = (recipes, paths) ->
  matching_paths = []
  for recipe in recipes
    output_pattern = in_pattern recipe.out
    matching_paths = _.union matching_paths, paths.filter (path) -> output_pattern.test(path)

  rm path for path in matching_paths

module.exports =
  clean:  clean
  purify: purify
