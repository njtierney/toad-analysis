# CHAPTER 2 — the same work, as named calls
#
# Written top-down: these calls were sketched before any of the bodies existed.
# Verbs live in R/, nouns live here.
#
# Compare it against the section headings in 01-flat-script.R. Read the records.
# Clean the records. Find the front. Measure the speed. The headings were the
# function names all along.
#
# R/
#   read_occurrences.R   clean_occurrences.R   front_by_decade.R
#   front_distances.R    front_speed.R         plot_front.R

library(arrow)
library(dplyr)
library(fs)
library(geodist)
library(ggplot2)
library(janitor)
library(lubridate)
library(readr)

lapply(dir_ls("R", glob = "*.R"), source)

toad_path <- "data/cane-toad-wildnet-to-1999.parquet"

occurrences_raw <- read_occurrences(toad_path)

occurrences_clean <- clean_occurrences(occurrences_raw)

toad_front <- front_by_decade(occurrences_clean)

front_distance <- front_distances(toad_front)

toad_speed <- front_speed(front_distance)

toad_speed

plot_front(front_distance)

write_csv(front_distance, "output/toad-front.csv")
