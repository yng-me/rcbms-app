filter_reg_ts <- function(data, remove_geo = T, is_arrow = T) {
  df <- data %>% 
    filter(pilot_area %in% current_area_filter) %>% 
    filter(case_id %in% ref_rov_reg)
  
  if(remove_geo == T) df <- df %>% select(-c(4:11))
  if(is_arrow == T) df <- df %>% collect()
  
  return(df)
}
