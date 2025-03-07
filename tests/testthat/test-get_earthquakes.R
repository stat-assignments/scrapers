test_that("get_earthquakes works", {
  eq <- get_earthquakes(lubridate::today())

  expect_equal(class(eq), "data.frame")
  expect_contains(names(eq), c("time", "longitude", "latitude", "mag"))
})
