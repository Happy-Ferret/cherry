fs       = require 'fs'
_        = require 'underscore'
{do_all} = require './flow'

in_pattern = (pattern) ->
  new RegExp "^#{pattern.replace /\*./g, (match) -> "([^#{match[1]}./]+)\\#{match[1]}"}$"

out_pattern = (pattern) ->
  count = 1
  pattern.replace /\*/g, (match) -> "$#{count++}"

expand = (recipes) ->
  for recipe in recipes
    recipe.in_pattern  = in_pattern recipe.in
    recipe.out_pattern = out_pattern recipe.out
    recipe.also ?= []
    recipe.also_patterns = for also in recipe.also
      out_pattern also
  recipes

scan_dir = (path) ->
  files = fs.readdirSync path
  paths = ((path + '/' + name).replace('./', '') for name in files)
  paths.concat(scan_dir path for path in paths when fs.statSync(path).isDirectory() ...)

needs_recompile = (output_path, input_paths..., callback) ->
  check = (err, stats) ->
    if err
      callback err
      return

    output_mtime = stats.shift().mtime
    if not output_mtime
      callback null, true
      return

    for mtime in _.pluck stats, 'mtime'
      if not mtime or mtime > output_mtime
        callback null, true
        return
    callback null, false

  check_all = do_all (path, callback) ->
    fs.exists path, (exists) ->
      if exists
        fs.stat path, callback
      else
        callback null, {}

  check_all.call null, [output_path, input_paths...], check

module.exports =
  in_pattern:      in_pattern
  out_pattern:     out_pattern
  expand:          expand
  scan_dir:        scan_dir
  needs_recompile: needs_recompile
