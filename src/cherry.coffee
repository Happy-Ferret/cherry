fs     = require 'fs'
_      = require 'underscore'
coffee = require 'coffee-script'
api    = require './api'
flow   = require './flow'

command = api[process.argv[2]]

if not command
  console.error "Wrong command. Available commands:\n\n  #{(_.keys api).join '\n  '}\n"
  process.exit 1

recipes = []

recipe = (recipe) -> recipes.push recipe

candidates = [
  'Cherryfile'
  'cherry.coffee'
  'Cakefile'
]

_.extend global, flow, recipe: recipe

cherryfile_path = _.find candidates, fs.existsSync

if not cherryfile_path
  console.error "Need one of the following files with recipes: #{candidates.join ', '}"
  process.exit 1

cherryfile_coffee = fs.readFileSync cherryfile_path, 'utf8'

coffee.run cherryfile_coffee, filename: cherryfile_path

command recipes
