# Toad Analysis

This is an example targets repository for learning targets, as part of my course: [A Gentle Introduction to {targets} and {geotargets}](https://github.com/njtierney/gentletargets)

It is currently still being developed, but the rough idea is to have one file per chapter, eventually working towards building a full targets pipeline.

- `01-flat-script.R`: Ch1, Everything in one file. This is what they are given.
- `02-functions.R`: Ch2, same as Ch1, as named calls. Bodies move to `R/`
-  Ch 3 Debugging changes, no code.
- `04-first-pipeline.R`: Ch3, The same calls, wrapped in `tar_assign()`
- `05-deeper.R`: Ch5, File targets, a report, validation.
- `06-branching.R`: Ch6, Twelve species. Branching, then a controller.
- `07-geotargets.R`: Ch7, Rasters arrive. `tar_terra_rast()`
- `08-production.R`: Ch8, What it looks like organised, with `packages.R` and section comments.

Some general conventions to follow:

- verbs in `R/`
- nouns in the plan
- one call per target
- piped `|> tar_target()`
- files as `format = "file"`
- writers return paths
