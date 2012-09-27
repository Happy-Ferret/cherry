engine = require './engine'

start_dir = '.'

full_tree = (recipes) ->
  engine.get_outputs_deps engine.group_outputs_inputs recipes, engine.scan_dir start_dir

build = (recipes) ->
  engine.build full_tree recipes

dump = (recipes) ->
  console.log full_tree recipes

clean = (recipes) ->
  engine.clean engine.group_outputs_inputs recipes, engine.scan_dir start_dir

purify = (recipes) ->
  engine.purify recipes, engine.scan_dir start_dir

module.exports =
  build:  build
  dump:   dump
  clean:  clean
  purify: purify
