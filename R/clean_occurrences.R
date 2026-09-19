#' Give the records short names, a year, and a sanity check
#'
#' Two jobs that always happen together. The Atlas column names are accurate and
#' long, so `decimalLongitude` becomes `lon` and you can read the rest of the
#' analysis. Then the records that cannot be right are removed.
#'
#' @section What gets removed, and why:
#' Missing dates and missing coordinates, because nothing downstream can use a
#' record without them.
#'
#' Records dated before `first_year`. Cane toads were released at Gordonvale in
#' 1935, so a cane toad recorded in 1770 is a data entry error. There are 41 of
#' them across the full WildNet extract, and left in they do not move the front
#' at all — they stretch the clock it is divided by, which halves the answer.
#'
#' Records outside the bounding box of Australia. There are 124 of them in the
#' museum records, mostly specimens carrying the coordinates of the institution
#' holding them rather than the place the animal was found.
#'
#' Both of those are a few dozen records in tens of thousands, and neither
#' announces itself. `range(occurrences$year)` finds the first one.
#'
#' @param occurrences A data frame from [read_occurrences()].
#' @param first_year The earliest year a record could legitimately have.
#'
#' @return A tibble with `lon`, `lat`, `date`, `year` and `decade`, and fewer
#'   rows than it was given.
clean_occurrences <- function(occurrences, first_year = 1935) {
  occurrences |>
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
    filter(
      !is.na(year),
      !is.na(lon),
      !is.na(lat),
      year >= first_year,
      between(lon, 112, 154),
      between(lat, -44, -9)
    )
}
