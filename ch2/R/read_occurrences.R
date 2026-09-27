#' Read cached occurrence records and give them workable names
#'
#' Reads one species' parquet file, shortens the Atlas column names, and derives
#' a `year` and a `decade` from the date. Nothing is removed: what arrives is
#' what the Atlas of Living Australia sent, warts and all, so you can see the
#' warts before deciding what to do about them. [clean_occurrences()] is the
#' deciding.
#'
#' @param path Path to a parquet file of occurrence records.
#'
#' @return A tibble with `lon`, `lat`, `date`, `year` and `decade`, one row per
#'   record.
read_occurrences <- function(path) {
  read_parquet(file = path) |>
    clean_names() |>
    rename(
      lat = decimal_latitude,
      lon = decimal_longitude,
      date = event_date
    ) |>
    mutate(
      year = year(date),
      decade = floor(year / 10) * 10,
      .after = date
    )
}
