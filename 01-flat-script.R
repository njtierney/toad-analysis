# Where were the cane toads, and how fast are they moving?
#
# In 1935 about 2,400 cane toads were released near Gordonvale in far north
# Queensland, to eat a beetle that was damaging the sugar cane. They did not eat
# the beetle. They spread instead, west across the top of the country, and they
# are still going.
#
# The data is occurrence records from the Atlas of Living Australia. One row is
# one report of one species, at one place, on one date. It is not a survey and
# it is not a count. Nobody went out and measured how many toads there are.
# Someone saw a toad, wrote down where and when, and that became a row.
#
# The boss has sent Queensland's WildNet records up to 1999. WildNet is the
# Queensland government's wildlife database, and it holds the origin: the oldest
# cane toad records in the country.
#
# Everything above the EXTENSIONS line at the bottom is the session. Below it is
# for afterwards.

library(arrow)
library(geodist)
library(here)
library(janitor)
library(ozmaps)
library(sf)
library(tidyverse)
library(visdat)
library(conflicted)
conflicts_prefer(dplyr::filter)

# ---- read the records -------------------------------------------------------
toad_path <- here("data/cane-toad-wildnet-to-1999.parquet")

toads_raw <- read_parquet(file = toad_path) |>
  clean_names()

toads_raw

# ---- clean the records ------------------------------------------------------
# Short names for the two columns we use most, a year to group by, and a decade
# to group by when a year is too fine.
toads <- toads_raw |>
  rename(
    lat = decimal_latitude,
    lon = decimal_longitude,
    date = event_date
  ) |>
  mutate(
    year = year(date),
    decade = floor(year / 10) * 10,
    .after = date
  ) |>
  filter(!is.na(year), !is.na(lat), !is.na(lon))

toads

# How many did that drop?
nrow(toads_raw) - nrow(toads)

# ---- what have we got? ------------------------------------------------------
glimpse(toads)
vis_dat(toads)

# Who collected these?
toads |>
  count(data_resource_name, sort = TRUE)

# How were they recorded? A quarter are museum specimens or machine detections
# rather than somebody seeing a live animal.
toads |>
  count(basis_of_record, sort = TRUE)

# How precise are the coordinates? Median 1.3 km, but the worst is 100 km.
summary(toads$coordinate_uncertainty_in_meters)

# What years does this cover? Check the ends, not the middle. A date that cannot
# be right is the easiest error to find and the easiest one to miss.
range(toads$year)

# ---- how many toads, over time? ---------------------------------------------
# Worth knowing before we read anything into a trend: this is how often somebody
# wrote a toad down, not how many toads there were.
toads |>
  count(decade)

ggplot(toads, aes(x = decade)) +
  geom_bar() +
  scale_x_continuous(breaks = scales::breaks_width(width = 10)) +
  labs(x = NULL, y = "Records")

# ---- where are they? --------------------------------------------------------
# ozmaps carries the state boundaries. "Other Territories" is Christmas Island
# and the Cocos Islands, which sit a long way offshore and squash the map.
australia <- ozmap_states |>
  filter(NAME != "Other Territories")

ggplot() +
  geom_sf(data = australia, fill = "grey95", colour = "grey70") +
  geom_point(data = toads, aes(x = lon, y = lat), alpha = 0.3) +
  coord_sf(xlim = c(112, 154), ylim = c(-44, -9))

# One panel per decade, so you can watch it move.
ggplot() +
  geom_sf(data = australia, fill = "grey95", colour = "grey70") +
  geom_point(data = toads, aes(x = lon, y = lat), alpha = 0.3) +
  coord_sf(xlim = c(112, 154), ylim = c(-44, -9)) +
  facet_wrap(~decade) +
  theme_void()

# ---- find the front ---------------------------------------------------------
# The toads also went south, down the east coast into New South Wales. That is a
# different front with a different story, so the northern one gets measured on
# its own.
northern_limit <- -20

# The front is an edge, not an average. Most records sit well behind it, in
# places the toads reached years ago, so an average tells you where people
# looked rather than where the toads got to.
#
# So: the ten westernmost records in each decade, and the middle of those ten.
# Ten rather than the single furthest, because then one bad coordinate cannot be
# the whole answer. Ten every decade, whether the decade has forty records or
# fourteen thousand.
n_front <- 10

toad_front <- toads |>
  filter(lat > northern_limit) |>
  group_by(decade) |>
  slice_min(lon, n = n_front) |>
  summarise(lon = mean(lon), lat = mean(lat)) |>
  ungroup()

toad_front

# There it is, on the map.
ggplot() +
  geom_sf(data = australia, fill = "grey95", colour = "grey70") +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    colour = "grey80",
    size = 0.4
  ) +
  geom_path(data = toad_front, aes(x = lon, y = lat), colour = "#D95F02") +
  geom_point(data = toad_front, aes(x = lon, y = lat), colour = "#D95F02") +
  coord_sf(xlim = c(112, 154), ylim = c(-44, -9))

# ---- how fast is it moving? -------------------------------------------------
# How far is it from one decade's edge to the next?
#
# geodist() walks down the rows and measures each step across the surface of the
# earth, in metres. `sequential = TRUE` is what makes it row-to-row rather than
# every-pair. There is no step into the first decade, hence the NA.
toad_speed <- toad_front |>
  mutate(
    km_moved = c(
      NA,
      geodist(
        x = cbind(x = lon, y = lat),
        sequential = TRUE,
        measure = "geodesic"
      )
    ) /
      1000,
    km_per_year = km_moved / 10
  )

toad_speed

ggplot(toad_speed, aes(x = decade, y = km_per_year)) +
  geom_col() +
  scale_x_continuous(breaks = scales::breaks_width(width = 10)) +
  labs(x = NULL, y = "km per year")

# One number, if somebody needs one: all the ground the front covered, divided
# by how long it took.
sum(toad_speed$km_moved, na.rm = TRUE) /
  (max(toad_speed$decade) - min(toad_speed$decade))

# ---- write it down ----------------------------------------------------------
write_csv(toad_speed, here("output/toad-front.csv"))

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

nt <- nt_raw |>
  rename(
    lat = decimal_latitude,
    lon = decimal_longitude,
    date = event_date
  ) |>
  mutate(
    year = year(date),
    decade = floor(year / 10) * 10,
    .after = date
  ) |>
  filter(!is.na(year), !is.na(lat), !is.na(lon))

nrow(nt_raw) - nrow(nt)

range(nt$year)

nt_front <- nt |>
  filter(lat > northern_limit) |>
  group_by(decade) |>
  slice_min(lon, n = n_front) |>
  summarise(lon = mean(lon), lat = mean(lat)) |>
  ungroup()

nt_speed <- nt_front |>
  mutate(
    km_moved = c(
      NA,
      geodist(
        x = cbind(x = lon, y = lat),
        sequential = TRUE,
        measure = "geodesic"
      )
    ) /
      1000,
    km_per_year = km_moved / 10
  )

median(nt_speed$km_per_year, na.rm = TRUE)

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
# =============================================================================
# Not part of the session. Each one is a thing you might reasonably want next,
# and each is a small piece of work on its own.

# ---- 1. animate it ----------------------------------------------------------
# Needs `library(gganimate)`. One frame per five-year period, with everything
# earlier left behind in grey, so what moves is the front rather than the dots.
#
# `transition_length = 0` means records appear where they are and stay put. The
# default tweens between frames, which makes the points slide around the map
# looking for their next position.
#
# How long each period sits on screen is set by `nframes`, not `state_length` —
# that is a ratio against `transition_length`, which is zero here.

# toads_period <- toads |>
#   mutate(period = floor(year / 5) * 5)
#
# march <- ggplot() +
#   geom_sf(data = australia, fill = "grey95", colour = "grey70") +
#   geom_point(data = toads_period, aes(x = lon, y = lat), colour = "#1B9E77") +
#   coord_sf(xlim = c(112, 154), ylim = c(-44, -9)) +
#   theme_void() +
#   gganimate::transition_states(period, transition_length = 0) +
#   gganimate::shadow_mark(past = TRUE, colour = "grey70")
#
# gganimate::animate(march, nframes = n_distinct(toads_period$period) * 4, fps = 4)

# ---- 2. how much of that movement was actually westward? --------------------
# `km_moved` is how far the edge travelled, in any direction. The edge wanders
# north and south as well, and that wandering counts towards the total. Holding
# latitude fixed measures the westward part on its own, and on the full dataset
# it turns out the difference reaches a factor of two in some decades.
#
# Replace the `cbind(x = lon, y = lat)` above with `cbind(x = lon, y = -15)`.

# ---- 3. the southern front --------------------------------------------------
# `northern_limit` throws away every record south of 20 degrees, which is a
# whole second invasion down the east coast. Run the same six steps on
# `filter(lon > 148)`, taking `slice_min(lat, n = 10)` instead of `lon`.
#
# The two fronts do opposite things. The western one speeds up, the southern one
# runs into the cold and stops.

# ---- 4. does ten matter? ----------------------------------------------------
# `n_front <- 10` was a choice. Try 5, 25 and 50, and see whether the answer
# changes. If it does, the number was doing the work rather than the data.

# ---- 5. how far beyond the known range is each new record? ------------------
# For every record in a decade, the distance to the nearest record from any
# earlier decade. Most land on top of somewhere already known, so the median is
# small. The far tail is either a toad that hitchhiked in freight, which they do,
# or a coordinate that is wrong, and you cannot tell which without looking.
#
# `geodist_min()` returns the INDEX of the nearest point, not the distance, so
# it takes two calls. On the full dataset it takes about five minutes.
