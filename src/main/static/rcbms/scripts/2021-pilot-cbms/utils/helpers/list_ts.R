list_ts <- function(data, ..., func = 'freq_ts') {

  acceptable_func <- c('freq_ts', 'prop_ts', 'cross_ts')
  is_acceptable_func <- func %in% acceptable_func
  if(is_acceptable_func == FALSE) stop("list_ts only accepts func = 'freq_ts' | 'prop_ts' | 'cross_ts'")
  
  func_eval <- eval(as.name(func))
  
  df <- list()
  
  df[[current_area]] <- data %>% func_eval(...)
    
  for(b in 1:length(brgys)) {
    
    df_ne <- data %>% 
      filter(!!as.name(d) == brgys[b]) 
    
    if(nrow(df_ne) > 0) {
      df[[brgys[b]]] <- data %>% 
        filter(!!as.name(d) == brgys[b]) %>% 
        func_eval(...)
    }
  }
  
  return(df)
  
}