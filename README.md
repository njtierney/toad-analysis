# Toad Analysis

This is an example targets repository for learning targets, as part of my course: [A Gentle Introduction to {targets} and {geotargets}](https://github.com/njtierney/gentletargets)

It is currently still being developed. There is one folder per chapter, and each one is the same analysis at a later stage, working towards a full targets pipeline. The data is shared, in `data/`.

- `ch1/01-flat-script.R`: everything in one file. `ch1/extensions/` has things you might want to try next.
- `ch2/`: the same analysis as named calls. `02-functions.R` and `analysis.R` call the functions in `ch2/R/`, and `toad-report.qmd` reads what `analysis.R` writes.
- Chapter 3 is debugging, and changes no code.
- `ch4/04-first-pipeline.R`: the same calls, wrapped in `tar_assign()`.
- `ch5/05-deeper.R`: file targets, a report, validation.
- `ch6/06-branching.R`: branching, then a controller.
- `ch7/07-geotargets.R`: rasters arrive. `tar_terra_rast()`.
- `ch8/08-production.R`: what it looks like organised, with `packages.R` and section comments.

Chapters 4 to 8 are sketches, and do not run yet.

Some general conventions to follow:

- verbs in `R/`
- nouns in the plan
- one call per target
- piped `|> tar_target()`
- files as `format = "file"`
- writers return paths
