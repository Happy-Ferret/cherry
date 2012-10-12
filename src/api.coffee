{inspect}          = require 'util'
build              = require './build'
dep_tree           = require './dep_tree'
{clean, purify}    = require './clean'
{scan_dir, expand} = require './discovery'

start_dir = '.'

with_full_tree = (action) -> (recipes) ->
  dep_tree action, (expand recipes), scan_dir start_dir

color_output = process.stdout.columns > 0

module.exports =
  build:  with_full_tree build
  dump:   with_full_tree (tree) -> console.log inspect tree, false, 4, color_output
  clean:  with_full_tree clean
  purify: (recipes) -> purify recipes, scan_dir start_dir
