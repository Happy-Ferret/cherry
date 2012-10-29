{inspect}          = require 'util'
{build, build_one} = require './build'
watch              = require './watch'
dep_tree           = require './dep_tree'
{clean, purify}    = require './clean'
{scan_dir, expand} = require './discovery'

color_output = process.stdout.columns > 0

module.exports =
  scan_dir: scan_dir
  expand:   expand
  dep_tree: dep_tree
  commands:
    clean: clean
    build: build
    watch: watch
    dump:  (outputs, callback) ->
      console.log inspect outputs, false, 4, color_output
      callback()
