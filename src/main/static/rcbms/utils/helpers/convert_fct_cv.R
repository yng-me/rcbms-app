convert_fct_cv <- function(data) {
  
  names <- as_tibble(names(data)) 
  
  fct_replace <- names %>% 
    filter(grepl('_fct$', value)) %>% 
    mutate(value = str_remove(value, '_fct$')) %>% 
    filter(value %in% names$value) %>% 
    mutate(value = paste0('^', value, '$')) %>% 
    pull(value) 
  
  df <- data %>% 
    select(-matches(fct_replace)) %>% 
    rename_at(vars(matches('_fct$')), ~ str_remove(., '_fct$'))
    
  return(df)
}
