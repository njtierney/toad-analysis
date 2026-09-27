# Sections marked `# ---- label ----` are read into the book with
# knitr::read_chunk(), so why-pipelines.qmd shows this file's own code. Renaming
# a label empties that chunk in the book.

# ---- read ----
# data read in
library(here)
toad_path <- here("data/cane-toad-wildnet-to-2010.parquet")

library(arrow)
toads_raw <- read_parquet(file = toad_path)

toads_raw

# ---- view ----
View(toads_raw)

# ---- names ----
toads_raw |> names()

library(janitor)
toads_raw |>
  clean_names() |>
  names()

# ---- tidy ----
library(tidyverse)
toads <- toads_raw |>
  clean_names() |>
  rename(
    lat = decimal_latitude,
    lon = decimal_longitude,
    date = event_date,
    coord_var_m = coordinate_uncertainty_in_meters,
    resource_name = data_resource_name
  ) |>
  mutate(
    year = year(date),
    decade = floor(year / 10) * 10,
    .after = date
  )

toads

# ---- look ----
# EDA
glimpse(toads)
library(visdat)
vis_dat(toads)

# What years does this cover?
range(toads$year)

# ---- over-time ----
toads |>
  count(year)

ggplot(toads, aes(x = year)) +
  geom_bar()

toads |>
  count(decade)

ggplot(toads, aes(x = decade)) +
  geom_bar()

# ---- map-first-look ----
# Maps
ggplot(toads, aes(x = lon, y = lat)) +
  geom_point()
# Looks a bit like queensland?

library(ozmaps)
library(sf)
gg_oz <- ggplot() + geom_sf(data = ozmap_states)

gg_oz

gg_oz +
  geom_point(data = toads, aes(x = lon, y = lat))

# What's in ozmap_states
ozmap_states

# ---- map-qld ----
# Let's just look at qld
qld <- ozmap_states |>
  filter(NAME == "Queensland")

gg_qld <- ggplot() + geom_sf(data = qld)
gg_qld

gg_qld + geom_point(data = toads, aes(x = lon, y = lat), alpha = 0.2)

# One panel per decade
gg_qld +
  geom_point(data = toads, aes(x = lon, y = lat), alpha = 0.2) +
  facet_wrap(~decade, nrow = 2)

# ---- front ----
# Find the most western toads per decade
toad_west_front <- toads |>
  group_by(decade) |>
  # smallest lon == most westerly
  slice_min(lon, n = 1) |>
  ungroup()

# ---- south-front ----
toad_south_front <- toads |>
  group_by(decade) |>
  # largest lat == most southern
  slice_min(lat, n = 1) |>
  ungroup()

toad_west_front
toad_south_front

# ---- front-map ----
gg_qld +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    alpha = 0.2
  ) +
  geom_point(
    data = toad_west_front,
    aes(x = lon, y = lat),
    colour = "orange"
  )

gg_qld +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    alpha = 0.2
  ) +
  geom_point(
    data = toad_west_front,
    aes(x = lon, y = lat),
    colour = "orange"
  ) +
  geom_path(
    data = toad_west_front,
    aes(x = lon, y = lat),
    colour = "orange"
  )

# ---- distance ----
# How far is it from one decade's edge to the next?

library(geodist)
# use {geodist} to calculate the distance
# it takes a matrix of inputs:
dist_mat <- cbind(lon = toad_west_front$lon, lat = toad_west_front$lat)

dist_mat

# geodist() walks down the rows and measures each step across the surface of the
# earth, in metres. `sequential = TRUE` is what makes it row-to-row rather than
# every-pair. There is no step into the first decade, so we pad it out:
distances_m <- dist_mat |>
  geodist(measure = "geodesic", sequential = TRUE, pad = TRUE)

distances_m

toad_speed <- toad_west_front |>
  mutate(
    distance_km = distances_m / 1000,
    .after = scientific_name
  )

toad_speed

ggplot(toad_speed, aes(x = decade, y = distance_km)) +
  geom_col()

# ---- plan ----
## Natural progressions - these should be in the book

## Email them this data, send them this script, get them to replicate
## Now, as them to convert that to a quarto document
# Can you also tidy this up to follow some standards
# libraries at the top
# Remove unrequired iterations in the code
## Now, ask them to save that data out to CSV
## discussion of side effects
## is rendering a document to save data a good idea?
## Now, email them some more current data, ask them to replace the data
## run the document again
## Once they do that: Stop

## Now, show them this as a targets document

## Future work

## run as a single script
## Turn into functions
## Encounter issue the {conflicted} solves
## convert into targets
## debugging
## using tar_assign
## using tar_quarto
