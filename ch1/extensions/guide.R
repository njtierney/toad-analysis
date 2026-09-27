# ---- more years arrive ------------------------------------------------------
# The boss sends the records up to 2010, and then all of them. Change
# `toad_path` at the top and run the whole thing again. Twice.
#
#   cane-toad-wildnet-to-2010.parquet
#   cane-toad-wildnet.parquet
#
# The first of those changes almost nothing: 19.6 km a year becomes 19.2.
#
# The second one halves it. 8.0 km a year, from the same toads, moving the same
# distance. Nothing errored and the plots all drew.
#
# Go back and look at `range(toads$year)`. Twelve records out of 2,302 are dated
# 1770, which is eighteen years before the First Fleet and 165 years before
# anyone released a cane toad. They do not move the front — they stretch the
# clock. Drop them and the answer is 21.1.
#
# Twelve records in two thousand. Nothing about the output said so.

# ---- so where else is there data? -------------------------------------------
toads_all <- read_parquet(file = here("data/cane-toad-all.parquet")) |>
  clean_names()

toads_all |>
  count(data_resource_name, sort = TRUE) |>
  head(8)

# Five more, and each is a different part of the invasion.
#
#   cane-toad-fauna-atlas-nt.parquet  the Territory, the middle passage
#   cane-toad-awc.parquet             the front, and the only one reaching WA
#   cane-toad-nsw-bionet.parquet      the southern tail
#   cane-toad-inaturalist.parquet     citizen science, for contrast
#   cane-toad-museums.parquet         OZCAM specimens, where the oddities are
#
# All of them together gives 43.3 km a year, which is too fast. This time the
# problem is coordinates rather than dates: 85 records out of 31,216 sit outside
# Australia. Keep only what is on the continent and it settles at 29.6.
#
# So the answer was wrong twice, in opposite directions, and both times it was a
# few dozen records in tens of thousands.

# ---- do it all again, for the Territory -------------------------------------
nt_raw <- read_parquet(file = here("data/cane-toad-fauna-atlas-nt.parquet")) |>
  clean_names()

# And now four more times, for AWC, NSW BioNet, iNaturalist and the museums.
#
# By this point you have run the same six steps eight times: three time windows
# and five sources. Every one was a filename change and a re-run, and the only
# thing telling you which results came from which file is your memory.
#
# Look back at the section headings. Read the records. Clean the records. Find
# the front. Measure the speed. You have written each of those twice already and
# there are six to go.
#
# That is what functions are for, and it is what the next session does.

# =============================================================================
# EXTENSIONS
# Animations
# Southward movement
# average west/south movement
