#' Find the western edge of the invasion, by decade
#'
#' The front is an edge, not an average. Most records sit well behind it, in
#' places the toads reached years ago, so an average tells you where people
#' looked rather than where the toads got to.
#'
#' This takes the `n_front` westernmost records in each decade and returns the
#' middle of those. Ten records rather than the single furthest one, so that a
#' single bad coordinate cannot be the whole answer. A fixed count rather than a
#' percentage, because the decades are not comparable in size: the 1950s hold
#' 29 records and the 2020s hold over fourteen thousand, so "the westernmost 5%"
#' would mean one record in one decade and seven hundred in another.
#'
#' @param occurrences A cleaned data frame from [clean_occurrences()].
#' @param north_of Latitude above which records count. The toads also spread
#'   south, down the east coast into New South Wales, which is a different front
#'   with a different story.
#' @param n_front How many of the westernmost records define the edge.
#'
#' @return A tibble, one row per decade, with the `lon` and `lat` of the edge.
front_by_decade <- function(occurrences, north_of = -20, n_front = 10) {
  occurrences |>
    filter(!is.na(lon), !is.na(lat), !is.na(decade)) |>
    filter(lat > north_of) |>
    group_by(decade) |>
    slice_min(lon, n = n_front) |>
    summarise(lon = mean(lon), lat = mean(lat)) |>
    ungroup()
}
