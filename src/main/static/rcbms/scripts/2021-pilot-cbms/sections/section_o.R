# Section O ==============================================
print('Processing Section O...')

section_o <- hpq_data$SECTION_O %>%
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  select(case_id, pilot_area, starts_with('O'), -contains('SPECIFY')) %>% 
  collect()

d_o <- section_o %>% 
  filter(O1 == 1, O2 == 1) %>% 
  select(starts_with('O')) %>% 
  select(where(notAllBlank))

# Answer in O1 is NA
cv_crime_o1 <- section_o %>% 
  filter(is.na(O1)) %>% 
  select(case_id, pilot_area, O1)

# ===================================================
# O1 not in the valueset
cv_crime_o1_not_in_vs <- section_o %>% 
  filter(!(O1 %in% c(1:6, NA))) %>% 
  select(case_id, pilot_area, O1)
# ===================================================

# Answer in O2 is NA with answer in c_O3
cv_crime_o2_na <- section_o %>% 
  select(case_id, pilot_area, O2, starts_with('O3_')) %>%
  filter(O2 == 2, rowSums(select(., c(O3_01:O3_12)), na.rm = T) > 0)

#Answer in O2 is 2 with answer in O3
cv_crime_o2_2 <- section_o %>% 
  select(case_id, pilot_area, O2) %>%
  filter(!(O2 %in% c(1, 2)))

# ====================================================
o_list <- list()
o3_letters <- c(LETTERS[1:11], 'Z')
for(i in seq_along(o3_letters)) {
  
  o3_var <- paste0('O3_', sprintf('%02d', i))

  for(j in 4:7) {
    o3_var_item <- paste0('O', j, '_', o3_letters[i], '_')
    
    o_list[[paste0('cv_crime_', tolower(o3_letters[i]), '_', j, '_na')]] <- section_o %>% 
      select(case_id, pilot_area, contains(c(o3_var, o3_var_item))) %>%
      filter(
        eval(as.name(o3_var)) == 1, 
        rowSums(select(., contains(o3_var_item)), na.rm = T) == 0
      )
  
    o_list[[paste0('cv_crime_', tolower(o3_letters[i]), '_', j)]] <- section_o %>% 
      select(case_id, pilot_area, contains(c(o3_var, o3_var_item))) %>% 
      filter(
        eval(as.name(o3_var)) == 2, 
        rowSums(select(., contains(o3_var_item)), na.rm = T) > 0
      )
  }
  
  o3_var_8 <- paste0('O8_', o3_letters[i], '_')
  o3_var_7 <- paste0('O7_', o3_letters[i], '_')
  
  d_o7 <- section_o %>% 
    mutate_at(vars(contains(o3_var_7)), as.integer) %>% 
    mutate_at(vars(contains(o3_var_7)), ~ if_else(. == 1L, ., 0L))
    
  o_list[[paste0('cv_crime_', tolower(o3_letters[i]), '_', 8, '_na')]] <- d_o7 %>% 
    select(case_id, pilot_area, contains(c(o3_var, o3_var_8))) %>% 
    filter(
      eval(as.name(o3_var)) == 1,
      rowSums(select(., contains(o3_var_7)), na.rm = T) > 0,
      rowSums(select(., contains(o3_var_8)), na.rm = T) == 0
    )
  
  o_list[[paste0('cv_crime_', tolower(o3_letters[i]), '_', 8)]] <- d_o7 %>% 
    select(case_id, pilot_area, contains(c(o3_var, o3_var_8))) %>% 
    filter(
      eval(as.name(o3_var)) == 2, 
      rowSums(select(., contains(o3_var_7)), na.rm = T) == 0,
      rowSums(select(., contains(o3_var_8)), na.rm = T) > 0
    )
  
  
}

list2env(o_list, envir = .GlobalEnv)
rm(o_list, section_o)

# print('Section O complete!')