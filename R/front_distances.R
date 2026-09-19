#' How far the front moved between decades
#'
#' `geodist()` walks down the rows and measures each step across the surface of
#' the earth, in metres. `sequential = TRUE` is what makes it row-to-row rather
#' than every pair against every other pair. There is no step into the first
#' decade, so the first `km_moved` is `NA`.
#'
#' This measures how far the edge travelled in any direction, not how far west
#' it went. The edge wanders north and south as well, and that wandering counts
#' towards the total. Holding latitude fixed measures the westward part on its
#' own, and the difference reaches a factor of two in some decades.
#'
#' @param front A tibble from [front_by_decade()].
#'
#' @return `front`, with `km_moved` and `km_per_year` added.
front_distances <- function(front) {
  front |>
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
}
