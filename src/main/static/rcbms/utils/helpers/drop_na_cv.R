drop_na_cv <- function(data, drop_count = 13) {
  
  n <- data %>% 
    count(case_id)
  
  data %>% 
    left_join(n, by = 'case_id') %>% 
    filter(rowSums(is.na(.)) <= (ncol(.) - drop_count) | n == 1)
}

