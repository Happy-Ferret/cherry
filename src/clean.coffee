fs           = require './io'
_            = require 'underscore'
{in_pattern} = require './discovery'
{do_all}     = require './flow'

rm = (path, callback) ->
  fs.exists path, (exists) ->
    if exists
      console.log "Deleting #{path}"
      fs.unlink path, callback
    else
      callback()

clean = (outputs, callback) ->
  (do_all rm) (_.keys outputs), callback

clean.help = 'Deletes all targets'

purify = (recipes, paths, callback) ->
  matching_paths = []
  for recipe in recipes
    output_pattern = in_pattern recipe.out
    matching_paths = _.union matching_paths, paths.filter (path) -> output_pattern.test(path)

  (do_all rm) matching_paths, callback

module.exports =
  clean:  clean
  purify: purify
