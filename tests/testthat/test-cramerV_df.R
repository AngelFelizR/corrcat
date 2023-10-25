library(testthat)

test_that("Validating cramerV_df results",{

  set.seed(2024)
  df <- data.frame(
    gender = sample(c("male", "female"), 100, replace = TRUE) |> factor(),
    race = sample(c("white", "black", "asian", "other"), 100, replace = TRUE),
    education = sample(c("high school", "college", "graduate"), 100, replace = TRUE),
    income = sample(c("low", "medium", "high"), 100, replace = TRUE)
  )
  set.seed(NULL)

  ResultTest <- data.frame(
    V1 = c('gender', 'gender', 'gender', 'race', 'race', 'education'),
    V2 = c('race', 'education', 'income', 'education', 'income', 'income'),
    Cramer.V = c(0.1537, 0.07143, 0.1035, 0.1848, 0.1892, 0.199)
  )

  Result <- cramerV_df(df)
  ResultCi <- cramerV_df(df, ci = TRUE, R = 50)

  # Validating ci results
  expect_identical(ResultCi[1:3], ResultTest)
  expect_identical(names(ResultCi),
                   c(names(ResultTest), "lower.ci", "upper.ci"))

  # Validating results with data.frame
  expect_identical(Result, ResultTest)

  # Validating results with data.table
  dt <- data.table::as.data.table(df)
  ResultTestDt <- data.table::as.data.table(ResultTest)
  expect_identical(cramerV_df(dt), ResultTestDt)

  # Validating results with data.table
  dt <- data.table::as.data.table(df)
  ResultTestDt <- data.table::as.data.table(ResultTest)
  expect_identical(cramerV_df(dt), ResultTestDt)

  # Validating results with tibble
  # For this case identical doesn't work
  # For a open issue in data.table
  # https://github.com/Rdatatable/data.table/issues/5698
  df_tibble <- tibble::as_tibble(df)
  ResultTestTibble  <- tibble::as_tibble(ResultTest)
  expect_identical(class(cramerV_df(df_tibble)),
                   class(ResultTestTibble))

})


test_that("Validating df most be data.frame",{

  expect_error(cramerV_df(1:5))
  expect_error(cramerV_df(matrix(1:6, nrow = 2)))
  expect_error(cramerV_df(matrix(LETTERS[1:6], nrow = 2)))

})

test_that("df must have at least 2 categorical variables",{

  expect_error(cramerV_df(iris))

})
