Things worth considering changing:

- deps of target should be watched even if first build fails
- add `remember`/`remind` to flow library for caching stuff in memory (or `remind` can be a part of `read`)
- add `filter` to flow library that takes a regexp, string (expanded by in_pattern) or a function
