fs       = require 'fs'
_        = require 'underscore'

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

scan_dir = (path, callback) ->
  files = fs.readdirSync path
  paths = ((path + '/' + name).replace('./', '') for name in files)
  all_paths = paths.concat(scan_dir path for path in paths when fs.statSync(path).isDirectory() ...)
  if callback
    callback null, all_paths
  all_paths

module.exports =
  in_pattern:  in_pattern
  out_pattern: out_pattern
  expand:      expand
  scan_dir:    scan_dir
