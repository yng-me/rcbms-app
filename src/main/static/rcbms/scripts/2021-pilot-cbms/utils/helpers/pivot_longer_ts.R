pivot_longer_ts <- function(data, pattern, filter = NULL) {
  
  if(!is.null(filter)) {
    data <- data %>% filter(eval(as.name(filter)) == 1)
  }

  data %>% 
    select(case_id, matches(pattern)) %>% 
    mutate_at(vars(matches(pattern)), as.integer) %>% 
    pivot_longer(cols = matches(pattern), names_to =  'val') %>% 
    select(-val) %>% 
    filter(!is.na(value)) %>% 
    transmute(
      match = 1,
      value = value,
      case_id_m = paste0(case_id, sprintf('%02d', value))
    )
}
