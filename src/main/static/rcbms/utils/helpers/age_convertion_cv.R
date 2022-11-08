convert_age_cv <- function(from, to = '2022-06-30') {
  from_lt = as.POSIXlt(mdy(from))
  to_lt = as.POSIXlt(to)
  
  age = to_lt$year - from_lt$year
  
  ifelse(to_lt$mon < from_lt$mon |
           (to_lt$mon == from_lt$mon & to_lt$mday < from_lt$mday),
         age - 1, age)
}
