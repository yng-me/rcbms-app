full_join_ts <- function(data, var, ...) {
  data %>% 
    filter_reg_ts() %>% 
    mutate(case_id_m = paste0(case_id, sprintf('%02d', as.integer({{var}})))) %>% 
    inner_join(dplyr::select(hpq_individual, case_id_m, line_number, age, sex, age_group_fct, ...), by = 'case_id_m') 
}
