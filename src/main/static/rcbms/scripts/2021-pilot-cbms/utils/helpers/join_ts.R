join_ts <- function(data, expand, m, filter = 1) {
  n <- data.frame(
    line_number = paste0(sprintf('%02d', seq(1:26))),
    type = LETTERS[1:26]
  )
  
  df <- data %>% 
    select(case_id, {{expand}}, {{m}}) %>% 
    filter({{expand}} == filter) %>% 
    mutate(type = str_split({{m}}, '')) %>% 
    select(-{{m}}) %>% 
    unnest(type) %>% 
    filter(str_trim(type) != '') %>% 
    left_join(n, by = 'type') %>% 
    mutate(case_id_m = paste0(case_id, line_number)) %>% 
    select(case_id_m, {{expand}}) %>% 
    distinct(case_id_m, {{expand}})
    
  return(df)
}
