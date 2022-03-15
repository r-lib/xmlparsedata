library(testthat)
library(xmlparsedata)

if (requireNamespace("xml2", quietly = TRUE)) {
  test_check("xmlparsedata")
}
