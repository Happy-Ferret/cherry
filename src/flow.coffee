fs = require 'fs'
_  = require 'underscore'

flow_next = (steps, final_step, final_callback, output_path) -> (err, data...) ->
  if err
    # console.error "Error while building #{output_path}", err.stack or err
    final_callback err, data...
  else if steps.length
    callback = flow_next steps[1..], final_step, final_callback, output_path
    try
      steps[0] callback, data...
    catch err
      callback err
  else if final_step
    final_step (flow_next [], null, final_callback), output_path, data...
  else
    final_callback null, data...

flow = (steps..., final_step) -> (final_callback, output_path, data...) ->
  (flow_next steps, final_step, final_callback, output_path) null, data...

do_all = (iterator) -> (callback, data...) ->
  results = []
  got = 0
  valid = true
  check = (i) -> (err, result) ->
    return if not valid
    if err
      callback err
      return
    results[i] = result
    got++
    if got is data.length
      callback null, results...
  for datum, i in data
    iterator (check i), datum

read_one = (encoding) -> (callback, input_path) ->
  fs.readFile input_path, encoding, callback

read = (encoding) -> do_all read_one encoding

save = (encoding) -> (callback, output_path, data) ->
  fs.writeFile output_path, data, encoding, callback

compile = (compiler, args...) -> (callback, sources...) ->
  results = []
  try
    results = (compiler src, args... for src in sources)
  catch err
    error = err
  finally
    callback error, results...

join = (glue = '\n') -> (callback, contents...) ->
  callback null, contents.join glue

take = (amount) -> (callback, data...) ->
  callback null, data[..amount]...

module.exports = _.extend flow,
  flow:    flow
  do_all:  do_all
  read:    read
  save:    save
  compile: compile
  join:    join
  take:    take
