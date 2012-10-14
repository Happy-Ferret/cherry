fs = require 'fs'
_  = require 'underscore'

flow_next = (output, steps, final_callback) -> (err, data) ->
  if err
    final_callback err
    return

  if steps.length > 0
    try
      steps[0].call output, data, (flow_next output, steps[1..], final_callback)
    catch ex
      final_callback ex
  else
    final_callback null, data

flow = (steps...) -> (data, final_callback) ->
  (flow_next this, steps, final_callback) null, data

do_all = (iterator) -> (data, callback) ->
  if data.length < 1
    callback null, []
    return

  results = []
  got = 0
  valid = true

  check = (i) -> (err, result) ->
    return if not valid
    if err
      valid = false
      callback err
      return
    results[i] = result
    got++
    if got is data.length
      callback null, results

  for datum, i in data
    try
      iterator.call this, datum, (check i)
    catch e
      (check i) e

storage = {}

read_one = (encoding) -> (input_path, callback) ->
  if _.has storage, input_path
    callback null, storage[input_path]
  else
    fs.readFile input_path, encoding, callback

read = (encoding) -> do_all read_one encoding

save = (encoding) -> (data, callback) ->
  fs.writeFile this.path, data[0], encoding, callback

remember = (data, callback) ->
  storage[this.path] = data[0]
  callback null, data

compile_one = (compiler, args...) -> (src, callback) ->
  callback null, (compiler.call this, src, args...)

compile = (compiler, args...) -> do_all (compile_one.call this, compiler, args...)

join = (glue = '\n') -> (data, callback) ->
  callback null, data.join glue

take = (amount) -> (data, callback) ->
  callback null, data[..amount]

module.exports = _.extend flow,
  flow:    flow
  do_all:  do_all
  read:    read
  save:    save
  compile: compile
  join:    join
  take:    take
