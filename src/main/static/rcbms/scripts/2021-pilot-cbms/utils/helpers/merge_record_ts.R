
merge_record_ts <- function(data, list, ...) {
  
  letters <- data.frame(
    letter = LETTERS[1:26],
    value = c(1:26)
  )
  
  l <- list()
  for(i in 1:length(list)) {
    l[[i]] <- data %>% 
      select(case_id, !!as.name(list[i])) %>% 
      filter(!is.na(eval(parse(text = list[i])))) %>% 
      mutate_all(str_trim) %>% 
      mutate(letter = strsplit(!!as.name(list[i]), '')) %>% 
      unnest(letter) %>% 
      filter(!is.na(letter)) %>% 
      left_join(letters, by = 'letter') %>% 
      mutate(case_id_m = paste0(case_id, sprintf('%02d', value))) %>% 
      select(case_id, case_id_m) 
  }

  df <- do.call('rbind', l) %>% tibble() %>% 
    distinct(case_id_m, ...) %>% 
      mutate(match = 1)
  
  return(df)

}
