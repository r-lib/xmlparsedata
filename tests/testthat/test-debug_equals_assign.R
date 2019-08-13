context("debugging `a = 1` bug in R3.6")

test_that("equals_assign bug on R 3.6", {
  # in R3.6 the xml for `a = 1` originally came out as:
  # <exprlist>
  #   <equal_assign ...>
  #     <expr ...>
  #       <SYMBOL ...>a</SYMBOL>
  #     </expr>
  #     <EQ_ASSIGN ...>=</EQ_ASSIGN>
  #     <expr ...>
  #       <NUM_CONST ...>1</NUM_CONST>
  #     </equal_assign>
  #   </expr>
  # </exprlist>

  # in R3.5 the same code gave
  # ...
  # <exprlist>
  #   <expr ...>
  #     <SYMBOL ...>a</SYMBOL>
  #   </expr>
  #   <EQ_ASSIGN ...>=</EQ_ASSIGN>
  #   <expr ...>
  #     <NUM_CONST ...>1</NUM_CONST>
  #   </expr>
  # </exprlist>

  # The tags have changed:
  # -  R3.6 intends to wrap the whole assignment statement using the tagname
  # `equal_assign` (whereas R3.5 uses `expr`)

  # But also, the xml parsing in R3.6 has interleaved the `equal_assign` tag
  # with the final `expr` tag; resulting in an illegal xml string

  # `equal_assign` nodes in results from getParseData() mean that `expr` nodes
  # can be nested inside `equal_assign` nodes in such a way that the start of
  # one nested-node matches the start of the equal_assign node, and the end of
  # a nested-node matches the end of the equal_assign node.

  xml <- xml_parse_data(parse(text = "a = 1", keep.source = TRUE))
  expect_true(is.character(xml))
  expect_true(length(xml) == 1)
  expect_silent(x <- xml2::read_xml(xml))
})

