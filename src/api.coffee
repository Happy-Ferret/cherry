engine = require './engine'

start_dir = '.'

with_full_tree = (action) -> (recipes) ->
  action engine.dep_tree recipes, engine.scan_dir start_dir

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
