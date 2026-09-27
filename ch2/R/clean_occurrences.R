#' Remove records that cannot be right
#'
#' Occurrence records arrive with dates and coordinates that are impossible.
#' This removes them. It does nothing else, so the difference between the number
#' you get before calling it and the number you get after is entirely the work
#' of the records it dropped.
#'
#' @section What gets removed, and why:
#' Missing dates and missing coordinates, because nothing downstream can use a
#' record without them.
#'
#' Records dated before `first_year`. Cane toads were released at Gordonvale in
#' 1935, so a cane toad recorded in 1770 is a data entry error. Left in, these
#' do not move the front — they stretch the span of years the distance is
#' divided by, which halves the answer.
#'
#' Records outside the bounding box of Australia. Most are museum specimens
#' carrying the coordinates of the institution holding them rather than the
#' place the animal was found. The front is the westernmost record, so one toad
#' at longitude -170 puts it two thirds of the way around the world.
#'
#' Both are a few dozen records in tens of thousands, and neither announces
#' itself. `range(occurrences$year)` finds the first, and a map finds the second.
#'
#' @param occurrences A data frame from [read_occurrences()].
#' @param first_year The earliest year a record could legitimately have.
#'
#' @return `occurrences`, with fewer rows. Column structure is unchanged.
clean_occurrences <- function(occurrences, first_year = 1935) {
  occurrences |>
    filter(
      !is.na(year),
      !is.na(lon),
      !is.na(lat),
      year >= first_year,
      between(lon, 112, 154),
      between(lat, -44, -9)
    )
}
