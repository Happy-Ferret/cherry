fs     = require 'fs'
_      = require 'underscore'
coffee = require 'coffee-script'
api    = require './api'
flow   = require './flow'
spawn  = require './spawn'

check_conditions = (candidates, callback) ->
  cherryfile_path = _.find candidates, fs.existsSync

  errors = []

  if not cherryfile_path
    errors.push "Need at least one of those files with recipes:\n\n  #{candidates.join '\n  '}\n"

  commands = (for name in process.argv[2..]
    fn = api.commands[name]
    if not fn
      errors.push "Command #{name} doesn't exist."
    fn)

  if commands.length is 0
    errors.push "No command given. Need at least one of those:\n\n  #{(_.keys api.commands).join '\n  '}\n"

  callback (errors.length and errors.join '\n'), [cherryfile_path, commands]

run = ([cherryfile_path, commands], callback) ->
  recipes = []
  recipe = (recipe) -> recipes.push recipe

  _.extend global, flow, {recipe: recipe, spawn: spawn}

  cherryfile_coffee = fs.readFileSync cherryfile_path, 'utf8'
  coffee.run cherryfile_coffee, filename: cherryfile_path

  go = flow api.scan_dir,
    (api.dep_tree.bind null, (api.expand recipes), {}),
    (commands.map (cmd) ->
      (outputs, callback) -> cmd outputs, (err) ->
        callback err, outputs)...

  go '.', callback

(flow check_conditions, run) [
  'Cherryfile'
  'cherry.coffee'
  'Cakefile'
], (err) ->
  if err
    console.error err.stack || err
