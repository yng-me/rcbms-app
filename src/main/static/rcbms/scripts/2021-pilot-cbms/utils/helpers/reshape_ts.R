reshape_ts <- function(data, seq_length, filter = NULL) {
  
  data <- data %>% filter_reg_ts() 
  
  cases <- data %>% 
    group_by(case_id) %>% 
    count() %>% 
    filter(n == seq_length) 
  
  df <- data %>% 
    filter(case_id %in% cases$case_id) %>%
    arrange(case_id) %>% 
    mutate(value = rep_along(case_id, 1:seq_length))

  if(!is.null(filter)) {
    df <- df %>% filter(value %in% filter)
  }
  
  return(df)
}
