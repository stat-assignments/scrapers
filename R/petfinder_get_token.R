#' @rdname get_petfinder_data
#' @param key character of the API key, if not specified, loaded from the environment
#' @param secret character of the API secret, if not specified, loaded from the environment
#' @param base_url characterstring of the API
#' @importFrom httr2 req_method req_body_json req_perform resp_body_json
#' @export
#' @examples
#' # Authenticate with the petfinder API and get a token
#' token <- petfinder_get_token()
petfinder_get_token <- function(
    key = get_api_key("PETFINDER_API"),
    secret = get_api_secret("PETFINDER_API"), base_url="https://api.petfinder.com/v2") {

  # Get OAuth2 token
  resp <- request(file.path(base_url, "oauth2/token")) |>
    req_body_json(list(
      grant_type = "client_credentials",
      client_id = key,
      client_secret = secret
    )) |>
    req_method("POST") |>
    req_perform()

  if (resp$status_code != 200) {
    stop(resp[1])
  }
  message("Successfully authenticated with PetFinder API.\n")
  token <- resp |> resp_body_json() |> (\(x) x$access_token)()
}
