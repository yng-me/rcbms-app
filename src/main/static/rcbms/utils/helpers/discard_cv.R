discard_cv <- function(data) {
  data %>% 
    nest() %>% 
    mutate(n = map_int(data, nrow)) %>% 
    filter(n > 1) %>% 
    mutate(data = map(data, distinct)) %>% 
    mutate(n = map_int(data, nrow)) %>% 
    filter(n > 1) %>% 
    select(-n) %>% 
    unnest(data)
}