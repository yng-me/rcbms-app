get_code_ref <- function(code_ref) {
  
  #unknown <- data.frame(label = 'Unknown', code = NA) %>% tibble()
  
  ref_codes %>%
    filter(list_name == code_ref) %>%
    transmute(label = label, code = as.integer(value)) %>% 
    arrange(code) %>% 
    #bind_rows(unknown) %>% 
    distinct(label, .keep_all = T)
}

#join_ts <- function(data, by) {
#  
#  code_ref <- ref_codes %>% 
#    filter(list_name == by) %>% 
#    select(label, value)
#  
#  data %>% left_join(code_ref, by = 'value') %>% 
#    arrange(value) %>% 
#    select(label, everything(), -value)
#}

recode_ts <- function(data, code_ref) {
  
  code_refs <- get_code_ref(code_ref)
  
  df <- data %>% 
    rename(code = 1) %>%
    mutate(code = as.integer(code)) %>% 
    full_join(code_refs, by = 'code') %>%
    arrange(code) %>% 
    select(label, everything(), -code) %>% 
    mutate_at(vars(1), ~ replace_na(., 'Unknown')) %>% 
    mutate_at(vars(2:ncol(.)), ~ replace_na(., 0)) 
}


remove_unknown_ts <- function(data) {
  
  df <- data %>% 
    rename_all(~ if_else(grepl('^NA_?.*', .), str_replace(., 'NA_?', 'Unknown'), .)) %>% 
    filter(!(.[[1]] == 'Unknown' & rowSums(select(., where(is.numeric)), na.rm = T) == 0)) 
  
  with_unknown <- df %>% 
    select(contains('Unknown')) 
  
  if(ncol(with_unknown) > 0) {
    
    zero_sum <- with_unknown %>% 
      summarise(s = sum(.[[1]], na.rm = T)) %>% 
      pull(s)
    
    zero_sum_boolean <- zero_sum[1] == 0
    
    if(zero_sum_boolean == TRUE) {
      df <- df %>% select(-contains('Unknown'))
    } 
  }
  
  return(df)
}
  
remove_na_ts <- function(data) {
  data %>% 
    mutate_at(vars(1), ~ replace_na(., 'Unknown')) %>% 
    #mutate_if(is.numeric, ~ replace_na(., 0)) %>% 
    filter(!(.[[1]] == 'Unknown' & rowSums(select(., where(is.numeric)), na.rm = T) == 0)) 
}

rename_na_ts <- function(data, remove_zero = T) {
  
  with_unknown_cols <- data %>% 
    select(contains('Unknown')) 
  
  if(ncol(with_unknown_cols) == 0) {
    df <- data %>% rename_all(~ if_else(grepl('NA_?$', .), str_replace(., 'NA_?', 'Unknown'), .))
  } else {
    df <- data
  }
  
  df <- df %>% 
    remove_na_ts %>% 
    tibble()
  
  if(remove_zero == T) {
    df <- df %>% 
      select(where(~ any(. != 0))) 
  }
  
  return(df)
}










