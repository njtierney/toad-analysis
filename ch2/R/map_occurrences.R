#' Map the records on a slippy map
#'
#' An interactive map of every record you pass it. The map fits to the data, so
#' if a record sits in the Pacific Ocean the map zooms out far enough to show
#' you the Pacific Ocean. That is the intended behaviour.
#'
#' @param occurrences A data frame with `lon` and `lat`.
#'
#' @return A leaflet widget.
map_occurrences <- function(occurrences) {
  points <- occurrences |>
    filter(!is.na(lon), !is.na(lat))

  leaflet(points) |>
    addProviderTiles("CartoDB.Positron") |>
    addCircleMarkers(
      lng = ~lon,
      lat = ~lat,
      radius = 3,
      stroke = FALSE,
      fillColor = "#1B9E77",
      fillOpacity = 0.6,
      popup = ~ paste0("Year: ", year)
    )
}
