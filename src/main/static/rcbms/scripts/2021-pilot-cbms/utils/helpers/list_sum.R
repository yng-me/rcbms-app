list_sum <- function(
    data, 
    ..., 
    total_src,
    rename_total = 'Households Affected by Calamity',
    sort_by = NULL
) {
  
  get_t <- function(x, p = NULL) {
    
    if(is.null(p)) {
      t <- {{total_src}} %>% 
        group_by(name) %>% 
        summarise(n = sum(n))
    } else {
      t <- {{total_src}} %>% 
        filter(!!as.name(d) == p) %>% 
        ungroup() %>% 
        select(-1)
    }
    
    x %>% 
      pivot_longer(-1) %>% 
      pivot_wider(names_from = 1, values_from = value, values_fill = 0) %>% 
      inner_join(t, by = 'name') %>% 
      select(1, n, everything()) %>% 
      mutate_if(is.numeric, list(percent = ~ 100 * (. / n ))) %>% 
      select(-contains('n_percent')) %>% 
      rename_ts %>% 
      rename(
        'Calamity' = 1,
        (!!as.name(rename_total)) := 2
      )
  }
  
  df <- list()
  
  if(!is.null(sort_by)) {
    df_all <- data %>% 
      group_by(..., !!as.name(sort_by)) %>% 
      summarise_if(is.numeric, sum) %>%
      arrange(!!as.name(sort_by)) %>% 
      select(-contains(sort_by))
  } else {
    df_all <- data %>% 
      group_by(...) %>% 
      summarise_if(is.numeric, sum)
  }
  
  df[[current_area]] <- df_all %>% get_t
  
  for(b in 1:length(brgys)) {
    
    if(!is.null(sort_by)) {
      df_d <- data %>% 
        filter(!!as.name(d) == brgys[b]) %>% 
        group_by(..., !!as.name(sort_by)) %>% 
        summarise_if(is.numeric, sum) %>% 
        arrange(!!as.name(sort_by)) %>% 
        select(-contains(sort_by))
    } else {
      df_d <- data %>% 
        filter(!!as.name(d) == brgys[b]) %>% 
        group_by(...) %>% 
        summarise_if(is.numeric, sum)
    }
     
    df[[brgys[b]]] <- df_d %>% get_t(brgys[b])
     
  }
  
  return(df)
  
}