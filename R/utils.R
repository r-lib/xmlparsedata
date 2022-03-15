
spaces_const <- sapply(1:41 - 1, function(x) paste(rep(" ", x), collapse = ""))

spaces <- function(x) spaces_const[pmin(x, 40) + 1]
