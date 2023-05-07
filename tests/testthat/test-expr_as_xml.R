test_that("XML object is returned with correct structure", {
  skip_if_not_installed("xml2")

  expect_silent({
    expr_xml <- expr_as_xml(mtcars[, "cyl"])
  })
  expect_s3_class(expr_xml, "xml_document")
  expect_identical(
    vapply(xml2::xml_children(xml2::xml_child(expr_xml)), xml2::xml_name, character(1L)),
    c("expr", "OP-LEFT-BRACKET", "OP-COMMA", "expr", "OP-RIGHT-BRACKET")
  )
})

test_that("multi-expression case also works", {
  expect_silent({
    expr_xml <- expr_as_xml({
      1 + 1
      sqrt(rnorm(100))
    })
  })
  expect_identical(xml2::xml_name(expr_xml), "exprlist")
  # `{`, `1 + 1`, `sqrt(...)`, and `}`
  expect_length(xml2::xml_children(xml2::xml_child(expr_xml)), 4L)
})

test_that("literals are also fine", {
  expect_silent(expr_as_xml("a b c"))
  expect_silent(expr_as_xml(100L))
})
