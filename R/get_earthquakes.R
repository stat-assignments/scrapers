#' Get earthquake information from USGS
#'
#' Downloads records of earth quakes from the USGS Earthquake Catalog
#' @param start_time character string specifying the start date for the records in the form 'yyyy-mm-dd'
#' @param end_time character string specifying the end date for the records in the form 'yyyy-mm-dd'
#' @param min_magnitude numeric quantity specifying the minimum magnitude considered for a record
#' @param base_url base url for the GET request
#' @importFrom httr2 request req_headers req_url_query req_perform resp_body_string
#' @importFrom utils read.csv
#' @importFrom lubridate today
#' @return data frame of earth quake records. Detailed information on each of the variables can be found as part of the [USGS ComCat Documentation](https://earthquake.usgs.gov/data/comcat/index.php).
#' By default, data for the last 30 days is requested from the archive. This is similar data to what USGS provides as `All Earthquakes` for the past 30 days in their spreadsheet/csv feed at https://earthquake.usgs.gov/earthquakes/feed/v1.0/csv.php
#' @export
#' @examples
#' # example code
#' library(lubridate)
#' todays <- get_earthquakes(start_time = today()-1, end_time = today())
#' # all documented earthquakes with a magnitude of at least 9 on the Richter scale
#' nines <-  get_earthquakes(start_time = "1800-01-01", end_time = today(), min_magnitude=9)
get_earthquakes <- function(start_time = today()-30, end_time=NULL, min_magnitude=NULL, base_url="https://earthquake.usgs.gov/fdsnws/event/1/query") {
  #library(xml2)
  #url <- "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2014-01-01&endtime=2014-01-02"
  #library(httr2)
  start_time <- as.character(start_time)
  if (!is.null(end_time)) end_time <- as.character(end_time)

  req <- request(base_url)

  req <- req |>
    req_headers("Accept"="application/csv") |>
    req_url_query(`format`="csv", `starttime` = start_time)

  if (!is.null(end_time))
    req <- req |> req_url_query(`endtime` = end_time)

  if (!is.null(min_magnitude))
    req <- req |> req_url_query(`minmagnitude` = min_magnitude)

  response <- try({
    req |> req_perform()
  }, silent = TRUE)

  if ("try-error" %in% class(response)) {
    stop(response[1])
  }
  if (response$status_code != 200) {
    stop(response[1])
  }

  # We know that things worked:
  tmp <- tempfile(pattern = "csv")
  fileConn<-file(tmp)
  writeLines(resp_body_string(response), fileConn)
  close(fileConn)
  read.csv(tmp)
}
