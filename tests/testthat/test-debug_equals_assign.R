context("debugging `a = 1` bug in R3.6")

test_that("equals_assign bug on R 3.6", {
  # `a = 1` is an example of an R statement that gets parsed into nested xml
  # nodes that have different token / tagnames (following the introduction of
  # the `equal_assign` token to getParseData() in R-3.6), but the same ending
  # position in the original code. Tokens/expressions that start before should
  # end after any nested subexpressions in the resulting xml:

  xml <- xml_parse_data(parse(text = "a = 1", keep.source = TRUE))
  expect_true(is.character(xml))
  expect_true(length(xml) == 1)
  expect_silent(x <- xml2::read_xml(xml))
})

