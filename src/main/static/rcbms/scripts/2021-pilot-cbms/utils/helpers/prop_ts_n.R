colname_ts <- function(data, code_ref, pattern, filter_label) {
  
  code_refs <- ref_codes %>%
    filter(list_name == code_ref) %>%
    transmute(label = label, code = value)
  
  var <- str_split(pattern, '_', simplify = T)[1]
  
  code_refs_p <- ref_codes %>%
    filter(list_name == code_ref) %>%
    transmute(
      label = paste0('<Percent> ', label),
      code = paste0(var, '_', value, '_p')
    ) 
  
  code_refs <- ref_codes %>%
    filter(list_name == code_ref) %>%
    transmute(
      label = paste0('<Frequency> ', label),
      code = paste0(var, '_', value)
    ) %>% 
    bind_rows(code_refs_p)
  
  colnames(data) <- c(d_label, filter_label, code_refs$label)
  
  return(data)
  
}


prop_ts_n <- function(
    data, pattern, 
    filter = NULL, 
    code_ref = NULL, 
    type = 'default', 
    filter_label = 'Total Households',
    rename_total = 'Total Households',
    include_overall_total = F,
    individual_total = F
  ) {
  
  if(!is.null(filter)) {
    data <- data %>% filter(eval(as.name(filter)) == 1) 
  }
  
  join_with <- data %>% 
    group_by(!!as.name(d)) %>% 
    count() %>% 
    adorn_totals
  
  if(type == 'default') {
    df <- data %>% 
      select(!!as.name(d), matches(pattern)) %>% 
      mutate_at(vars(matches(pattern)), ~ if_else(. == 2L, 0L, .))
  } else if (type == 'count-based') {
    df <- data %>% 
      select(!!as.name(d), matches(pattern)) %>% 
      mutate_at(vars(matches(pattern)), ~ if_else(. > 0, 1L, 0L))
  }
  
  df <- df %>% 
    group_by(!!as.name(d)) %>% 
    summarise_at(vars(matches(pattern)), ~ sum(., na.rm = T)) %>% 
    adorn_totals() %>% 
    inner_join(join_with, by = d) %>% 
    mutate_at(
      vars(-c(1, n)),
      list(p = ~ (. / n) * 100)
    ) %>% 
    select(1, n, everything())
  
  if(!is.null(code_ref)) {
    df <- colname_ts(df, code_ref, pattern, filter_label)
  }
  
  if(!is.null(rename_total)) {
    df <- df %>% 
      rename((!!as.name(rename_total)) := 2)
  }
  
  if(include_overall_total == T) {
    
    count <- ref_hh_count
    count_label <- 'Number of Households'
    
    if(individual_total == T) {
      count <- ref_hh_member_count
      count_label <- 'Number of Household Members'
    }
    
    df <- df %>% 
      inner_join(count, by = d_label) %>% 
      select(1, t, everything()) %>% 
      rename((!!as.name(count_label)) := 2)
  }
  
  return(df %>% tibble())
}

