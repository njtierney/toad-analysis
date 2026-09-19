#' Read cached occurrence records
#'
#' Reads one species' parquet file and tidies the column names. No cleaning
#' happens here on purpose: what arrives is what the Atlas of Living Australia
#' sent, warts and all, so you can see the warts before deciding what to do
#' about them. [clean_occurrences()] is the deciding.
#'
#' @param path Path to a parquet file of occurrence records.
#'
#' @return A tibble, one row per record, with snake_case column names.
read_occurrences <- function(path) {
  read_parquet(file = path) |>
    clean_names()
}
