# 38-52. ==============================================================================
# Not a valid value
#g_list <- list()
#g_letters <- paste0('G1_', LETTERS[1:14])
#for(i in seq_along(g_letters)) {
#  g1_name <- paste0('cv_', tolower(g_letters[i]), '_na')
#  g_list[[g1_name]] <- section_f_ang_g %>% 
#    filter(is.na(eval(as.name(g_letters[i]))), is.na()) %>% 
#    select(case_id, pilot_area, !!as.name(g_letters[i]))
#}

cv_g_missing <- section_f_ang_g %>% 
  filter(
    rowSums(select(., matches('G1_[A-N]')), na.rm = T) == 0, 
    is.na(TOTALFOOD) | TOTALFOOD == 0
  ) %>% select(case_id, pilot_area, matches('G1_[A-N]'), TOTALFOOD)


#list2env(g_list, envir = .GlobalEnv)
#rm(g_list, f2_list, section_f_ang_g)

print('Section G complete!')