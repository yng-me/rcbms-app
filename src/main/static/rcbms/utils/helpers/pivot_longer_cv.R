pivot_longer_cv <- function(data, ..., vars, count) {
  
  df_all <- list()
  
  for(i in 1:count) {
    
    f <- paste0(sprintf('%02d', i))
    
    if(count < 10) f <- i
    
    var <- paste0(vars, f, '$')
    
    df_all[[i]] <- data  %>% 
      select(1:17, ..., matches(var)) %>% 
      rename_at(vars(matches(var)), ~ str_replace(., paste0(f, '$'), ''))
  }
  
  df <- do.call('rbind', df_all)
  
  return(df)
}