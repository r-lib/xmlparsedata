
spaces_const <- sapply(1:41 - 1, function(x) paste(rep(" ", x), collapse = ""))

spaces <- function(x) spaces_const[pmin(x, 40) + 1]

reparse_octal <- function(pd, lines) {
  out <- character(nrow(pd))
  single_line <- pd$line1 == pd$line2
  out[single_line] <- substr(lines[pd$line1[single_line]], pd$col1[single_line], pd$col2[single_line])
  for (ii in which(!single_line)) {
    out[ii] <- paste(
      c(
        substring(lines[pd$line1[ii]], pd$col1[ii]),
        if (pd$line1[ii] < pd$line2[ii] - 1L) lines[(pd$line1[ii] + 1L):(pd$line2[ii] - 1L)],
        substr(lines[pd$line2[ii]], 1L, pd$col2[ii])
      ),
      collapse = "\n"
    )
  }
  out
}
