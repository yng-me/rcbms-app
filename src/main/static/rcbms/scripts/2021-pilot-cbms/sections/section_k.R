
print('Processing Section K...')

section_k <- hpq_data$SECTION_K %>%
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>%
  select(case_id, pilot_area, matches('K[1-8]')) %>% 
  collect()

k_na <- list()
k_not_in_vs <- list()

for(i in 1:8) {
  k_na[[paste0('cv_k', i, '_na')]] <- section_k %>% 
    filter(is.na(eval(as.name(paste0('K', i))))) %>% 
    select(case_id, pilot_area, !!as.name(paste0('K', i)))
}

for(i in 1:8) {
  k_not_in_vs[[paste0('cv_k', i, '_not_in_vs')]] <- section_k %>% 
    filter(!(eval(as.name(paste0('K', i)))) %in% c(1, 2, 8, NA)) %>% 
    select(case_id, pilot_area, !!as.name(paste0('K', i)))
}

list2env(k_not_in_vs, envir = .GlobalEnv)
list2env(k_na, envir = .GlobalEnv)
rm(k_not_in_vs, k_na, section_k)

