# To run:
# Sys.setenv(TAR_PROJECT = "ch1")
# tar_make()
source(here::here("ch1/ch1-targets/packages.R"))
source(here::here("ch1/ch1-targets/functions.R"))

tar_assign({
  toad_path <- here("data/cane-toad-wildnet-to-2010.parquet") |> tar_file()

  toads_raw <- read_parquet(file = toad_path) |> tar_target()

  toads <- tidy_toads(toads_raw) |> tar_target()

  # Let's just look at qld
  qld <- ozmap_states |>
    filter(NAME == "Queensland") |>
    tar_target()

  # ---- find the front ---------------------------------------------------------
  # Find the most western toads per decade
  toad_west_front <- toads |>
    group_by(decade) |>
    # smallest lon == most westerly
    slice_min(lon, n = 1) |>
    ungroup() |>
    tar_target()

  toad_distance <- toad_west_front |>
    add_distance(lon = "lon", lat = "lat") |>
    tar_target()

  report <- tar_quarto(path = "ch1/ch1-targets/tar-ch-1.qmd")
})
