# Put A Cherry On The Cake

General-purpose build system.
Features:

- Simple recipe syntax
- Automatic files tree discovery
- Simple wildcard system for input and output file paths
- Reruns tasks when input files changes
- Doesn't impose workflow nor libraries nor directory structure
- Includes simplified asynchronous processing library `flow`

Rationale:

- Preferred use of JavaScript libraries rather than starting new processes
- You still can use anything you want to process your files
- More portable than make & shell-based build system (all dependencies other than node.js contained in your project)
- Reusing existing simple build framework of `cake`
- Extensive use of CoffeeScript although there's no reason to not use it in JavaScript

Nomenclature:

- Recipe = instruction how to build a target from deps
- Target = output file matching `out` field from a recipe
- Inputs = files matching `in` field from a recipe
- Deps   = inputs and files returned by an optional `dep` function of a recipe
- Run    = function responsible of translating deps to target
