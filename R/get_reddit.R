#' Get user content from reddit
#'
#' Download an individual user's content from reddit
#' @param user_name character string for an individual reddit user
#' @param limit integer value between 1 and 100
#' @param after character string specifying the location in a list of user comments. If specified, the comments after that location are returned (if found).
#' @param base_url base url for the GET request
#' @importFrom httr2 request req_headers  req_url_path_append req_url_query req_perform resp_body_string
#' @importFrom utils URLencode
#' @importFrom lubridate today
#' @importFrom jsonlite fromJSON
#' @return list containing named items: `data`, `after`, and `request`.
#' `data` is a data frame of reddit comments for a user.
#' `after` is a character value of the hashed location of the last comment included in the returned items. This value can be used as a starting point for the next batch of responses.
#' `request` is the exact string for which results are returned.
#' @export
#' @examples
#' # example code
#' sprog2 <- get_user_comments(user_name="poem_for_your_sprog", limit=2)
#' sprog_next2 <- get_user_comments(user_name="poem_for_your_sprog", limit=2, after=sprog2$after)
#' sprog4 <- get_user_comments(user_name="poem_for_your_sprog", limit=4)
get_user_comments <- function(user_name, limit = 10L, after = NULL, base_url="https://www.reddit.com/") {
  #
  if (!is.null(limit)) {
    stopifnot(is.numeric(limit))
    limit <- as.integer(limit)
  }
  if (is.null(limit)) limit <- 100 # max limit

  stopifnot(limit > 0, limit <= 100)

  req <- request(base_url) |>
    req_url_path_append("user") |>
    req_url_path_append(paste0(URLencode(user_name), ".json"))

  req <- req |>
    req_headers("Accept"="application/json") |>
    req_url_query(`limit`=limit, raw_json=1)



  if (!is.null(after)) {
    req <- req |> req_url_query(`after`=after)
  }

  response <- try({
    req |> req_perform()
  }, silent = TRUE)

  if ("try-error" %in% class(response)) {
    stop(response[1])
  }
  if (response$status_code != 200) {
    stop(response[1])
  }

  res <- response |> resp_body_string() |> jsonlite::fromJSON()

  # should be a listing
  if (res$kind == "Listing") {
    after <- res$data$after

    data <- res$data$children$data
    return(list(data=data, after=after, request=req$url))
  }

  res
}


