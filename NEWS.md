
# 1.0.2

* Remove control characters `\003`, `\007`, `\010`, `\027`, as they are
  not allowed in XML 1.0, #1 @GregoireGauriot

* Always convert parsed text to UTF-8

# 1.0.1

* Fix a bug when the input is already a `getParseData()` data frame.
  https://github.com/jimhester/lintr filters the parsed data to include
  individual functions only, but only filters the data frame, not the
  underlying srcrefs, so when we call `getParseData()` on the data frame
  again, we get the data for the whole source file. This is fixed now by
  noticing that the input is already a data frame

# 1.0.0

First public release.
