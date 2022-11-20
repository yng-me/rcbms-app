
list_cv <- function(data, output_name, ...) {
  
  if(nrow(data) == 0) {
    df <- tibble(label = output_name, n = 0)
    return(df)
  }
  
  p <- data %>% 
    mutate(p = str_replace(pilot_area, '^.*, ', '')) %>% 
    distinct(pilot_area, .keep_all = T)
  
  cv <- list()
  
  for(i in 1:nrow(p)) {
    cv[[p$p[i]]] <- data %>% 
      filter(pilot_area == p$pilot_area[i]) %>% 
      select(case_id, pilot_area, brgy_name, ...) %>% 
      rename(
        'Case ID' = 1,
        'Pilot Area' = 2,
        'Barangay' = 3
      )
  }
  
  if(nrow(data) > 0) {
    formatted_date <- paste0(
      sprintf('%02d', day(today())), ' ', 
      month(today(), label = TRUE, abbr = FALSE), ' ',
      year(today())
    )
    
    new_dir <- paste0('exports/Validation/As of ', formatted_date)
    
    if_else(!dir.exists(new_dir), dir.create(new_dir, showWarnings = F), F)
    
    export_path <- paste0('./', new_dir, '/', output_name, ' (as of ', formatted_date, ').xlsx')
    
    write.xlsx(cv, export_path, overwrite = T)
  }
  
  n <- do.call('rbind', cv) %>% nrow
  
  df <- tibble(label = output_name, n = n)
  
  return(df)
  
}
