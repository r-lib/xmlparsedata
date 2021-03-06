
# xmlparsedata

> Parse Data of R Code as an ‘XML’ Tree

<!-- badges: start -->

[![R build
status](https://github.com/r-lib/xmlparsedata/workflows/R-CMD-check/badge.svg)](https://github.com/r-lib/xmlparsedata/actions)
[![](https://www.r-pkg.org/badges/version/xmlparsedata)](https://www.r-pkg.org/pkg/xmlparsedata)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/xmlparsedata)](https://www.r-pkg.org/pkg/xmlparsedata)
[![Coverage
Status](https://img.shields.io/codecov/c/github/r-lib/xmlparsedata/master.svg)](https://codecov.io/github/r-lib/xmlparsedata?branch=master)
<!-- badges: end -->

Convert the output of ‘utils::getParseData()’ to an ‘XML’ tree, that is
searchable and easier to manipulate in general.

-----

  - [Installation](#installation)
  - [Usage](#usage)
      - [Introduction](#introduction)
      - [`utils::getParseData()`](#utilsgetparsedata)
      - [`xml_parse_data()`](#xml_parse_data)
      - [Renaming some tokens](#renaming-some-tokens)
      - [Search the parse tree with
        `xml2`](#search-the-parse-tree-with-xml2)
  - [License](#license)

## Installation

``` r
install.packages("xmlparsedata")
```

## Usage

### Introduction

In recent R versions the parser can attach source code location
information to the parsed expressions. This information is often useful
for static analysis, e.g. code linting. It can be accessed via the
`utils::getParseData()` function.

`xmlparsedata` converts this information to an XML tree. The R parser’s
token names are preserved in the XML as much as possible, but some of
them are not valid XML tag names, so they are renamed, see below.

### `utils::getParseData()`

`utils::getParseData()` summarizes the parse information in a data
frame. The data frame has one row per expression tree node, and each
node points to its parent. Here is a small example:

``` r
p <- parse(
  text = "function(a = 1, b = 2) { \n  a + b\n}\n",
  keep.source = TRUE
  )
getParseData(p)
```

    #>    line1 col1 line2 col2 id parent          token terminal     text
    #> 33     1    1     3    1 33      0           expr    FALSE         
    #> 1      1    1     1    8  1     33       FUNCTION     TRUE function
    #> 2      1    9     1    9  2     33            '('     TRUE        (
    #> 3      1   10     1   10  3     33 SYMBOL_FORMALS     TRUE        a
    #> 4      1   12     1   12  4     33     EQ_FORMALS     TRUE        =
    #> 5      1   14     1   14  5      6      NUM_CONST     TRUE        1
    #> 6      1   14     1   14  6     33           expr    FALSE         
    #> 7      1   15     1   15  7     33            ','     TRUE        ,
    #> 10     1   17     1   17 10     33 SYMBOL_FORMALS     TRUE        b
    #> 11     1   19     1   19 11     33     EQ_FORMALS     TRUE        =
    #> 12     1   21     1   21 12     13      NUM_CONST     TRUE        2
    #> 13     1   21     1   21 13     33           expr    FALSE         
    #> 14     1   22     1   22 14     33            ')'     TRUE        )
    #> 30     1   24     3    1 30     33           expr    FALSE         
    #> 17     1   24     1   24 17     30            '{'     TRUE        {
    #> 25     2    3     2    7 25     30           expr    FALSE         
    #> 19     2    3     2    3 19     21         SYMBOL     TRUE        a
    #> 21     2    3     2    3 21     25           expr    FALSE         
    #> 20     2    5     2    5 20     25            '+'     TRUE        +
    #> 22     2    7     2    7 22     24         SYMBOL     TRUE        b
    #> 24     2    7     2    7 24     25           expr    FALSE         
    #> 28     3    1     3    1 28     30            '}'     TRUE        }

### `xml_parse_data()`

`xmlparsedata::xml_parse_data()` converts the parse information to an
XML document. It works similarly to `getParseData()`. Specify the
`pretty = TRUE` option to pretty-indent the XML output. Note that this
has a small overhead, so if you are parsing large files, I suggest you
omit it.

``` r
library(xmlparsedata)
xml <- xml_parse_data(p, pretty = TRUE)
cat(xml)
```

    #> <?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
    #> <exprlist>
    #>   <expr line1="1" col1="1" line2="3" col2="1" start="26" end="76">
    #>     <FUNCTION line1="1" col1="1" line2="1" col2="8" start="26" end="33">function</FUNCTION>
    #>     <OP-LEFT-PAREN line1="1" col1="9" line2="1" col2="9" start="34" end="34">(</OP-LEFT-PAREN>
    #>     <SYMBOL_FORMALS line1="1" col1="10" line2="1" col2="10" start="35" end="35">a</SYMBOL_FORMALS>
    #>     <EQ_FORMALS line1="1" col1="12" line2="1" col2="12" start="37" end="37">=</EQ_FORMALS>
    #>     <expr line1="1" col1="14" line2="1" col2="14" start="39" end="39">
    #>       <NUM_CONST line1="1" col1="14" line2="1" col2="14" start="39" end="39">1</NUM_CONST>
    #>     </expr>
    #>     <OP-COMMA line1="1" col1="15" line2="1" col2="15" start="40" end="40">,</OP-COMMA>
    #>     <SYMBOL_FORMALS line1="1" col1="17" line2="1" col2="17" start="42" end="42">b</SYMBOL_FORMALS>
    #>     <EQ_FORMALS line1="1" col1="19" line2="1" col2="19" start="44" end="44">=</EQ_FORMALS>
    #>     <expr line1="1" col1="21" line2="1" col2="21" start="46" end="46">
    #>       <NUM_CONST line1="1" col1="21" line2="1" col2="21" start="46" end="46">2</NUM_CONST>
    #>     </expr>
    #>     <OP-RIGHT-PAREN line1="1" col1="22" line2="1" col2="22" start="47" end="47">)</OP-RIGHT-PAREN>
    #>     <expr line1="1" col1="24" line2="3" col2="1" start="49" end="76">
    #>       <OP-LEFT-BRACE line1="1" col1="24" line2="1" col2="24" start="49" end="49">{</OP-LEFT-BRACE>
    #>       <expr line1="2" col1="3" line2="2" col2="7" start="53" end="57">
    #>         <expr line1="2" col1="3" line2="2" col2="3" start="53" end="53">
    #>           <SYMBOL line1="2" col1="3" line2="2" col2="3" start="53" end="53">a</SYMBOL>
    #>         </expr>
    #>         <OP-PLUS line1="2" col1="5" line2="2" col2="5" start="55" end="55">+</OP-PLUS>
    #>         <expr line1="2" col1="7" line2="2" col2="7" start="57" end="57">
    #>           <SYMBOL line1="2" col1="7" line2="2" col2="7" start="57" end="57">b</SYMBOL>
    #>         </expr>
    #>       </expr>
    #>       <OP-RIGHT-BRACE line1="3" col1="1" line2="3" col2="1" start="76" end="76">}</OP-RIGHT-BRACE>
    #>     </expr>
    #>   </expr>
    #> </exprlist>

The top XML tag is `<exprlist>`, which is a list of expressions, each
expression is an `<expr>` tag. Each tag has attributes that define the
location: `line1`, `col1`, `line2`, `col2`. These are from the
`getParseData()` data frame column names.

### Renaming some tokens

The R parser’s token names are preserved in the XML as much as possible,
but some of them are not valid XML tag names, so they are renamed, see
the `xml_parse_token_map` vector for the mapping:

``` r
xml_parse_token_map
```

    #>                '?'                '~'                '+'                '-' 
    #>      "OP-QUESTION"         "OP-TILDE"          "OP-PLUS"         "OP-MINUS" 
    #>                '*'                '/'                ':'                '^' 
    #>          "OP-STAR"         "OP-SLASH"         "OP-COLON"         "OP-CARET" 
    #>                '$'                '@'                '('                '[' 
    #>        "OP-DOLLAR"            "OP-AT"    "OP-LEFT-PAREN"  "OP-LEFT-BRACKET" 
    #>                ';'                '{'                '}'                ')' 
    #>     "OP-SEMICOLON"    "OP-LEFT-BRACE"   "OP-RIGHT-BRACE"   "OP-RIGHT-PAREN" 
    #>                '!'                ']'                ','             '\\\\' 
    #>   "OP-EXCLAMATION" "OP-RIGHT-BRACKET"         "OP-COMMA"        "OP-LAMBDA"

### Search the parse tree with `xml2`

The `xml2` package can search XML documents using
[XPath](https://en.wikipedia.org/wiki/XPath) expressions. This is often
useful to search for specific code patterns.

As an example we search a source file from base R for `1:nrow(<expr>)`
expressions, which are usually unsafe, as `nrow()` might be zero, and
then the expression is equivalent to `1:0`, i.e. `c(1, 0)`, which is
usually not the intended behavior.

We load and parse the file directly from the the R source code mirror at
<https://github.com/wch/r-source>:

``` r
url <- paste0(
  "https://raw.githubusercontent.com/wch/r-source/",
  "4fc93819fc7401b8695ce57a948fe163d4188f47/src/library/tools/R/xgettext.R"
)
src <- readLines(url)
p <- parse(text = src, keep.source = TRUE)
```

and we convert it to an XML tree:

``` r
library(xml2)
xml <- read_xml(xml_parse_data(p))
```

The `1:nrow(<expr>)` expression corresponds to the following tree in R:

    <expr>
      +-- <expr>
        +-- NUM_CONST: 1
      +-- ':'
      +-- <expr>
        +-- <expr>
          +-- SYMBOL_FUNCTION_CALL nrow
        +-- '('
        +-- <expr>
        +-- ')'

``` r
bad <- xml_parse_data(
  parse(text = "1:nrow(expr)", keep.source = TRUE),
  pretty = TRUE
)
cat(bad)
```

    #> <?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
    #> <exprlist>
    #>   <expr line1="1" col1="1" line2="1" col2="12" start="14" end="25">
    #>     <expr line1="1" col1="1" line2="1" col2="1" start="14" end="14">
    #>       <NUM_CONST line1="1" col1="1" line2="1" col2="1" start="14" end="14">1</NUM_CONST>
    #>     </expr>
    #>     <OP-COLON line1="1" col1="2" line2="1" col2="2" start="15" end="15">:</OP-COLON>
    #>     <expr line1="1" col1="3" line2="1" col2="12" start="16" end="25">
    #>       <expr line1="1" col1="3" line2="1" col2="6" start="16" end="19">
    #>         <SYMBOL_FUNCTION_CALL line1="1" col1="3" line2="1" col2="6" start="16" end="19">nrow</SYMBOL_FUNCTION_CALL>
    #>       </expr>
    #>       <OP-LEFT-PAREN line1="1" col1="7" line2="1" col2="7" start="20" end="20">(</OP-LEFT-PAREN>
    #>       <expr line1="1" col1="8" line2="1" col2="11" start="21" end="24">
    #>         <SYMBOL line1="1" col1="8" line2="1" col2="11" start="21" end="24">expr</SYMBOL>
    #>       </expr>
    #>       <OP-RIGHT-PAREN line1="1" col1="12" line2="1" col2="12" start="25" end="25">)</OP-RIGHT-PAREN>
    #>     </expr>
    #>   </expr>
    #> </exprlist>

This translates to the following XPath expression (ignoring the last
tree tokens from the `length(expr)` expressions):

``` r
xp <- paste0(
  "//expr",
     "[expr[NUM_CONST[text()='1']]]",
     "[OP-COLON]",
     "[expr[expr[SYMBOL_FUNCTION_CALL[text()='nrow']]]]"
)
```

We can search for this subtree with `xml2::xml_find_all()`:

``` r
bad_nrow <- xml_find_all(xml, xp)
bad_nrow
```

    #> {xml_nodeset (1)}
    #> [1] <expr line1="334" col1="19" line2="334" col2="27" start="38763" end="3877 ...

There is only one hit, in line 334:

``` r
cbind(332:336, src[332:336])
```

    #>      [,1]  [,2]                                           
    #> [1,] "332" "\tcat(\"No errors\\n\")"                      
    #> [2,] "333" "    else"                                     
    #> [3,] "334" "\tfor (i in 1:nrow(x)) {"                     
    #> [4,] "335" "\t    if (is.na(x[i, 2L])) cols <- c(1L, 3:5)"
    #> [5,] "336" "\t    else cols <- 1:5"

## License

MIT © Mango Solutions
