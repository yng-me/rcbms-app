list_prop_ts <- function(
    data, 
    indicator, 
    list, 
    labels = NULL, 
    code_refs = NULL, 
    func = 'prop_ts',
    code_ref = NULL,
    side_effect = NULL,
    unlist = FALSE,
    ...
) {
  
  df <- list()
  func_eval <- eval(as.name(func))
  
  
  for(i in 1:length(list)) {
    
    colname <- list[i]
    
    if(!is.null(labels)) colname <- labels[i]
    
    var <- list[i]
    code <- code_refs[i]
    new_data <- data
    
    if(!is.null(code_refs)) {
      
      if(!is.na(code)) {
        
        code_ref_value <- get_code_ref(code)
        
        new_data <- data %>% 
          mutate(code = as.integer(!!as.name(var))) %>% 
          left_join(code_ref_value, by = 'code') %>% 
          arrange(code)
        
        var <- 'label'
      }
    }
    
    if(func == 'prop_ts_m') {
      df_ts <- new_data %>% 
        func_eval({{var}}, {{indicator}}, label = colname, code_ref = code_ref, ...)
      
    } else {
      df_ts <- new_data %>% 
        func_eval(!!as.name(var), {{indicator}}, label = colname, ...) 
    }
    
    if(unlist == T) {
      df[[colname]]  <- df_ts %>% 
        mutate(stub = colname) %>% 
        select(stub, everything()) %>% 
        rename(grouping = 2)# %>% 
        #filter(grouping != 'Total')
    } else {
      
      if(!is.null(side_effect)) {
        func_side_effect <- eval(as.name(side_effect))
        df_ts <- df_ts %>% func_side_effect()
      }
      
      df[[colname]]  <- df_ts
    }
      
  }
  
  if(unlist == T) {
    df <- do.call('rbind', df) %>% 
      #filter(!(grouping == 'Total' & stub != colname)) %>% 
      mutate(grouping = if_else(is.na(grouping), 'Missing / No Response', grouping)) %>% 
      tibble() 
  }
  
  return(df)
}





