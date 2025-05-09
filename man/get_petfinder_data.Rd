% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_petfinder_data.R, R/petfinder_get_token.R
\name{get_petfinder_data}
\alias{get_petfinder_data}
\alias{petfinder_get_token}
\title{Get adoptable pets from Petfinder}
\usage{
get_petfinder_data(
  token = NULL,
  endpoint = "animals",
  params = list(type = "cat", location = "68528"),
  page = 1,
  base_url = "https://api.petfinder.com/v2/"
)

petfinder_get_token(
  key = get_api_key("PETFINDER_API"),
  secret = get_api_secret("PETFINDER_API"),
  base_url = "https://api.petfinder.com/v2"
)
}
\arguments{
\item{token}{authentication token. Can be passed in as a result of calling `petfinder_get_token`. If absent, one attempt is made at creating a new token.}

\item{endpoint}{character value - which endpoint of the Petfinder API is being used? API v2 has endpoints `animals` and `organizations`.}

\item{page}{positive integer value, defaults to one. For multi-page results, a way to pick up on a previous result.}

\item{base_url}{characterstring of the API}

\item{key}{character of the API key, if not specified, loaded from the environment}

\item{secret}{character of the API secret, if not specified, loaded from the environment}

\item{param}{(list of) parameters to pass to the endpoint. These will be incorporated into the query in the form of `name='value'&...`}
}
\value{
A list of (pages of) records returned from the Petfinder API (JSON-style list).
Each element in the list represents one page of results. Each page of results is organized in
form of 'animals' (records of about 20 animals) and 'pagination'.
Records are returned in increasing page order.
}
\description{
Downloads records of adoptable pets. You will need to have a key and a secret from the [PetFinder API](https://www.petfinder.com/developers/).
}
\examples{
# example code
# Make sure to get a token before your first use:
petf_token <- petfinder_get_token()

cats <- get_petfinder_data(token=petf_token)
length(cats)
# each element is a list of animals and pagination information:
cats[1:5] |> str(max.level = 2)
cats[[21]]$pagination[5] # the last element in the pagination vector contains the link to the next set of records, if available
cats2 <- get_petfinder_data(token=petf_token, page = 22)
# not a complete list anymore:
cats2[[21]]$animals
animals <- cats |> purrr::map(.f = function(x) x$animals)
animals[21+(1:21)] <- cats2 |> purrr::map(.f = function(x) x$animals)
animals <- animals |> purrr::compact() # get rid of empty elements
length(animals)
# flatten the structure once:
animal_record_list <- animals |> purrr::flatten()
jsonlite::write_json(animal_record_list, path = "cats.json")
# Authenticate with the petfinder API and get a token
token <- petfinder_get_token()
}
