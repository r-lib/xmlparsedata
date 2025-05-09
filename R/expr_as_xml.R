#' Get an XML representation of an expression
#'
#' @param expr An expression.
#' @export
expr_as_xml <- function(expr) {
  if (!requireNamespace("xml2", quietly = TRUE)) {
    stop("'xml2' is required to return an XML object")
  }
  tmp_source <- tempfile()
  on.exit(unlink(tmp_source))

  # NB: deparse() approach struggles with `{` expressions
  dput(substitute(expr), file = tmp_source)
  parsed_expr <- parse(tmp_source, keep.source = TRUE)
  # TODO(#28): Strip the line/column metadata which
  #   is technically 'missing' for this case.
  xml2::read_xml(xml_parse_data(parsed_expr))
}
