#' Plot how fast the front moved, decade by decade
#'
#' One bar per decade. The shape is the point: the invasion accelerated, so a
#' single average rate describes none of the decades well. A flat bar means the
#' front did not move that decade, which is sometimes true and sometimes means
#' nobody went and looked.
#'
#' @param front A tibble from [front_distances()].
#'
#' @return A ggplot object. Nothing is written to disk.
plot_front <- function(front) {
  ggplot(front, aes(x = decade, y = km_per_year)) +
    geom_col(fill = "grey20") +
    scale_x_continuous(breaks = scales::breaks_width(width = 10)) +
    labs(
      x = NULL,
      y = "km per year",
      title = "How fast did the front move?"
    ) +
    theme_minimal(base_size = 12)
}
