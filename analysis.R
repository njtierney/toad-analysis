# Where were the cane toads, where are they now, and where are they going?
#
# This computes and saves. Nothing is printed and nothing is plotted, because
# neither of those is something you can pick up again later. `toad-report.qmd`
# reads what this writes and turns it into something you can send to someone.
#
# The boss has sent us the WildNet records up to 1999. When more arrives, change
# the filename. There are three windows and five more sources:
#
#   cane-toad-wildnet-to-1999.parquet
#   cane-toad-wildnet-to-2010.parquet
#   cane-toad-wildnet.parquet
#   cane-toad-all.parquet

toad_path <- "data/cane-toad-wildnet-to-1999.parquet"

library(arrow)
library(dplyr)
library(fs)
library(geodist)
library(janitor)
library(lubridate)
library(readr)

lapply(dir_ls("R", glob = "*.R"), source)

dir_create("output")

occurrences_raw <- read_occurrences(toad_path)

occurrences_clean <- clean_occurrences(occurrences_raw)

toad_front <- front_by_decade(occurrences_clean)

front_distance <- front_distances(toad_front)

toad_summary <- tibble(
  source = toad_path,
  records = nrow(occurrences_raw),
  records_clean = nrow(occurrences_clean),
  km_per_year = front_speed(front_distance)
)

write_csv(front_distance, "output/toad-front.csv")
write_csv(toad_summary, "output/toad-summary.csv")
