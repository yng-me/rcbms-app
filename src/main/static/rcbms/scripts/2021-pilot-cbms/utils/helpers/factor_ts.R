factor_ts <- function(..., code_ref = NULL, is_char = F) {
  
  if(is.null(code_ref)) {
    
    factor(..., ordered = T)
    
  } else {
    
    if(is_char == T) {
      code <- ref_codes %>%
        filter(list_name == code_ref) %>% 
        mutate(level = str_trim(value)) %>% 
        select(level, label)
      
    } else {
      
      code <- ref_codes %>%
        filter(list_name == code_ref) %>% 
        mutate(level = as.integer(value)) %>% 
        select(level, label)
      
    }

    factor(..., levels = code$level, labels = code$label, ordered = T)
  }
}