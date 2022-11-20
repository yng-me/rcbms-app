pivot_ts <- function(data, ..., code_ref) {

  code_refs <- get_code_ref(code_ref) %>% 
    na.omit()
  
  data %>% 
    group_by(...) %>% 
    count() %>% 
    ungroup() %>% 
    rename(code = 2) %>% 
    full_join(code_refs, by = 'code') %>% 
    arrange(code) %>% 
    select(everything(), -code) %>% 
    pivot_wider(
      names_from = label,
      values_from = n,
      values_fill = 0
    ) %>% 
    na.omit()
}
