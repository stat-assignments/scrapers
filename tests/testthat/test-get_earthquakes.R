test_that("get_earthquakes works", {
  eq <- get_earthquakes(lubridate::today())

  expect_equal(class(eq), "data.frame")
  expect_contains(names(eq), c("time", "longitude", "latitude", "mag"))

  eq2 <- get_earthquakes(lubridate::today()-7, end_time = lubridate::today())
  expect_equal(class(eq2), "data.frame")
  expect_equal(names(eq), names(eq2))

  eq3 <- get_earthquakes("1800/01/01", min_magnitude = 8)
  expect_equal(class(eq3), "data.frame")
  expect_equal(all(eq3$mag >= 8), TRUE)

  expect_error(get_earthquakes("1800/01/01", min_magnitude = 8, base_url = "no-such-url"))

})
