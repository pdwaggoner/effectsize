test_that("cohens_d errors and warnings", {
  # Direction ---------------------------------------------------------------
  rez_t <- t.test(iris$Sepal.Length, iris$Sepal.Width)
  rez_d <- cohens_d(iris$Sepal.Length, iris$Sepal.Width)
  expect_equal(sign(rez_t$statistic), sign(rez_d$Cohens_d), ignore_attr = TRUE)


  # Alternative -------------------------------------------------------------
  d1 <- cohens_d(iris$Sepal.Length, iris$Sepal.Width, ci = 0.80)
  d2 <- cohens_d(iris$Sepal.Length, iris$Sepal.Width, ci = 0.90, alternative = "l")
  d3 <- cohens_d(iris$Sepal.Length, iris$Sepal.Width, ci = 0.90, alternative = "g")
  expect_equal(d1$CI_high, d2$CI_high)
  expect_equal(d1$CI_low, d3$CI_low)
})

test_that("cohens_d - mu", {
  expect_equal(cohens_d(mtcars$mpg - 5),
    cohens_d(mtcars$mpg, mu = 5),
    ignore_attr = TRUE
  )

  x <- 1:9
  y <- c(1, 1:9)
  expect_equal(cohens_d(x - 3, y),
    cohens_d(x, y, mu = 3),
    ignore_attr = TRUE
  )

  d <- cohens_d(x, y, mu = 3.125)
  expect_equal(d[[1]], -0.969, tolerance = 0.01)
  expect_equal(d$CI_low, -1.913, tolerance = 0.01)
  expect_equal(d$CI_high[[1]], 0, tolerance = 0.01)
})

test_that("cohens_d - pooled", {
  x <- cohens_d(wt ~ am, data = mtcars, pooled_sd = TRUE)
  expect_equal(colnames(x)[1], "Cohens_d")
  expect_equal(x[[1]], 1.892, tolerance = 0.001)
  expect_equal(x$CI_low, 1.030, tolerance = 0.001)
  expect_equal(x$CI_high, 2.732, tolerance = 0.001)
})

test_that("cohens_d - non-pooled", {
  x <- cohens_d(wt ~ am, data = mtcars, pooled_sd = FALSE)
  expect_equal(colnames(x)[1], "Cohens_d")
  expect_equal(x[[1]], 1.934, tolerance = 0.001)
  expect_equal(x$CI_low, 1.075151, tolerance = 0.001)
  expect_equal(x$CI_high, 2.772516, tolerance = 0.001)
})

test_that("hedges_g (and other bias correction things", {
  x <- hedges_g(wt ~ am, data = mtcars)
  expect_equal(colnames(x)[1], "Hedges_g")
  expect_equal(x[[1]], 1.844, tolerance = 0.001)
  expect_equal(x$CI_low, 1.004, tolerance = 0.001)
  expect_equal(x$CI_high, 2.664, tolerance = 0.001)
})

test_that("glass_delta", {
  # must be 2 samples
  expect_error(glass_delta(1:10), "two")
  expect_error(glass_delta("wt", data = mtcars), "two")

  x <- glass_delta(wt ~ am, data = mtcars)
  expect_equal(colnames(x)[1], "Glass_delta")
  expect_equal(x[[1]], 2.200, tolerance = 0.001)
  expect_equal(x$CI_low, 1.008664, tolerance = 0.001)
  expect_equal(x$CI_high, 3.352597, tolerance = 0.001)
})


test_that("fixed values", {
  skip_if_not_installed("bayestestR")

  x1 <- bayestestR::distribution_normal(1e4, mean = 0, sd = 1)
  x2 <- bayestestR::distribution_normal(1e4, mean = 1, sd = 1)
  expect_equal(cohens_d(x1, x2)$Cohens_d, -1, tolerance = 1e-3)


  x1 <- bayestestR::distribution_normal(1e4, mean = 0, sd = 1)
  x2 <- bayestestR::distribution_normal(1e4, mean = 1.5, sd = 2)

  expect_equal(cohens_d(x1, x2)[[1]], -sqrt(0.9), tolerance = 1e-2)
  expect_equal(glass_delta(x2, x1, ci = NULL)[[1]], 1.5, tolerance = 1e-2)
})
