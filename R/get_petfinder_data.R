#' Get adoptable pets from Petfinder
#'
#' Downloads records of adoptable pets. You will need to have a key and a secret from the [PetFinder API](https://www.petfinder.com/developers/).
#' @param token authentication token. Can be passed in as a result of calling `petfinder_get_token`. If absent, one attempt is made at creating a new token.
#' @param endpoint character value - which endpoint of the Petfinder API is being used? API v2 has endpoints `animals` and `organizations`.
#' @param param (list of) parameters to pass to the endpoint. These will be incorporated into the query in the form of `name='value'&...`
#' @param page positive integer value, defaults to one. For multi-page results, a way to pick up on a previous result.
#' @param base_url base url for the GET request
#' @importFrom httr2 request req_headers req_url_query req_perform resp_body_string req_auth_bearer_token
#' @importFrom httr2 req_perform_iterative iterate_with_link_url
#' @importFrom utils read.csv
#' @importFrom lubridate today
#' @return A list of (pages of) records returned from the Petfinder API (JSON-style list).
#' Each element in the list represents one page of results. Each page of results is organized in
#' form of 'animals' (records of about 20 animals) and 'pagination'.
#' Records are returned in increasing page order.
#' @export
#' @examples
#' # example code
#' # Make sure to get a token before your first use:
#' petf_token <- petfinder_get_token()
#'
#' cats <- get_petfinder_data(token=petf_token)
#' length(cats)
#' # each element is a list of animals and pagination information:
#' cats[1:5] |> str(max.level = 2)
#' cats[[21]]$pagination[5] # the last element in the pagination vector contains the link to the next set of records, if available
#' cats2 <- get_petfinder_data(token=petf_token, page = 22)
#' # not a complete list anymore:
#' cats2[[21]]$animals
#' animals <- cats |> purrr::map(.f = function(x) x$animals)
#' animals[21+(1:21)] <- cats2 |> purrr::map(.f = function(x) x$animals)
#' animals <- animals |> purrr::compact() # get rid of empty elements
#' length(animals)
#' # flatten the structure once:
#' animal_record_list <- animals |> purrr::flatten()
#' jsonlite::write_json(animal_record_list, path = "cats.json")
get_petfinder_data <- function(
    token = NULL, endpoint = "animals",
    params = list(type="cat", location = "68528"), page=1, base_url="https://api.petfinder.com/v2/") {

  if (is.null(token)) {
    token = petfinder_get_token()
  }
  if (!is.list(params)) params <- list(params)
  # Build query
  req <- request(base_url) |>
    req_url_path_append(endpoint) |>
    req_url_query(!!!params) |>
    req_url_query("page"=page) |>
    req_headers(Authorization = paste0("Bearer ", token))

# Two steps: check that the authentication works in general, then iterate

  # Make authenticated request to get data
  response <- try({
    req |>
      req_perform()
  }, silent = TRUE)

  if ("try-error" %in% class(response)) {
    stop(response[1])
  }
  if (response$status_code != 200) {
    stop(response[1])
  }
  result <- list(response)
  # Now we know that things work in general, we get the next pages:

  response <- req_perform_iterative(
    req = req,
    next_req = httr2::iterate_with_offset("page", start=page+1)
  )
  # include new responses:
  result[2:(length(response)+1)] <- response
  result |> purrr::map(resp_body_json)
}


