engine   = require './engine'
dep_tree = require './dep_tree'

start_dir = '.'

with_full_tree = (action) -> (recipes) ->
  dep_tree action, (engine.translate_all_patterns recipes), engine.scan_dir start_dir

build = with_full_tree engine.build
dump  = with_full_tree console.log
clean = with_full_tree engine.clean

purify = (recipes) ->
  engine.purify recipes, engine.scan_dir start_dir

module.exports =
  build:  build
  dump:   dump
  clean:  clean
  purify: purify
