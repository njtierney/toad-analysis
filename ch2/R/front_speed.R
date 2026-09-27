#' One number for how fast the front moved
#'
#' All the ground the front covered, divided by how long it took. Separate from
#' [front_distances()] on purpose: the per-decade distances are worth keeping
#' and looking at, and this throws all of them away to get a single number. Two
#' different jobs, so two functions.
#'
#' The per-decade numbers are the more honest answer. The invasion accelerated,
#' so one average rate describes none of the decades well.
#'
#' @param front A tibble from [front_distances()].
#'
#' @return One number, kilometres per year.
front_speed <- function(front) {
  total_km <- sum(front$km_moved, na.rm = TRUE)
  elapsed_years <- max(front$decade) - min(front$decade)

  total_km / elapsed_years
}
