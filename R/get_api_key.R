#' @export
get_api_key <- function(which_api, verbose = TRUE) {
  KEY = paste0(which_api, "_KEY")
  if (verbose) message(sprintf("Searching for key <%s> ... ", KEY))
  key <- Sys.getenv(KEY)
  if (identical(key, "")) {
    stop("\nNo API key found, please supply with `key` argument or store in environment")
  }

  key
}

# really, should be using secret_encrypt from httr2

# set_api_key <- function(key = NULL) {
#   if (is.null(key)) {
#     key <- askpass::askpass("Please enter your API key")
#   }
#   Sys.setenv("NYTIMES_KEY" = key)
# }

#' @export
get_api_secret <- function(which_api, verbose = TRUE) {
  SECRET = paste0(which_api, "_SECRET")
  if (verbose) message(sprintf("Searching for secret <%s> ... ", SECRET))
  key <- Sys.getenv(SECRET)
  if (identical(key, "")) {
    stop("\nNo API secret found, please supply with `secret` argument or store in environment")
  } else {
    if (verbose) message("OK\n")
  }

  key
}
