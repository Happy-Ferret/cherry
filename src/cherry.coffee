fs     = require 'fs'
_      = require 'underscore'
coffee = require 'coffee-script'
api    = require './api'
flow   = require './flow'
spawn  = require './spawn'

candidates = [
  'Cherryfile'
  'cherry.coffee'
  'Cakefile'
]

cherryfile_path = _.find candidates, fs.existsSync
command = api[process.argv[2]]

requirements = [
  [ command
    "Wrong command. Available commands:"
    _.keys api ]
  [ cherryfile_path
    "Need one of the following files with recipes:",
    candidates ]
]

met_requirements = true
for [req, message, alternatives] in requirements
  if not req
    console.error message
    if alternatives
      console.error "\n  #{alternatives.join '\n  '}\n"
    met_requirements = false

if not met_requirements then return 1

recipes = []
recipe = (recipe) -> recipes.push recipe

_.extend global, flow, {recipe: recipe, spawn: spawn}

cherryfile_coffee = fs.readFileSync cherryfile_path, 'utf8'
coffee.run cherryfile_coffee, filename: cherryfile_path

command recipes
