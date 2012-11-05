# Cherry

Cherry is a general-purpose <del>build</del> cook tool. It provides a CoffeeScript-based DSL for defining *recipes*.

Cherry takes a file (a `Cherryfile`, `Cakefile` or `cherry.coffee`) with recipes and turns input files in current directory to output files.

Main features:

- a friendly CoffeeScript-based DSL
- allows to write very custom build flows while being terse and declarative
- automatic dependencies resolution
- watch mode
- pattern matching between input and output paths
- asynchronous operation (while supporting synchronous operation as well)
- flow library that eases composition of build steps

## Installation

Install from npm with `-g` switch to put it in the `$PATH`.

```sh
npm install -g cherry
```

## Usage

Supported commands for `cherry` are listed when none is given.

```
PS> cherry
No command given. Need at least one of those:

  clean         Deletes all targets
  build         Builds all targets
  watch         Watches all inputs and rebuilds outdated targets
  dump          Print the dependency tree

```

Commands can be chained in any combination, for example `cherry clean build watch`. Mind that `watch` is supposed to be always the last one because it never ends (only when the process is killed by Ctrl+C).

## Recipes

A recipe looks like this:

```coffee
recipe
  in:  'src/*.coffee'
  out: 'lib/*.js'
  run: (flow (read 'utf8'), (compile coffee.compile), (save 'utf8'))
```

A recipe have three mandatory parts: `in`, `out` and `run` fields.

### `in` field

`in` it's a pattern of input files paths. Current directory is scanned for files that matches this pattern. `*` marks a wild card group.

### `out` field

`out` tells what will be produced (a **target**) from matched input file(s). It can contain wild card groups as well. Wild card groups are matched against corresponding groups in `in` pattern in a manner similar to `replace` method of strings, in the upper example file `src/cherry.coffee` will produce `lib/cherry.js` file.

A shortage of groups in output pattern indicates a will to produce one target from many files. For example this recipe will make `app.js` of many `*.coffee` files.

```coffee
recipe
  in:  'src/*.coffee'
  out: 'app.js'
  run: (flow (read 'utf8'), (compile coffee.compile), (join '\n'), (save 'utf8'))
```

The rule here is that all input paths that matches the same target are grouped as that target's dependencies. All of them will be passed to function given at `run` field. You can a little more crazy things like this (`run` field as above):

```coffee
recipe
  in:  'src/*/*.coffee'
  out: 'src/*.js'
```

This will produce one `*.js` file for each subdirs of `src` dir. (Where the name of file before `.js` is name of that dir.)

### `run` field & `run` interface

`run` field is a function that will produce a result for a recipe. It is once called for every target and have to accept following arguments:

```coffee
run: (input_paths, callback) ->
```

`input_paths` is an array of all paths of all dependencies for current target. `callback` is a function of one optional argument `err` that needs to be called after completion of building the target. `err` needs to be an error information and only passed on failure.

Any exceptions thrown by `run` function will be treated the same as passing an error to `callback`. (So catching exception inside of `run` is not necessary).

Using callback instead of return value enables asynchronous operation which is much appreciated (allows interleaving building of multiple targets).

`run` function is called with `this` field set to a clone of a target object. Each target (a matched output path) has one object of that kind and is composed of the same fields that are printed by `cherry dump`:

- `path` -- matched target's output path
- `recipe` -- recipe for that target
- `deps` -- array of dependencies paths
- `nexts` -- array of target paths that depend on this one
- `awaiting` -- array of dependencies that need to be build before this one can start (it's actually empty when `run` is called)

`run` function is supposed not to change any of these fields but can add new.

For further reference, the arguments and the behaviour mentioned here are called the "`run` interface".

### `dep` field
### `and` field

## Interdependencies & Caching

Cherry manages interdependencies automatically. If any target depends on any other, then that dependency will be built first. This works also in watch mode: rebuilding a target triggers rebuilding of all others dependent on it.

Actually saving intermediate targets to disk is not necessary. Successful build of a target is not marked when file is saved but when callback given to `run` is called. You can cache result in memory and retrieve it later without disk operation. (This can speed up things significantly but also increase memory consumption tremendously so do it with care.)

Caching makes sense even more on watch mode. If you only use `cherry build` then all unsaved targets will be built causing a rebuild of all targets that depend on them.

## Flow Library

Flow is a library of functions that are meant to ease asynchronous processing of files that take many steps to complete. Each of them either *is* a function that complies with `run` function interface or *returns* one.

In the Flow library this interface is a little enhanced in that callbacks additionally to `err` receive also `data` argument.

Two most significant functions are `flow` and `do_all`. First allows to queue functions and call them in order while the second calls one function across an array of data simultaneously and collect results to new array.

### `flow` function

```coffee
flow = (steps...) -> (data, final_callback) ->
```

Function returned by `flow` executes all `steps` in order while passing data between them. Each step receives data from previous step and is required to pass (after `err` argument) new data to the callback given to it. (Steps have to be compatible with the `run` interface.)

First step is called with `data` passed to the resulting function. `final_callback` is called with `data` (after `err` argument) that was returned (passed to it's callback) by the last step.

### `do_all` function

```coffee
do_all = (iterator) -> (data, callback) ->
```

Returned function will invoke the `iterator` (complying with `run` interface) once for every element of `data` array, collect all results to an array an invoke `callback` with this array.

Indexes of input data are kept in output data arrangement.

### `read` function

```coffee
read = (encoding) -> (input_paths, callback) ->
```

Returned function reads all input files using optional `encoding`. If no encoding is given then `Buffer` objects are created instead of strings.

If given path was saved using `remember` function then remembered value is used instead of reading from file system.

### `save` function

```coffee
save = (encoding) -> (data, callback) ->
```

Returned function saves the first element of `data` to path pointed in `this.path`. To save all elements of `data` use `join` function.

### `remember` function

```coffee
remember = (data, callback) ->
```

Remembers `data[0]` in memory using path from `this.path`. Further reads using `read` on that path will retrieve the remembered value. The value can be any object.

### `join` function

```coffee
join = (glue = '\n') -> (data, callback) ->
```

Returned function joins all elements of `data` with glue as in `data.join(glue)`.

### `compile` function

```coffee
compile = (compiler, args...) -> (sources, callback) ->
```

Returns a wrapper for a synchronous compiler. For each element of `sources` compiler will be called with `source, args...` arguments. Returned values are in an array to next step.

### `take` function

```coffee
take = (amount) -> (data, callback) ->
```

Returned function limits the number of elements in `data` to `amount` of elements.

### `filter` function

```coffee
filter = (pattern) -> (data, callback) ->
```

Returned function filters elements of `data` using `pattern`. The `pattern` can be a one-param function returning a bool, a RegExp or a string. If it's a string then it's works like the `in` field patterns of recipes.

## Spawning Processes

For spawning auxiliary processes you can use the standard node-wise method or the `spawn` function.

```coffee
spawn = (command, args, callback) ->
```

`command` is the system command to invoke, `args` is an array of arguments and `callback` takes following arguments:

```coffee
(code, stdout, stderr)
```

`code` is the exit code returned by application, `stdout` is a string with all stdout output from application and `stderr` is all stderr output from application.

For convenience there's the `spawn.default` handler that wraps given `callback` and returns a function that will print the stdout invoke this callback with an error message from stderr if `code` is different than `0`.

```coffee
spawn.default = (callback) -> (code, stdout, stderr) ->
```

## Licence

MIT, see the `COPYING` file.
