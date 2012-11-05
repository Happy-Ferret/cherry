{build}            = require './build'
watch              = require './watch'
{dump} = dep_tree  = require './dep_tree'
{clean, purify}    = require './clean'
{scan_dir, expand} = require './discovery'

module.exports =
  scan_dir: scan_dir
  expand:   expand
  dep_tree: dep_tree
  commands:
    clean: clean
    build: build
    watch: watch
    dump:  dep_tree.dump
