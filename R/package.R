
#' Parse Data of R Code as an 'XML' Tree
#'
#' Convert the output of 'utils::getParseData()' to an 'XML' tree, that is
#' searchable and easier to manipulate in general.
#'
#' @docType package
#' @name xmlparsedata
NULL

#' Convert R parse data to XML
#'
#' In recent R versions the parser can attach source code location
#' information to the parsed expressions. This information is often
#' useful for static analysis, e.g. code linting. It can be accessed
#' via the \code{\link[utils]{getParseData}} function.
#'
#' \code{xml_parse_data} converts this information to an XML tree.
#' The R parser's token names are preserved in the XML as much as
#' possible, but some of them are not valid XML tag names, so they are
#' renamed, see the \code{\link{xml_parse_token_map}} vector for the
#' mapping.
#'
#' The top XML tag is \code{<exprlist>}, which is a list of
#' expressions, each expression is an \code{<expr>} tag. Each tag
#' has attributes that define the location: \code{line1}, \code{col1},
#' \code{line2}, \code{col2}. These are from the \code{\link{getParseData}}
#' data frame column names.
#'
#' See an example below. See also the README at
#' \url{https://github.com/r-lib/xmlparsedata#readme}
#' for examples on how to search the XML tree with the \code{xml2} package
#' and XPath expressions.
#'
#' @param pretty Whether to pretty-indent the XML output. It has a small
#'   overhead which probably only matters for very large source files.
#' @inheritParams utils::getParseData
#' @return An XML string representing the parse data. See details below.
#'
#' @export
#' @importFrom utils getParseData
#' @seealso \code{\link{xml_parse_token_map}} for the token names.
#' \url{https://github.com/r-lib/xmlparsedata#readme} for more
#' information and use cases.
#' @examples
#' code <- "function(a = 1, b = 2) {\n  a + b\n}\n"
#' expr <- parse(text = code, keep.source = TRUE)
#'
#' # The base R way:
#' getParseData(expr)
#'
#' cat(xml_parse_data(expr, pretty = TRUE))

xml_parse_data <- function(x, includeText = NA, pretty = FALSE) {

  xml_header <- paste0(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"",
    "standalone=\"yes\" ?>\n<exprlist>\n"
  )
  xml_footer <- "\n</exprlist>\n"

  ## Maybe it is already a data frame, e.g. when used in lintr
  if (is.data.frame(x)) {
    pd <- x

  } else {
    pd <- getParseData(x, includeText = includeText)
  }

  if (!nrow(pd)) return(paste0(xml_header, xml_footer))

  pd <- fix_comments(pd)
  pd$text <-  enc2utf8(pd$text)

  ## Tags for all nodes, teminal nodes have end tags as well
  pd$token <- map_token(pd$token)

  ## Positions, to make it easy to compare what comes first
  maxcol <- max(pd$col1, pd$col2) + 1L
  pd$start <- pd$line1   * maxcol + pd$col1
  pd$end   <- pd$line2   * maxcol + pd$col2

  pd$tag <- paste0(
    "<", pd$token,
    " line1=\"", pd$line1,
    "\" col1=\"", pd$col1,
    "\" line2=\"", pd$line2,
    "\" col2=\"", pd$col2,
    "\" start=\"", pd$start,
    "\" end=\"", pd$end,
    "\">",
    xml_encode(pd$text),
    ifelse(pd$terminal, paste0("</", pd$token, ">"), "")
  )

  ## Add an extra terminal tag for each non-terminal one
  pd2 <- pd[! pd$terminal, ]
  if (nrow(pd2)) {
    pd2$terminal <- TRUE
    pd2$parent <- -1
    pd2$line1 <- pd2$line2
    pd2$col1 <- pd2$col2
    pd2$line2 <- pd2$line2 - 1L
    pd2$col2 <- pd2$col2 - 1L
    pd2$tag <- paste0("</", pd2$token, ">")
    pd <- rbind(pd, pd2)
  }

  ## Order the nodes properly
  pd <- pd[ order(pd$line1, pd$col1, -pd$line2, -pd$col2, pd$terminal), ]

  if (pretty) {
    str <- ! pd$terminal
    end <- pd$parent == -1
    ind <- 2L + cumsum(str * 2L + end * (-2L)) - str * 2L
    xml <- paste0(spaces(ind), pd$tag, collapse = "\n")

  } else {
    xml <- paste(pd$tag, collapse = "\n")
  }

  paste0(xml_header, xml, xml_footer)
}

fix_comments <- function(pd) {
  pd$parent[ pd$parent < 0 ] <- 0
  pd
}

map_token <- function(token) {
  map <- xml_parse_token_map[token]
  ifelse(is.na(map), token, map)
}

#' Map token names of the R parser to token names in
#' \code{\link{xml_parse_data}}
#'
#' Some of the R token names are not valid XML tag names,
#' so \code{\link{xml_parse_data}} needs to replace them to create a
#' valid XML file.
#'
#' @export
#' @seealso \code{\link{xml_parse_data}}

xml_parse_token_map <- c(
  "'?'" = "OP-QUESTION",
  "'~'" = "OP-TILDE",
  "'+'" = "OP-PLUS",
  "'-'" = "OP-MINUS",
  "'*'" = "OP-STAR",
  "'/'" = "OP-SLASH",
  "':'" = "OP-COLON",
  "'^'" = "OP-CARET",
  "'$'" = "OP-DOLLAR",
  "'@'" = "OP-AT",
  "'('" = "OP-LEFT-PAREN",
  "'['" = "OP-LEFT-BRACKET",
  "';'" = "OP-SEMICOLON",
  "'{'" = "OP-LEFT-BRACE",
  "'}'" = "OP-RIGHT-BRACE",
  "')'" = "OP-RIGHT-PAREN",
  "'!'" = "OP-EXCLAMATION",
  "']'" = "OP-RIGHT-BRACE",
  "','" = "OP-COMMA"
)

xml_encode <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("\003", "", x, fixed = TRUE) # Control-C character are not allowed in xml 1.0
  x <- gsub("\007", "", x, fixed = TRUE) # neither is Bell
  x <- gsub("\010", "", x, fixed = TRUE) # neither is Backspace
  x <- gsub("\027", "", x, fixed = TRUE) # neither is Escape
  x
}
