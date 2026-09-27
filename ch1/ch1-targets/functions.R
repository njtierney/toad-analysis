tidy_toads <- function(toads_raw) {
  toads_raw |>
    clean_names() |>
    rename(
      lat = decimal_latitude,
      lon = decimal_longitude,
      date = event_date,
      coord_var_m = coordinate_uncertainty_in_meters,
      resource_name = data_resource_name
    ) |>
    mutate(
      year = year(date),
      decade = floor(year / 10) * 10,
      .after = date
    )
}

# How far is it from one decade's edge to the next?
# use {geodist} to calculate the distance, it takes a matrix of inputs:
add_distance <- function(data, lon, lat) {
  dist_mat <- cbind(lon = data[[lon]], lat = data[[lat]])

  # geodist() walks down the rows and measures each step across the surface of the
  # earth, in metres. `sequential = TRUE` is what makes it row-to-row rather than
  # every-pair. There is no step into the first decade, so we pad it out:
  distances_m <- dist_mat |>
    geodist(measure = "geodesic", sequential = TRUE, pad = TRUE)

  data |>
    mutate(
      distance_km = distances_m / 1000,
      .after = scientific_name
    )
}
