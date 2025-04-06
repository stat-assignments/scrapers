test_that("get_user_comments works", {
  sp <- get_user_comments("poem_for_your_sprog", limit=3)

  expect_equal(class(sp), "list")
  expect_contains(names(sp), c("data", "after", "request"))
  expect_equal(class(sp$data), "data.frame")
  expect_equal(dim(sp$data), c(3, 76))

  expect_error(get_user_comments("no such user", limit = 1000),
               "limit <= 100 is not TRUE") # too high

  expect_error(get_user_comments("no such user", limit = -1),
               "limit > 0 is not TRUE") # too low

  expect_error(get_user_comments("no such user", limit = 1),
               "HTTP 404 Not Found") # not found

})
