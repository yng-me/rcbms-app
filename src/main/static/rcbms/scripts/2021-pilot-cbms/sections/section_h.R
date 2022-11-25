
print('Processing Section H...')

section_h_hh <- hpq_data$SECTION_H %>% 
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  select(case_id, pilot_area, starts_with('H')) %>% 
  collect()  %>% 
  mutate_at(
    vars(matches(c('^H4_MAJOR_', '^H4_CODE_', '^H4_NAME_', '^H2_SUSTENANCE'), '^H9_MONTH_')), 
    ~ as.character(str_trim(as.character(.)))
  )

# ===========================================================================
# Regular household with no response in H01
cv_h01_na <- section_h_hh %>% 
  filter(is.na(H1_GOODS)) %>% 
  select(case_id, pilot_area, H1_GOODS)

# H01 not in the value set
cv_h01_not_in_vs <- section_h_hh %>% 
  filter(!(H1_GOODS %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, H1_GOODS)

# ===========================================================================
# Yes in H01 but no response in H02
cv_h02_blank <- section_h_hh %>% 
  filter(H1_GOODS == 1, H2_SUSTENANCE == '') %>% 
  select(case_id, pilot_area, H1_GOODS, H2_SUSTENANCE)

# ===========================================================================
# H02 not in the value set
cv_h02_not_in_vs <- section_h_hh %>% 
  filter(H1_GOODS == 1, !grepl('([A-E]){1,5}', H2_SUSTENANCE) & H2_SUSTENANCE != '') %>% 
  select(case_id, pilot_area, H1_GOODS, H2_SUSTENANCE)

# ===========================================================================
h3_list <- list()
h3_seq <- paste0('H3_ENTRE_', sprintf('%02d', seq(1:22)))

for(i in seq_along(h3_seq)) {
  h3_name_not_in_vs <- paste0('cv_h03_entrep_', letters[i], '_not_in_vs')
  h3_name_na <- paste0('cv_h03_entrep_', letters[i], '_na')
  
  # Not in the value set
  h3_list[[h3_name_not_in_vs]] <- section_h_hh %>% 
    filter(!(eval(as.name(h3_seq[i])) %in% c(1, 2, NA))) %>% 
    select(case_id, pilot_area, !!as.name(h3_seq[i]))
  
  # Missing answer (NA)
  h3_list[[h3_name_na]] <- section_h_hh %>% 
    filter(is.na(eval(as.name(h3_seq[i])))) %>% 
    select(case_id, pilot_area, !!as.name(h3_seq[i]))
}

# ===========================================================================
# No entrep activities but with answer in H4_MAJOR
cv_h04_no_entrep_with_response <- section_h_hh %>% 
  mutate(s = rowSums(select(., matches('H3_ENTRE_\\d{2}')), na.rm = T)) %>% 
  filter(s == 44, H4_MAJOR != '') %>% 
  select(case_id, pilot_area, H4_MAJOR, matches('H3_ENTRE_\\d{2}'))

# ===========================================================================
# With entrep but no answer in H4_MAJOR
cv_h04_entrep_no_response <- section_h_hh %>% 
  mutate(s = rowSums(select(., matches('H3_ENTRE_\\d{2}')), na.rm = T)) %>% 
  filter(s < 44, H4_MAJOR == '') %>%
  select(case_id, pilot_area, matches('H3_ENTRE_\\d{2}'), H4_MAJOR)

h4_list <- list()
for(i in 1:3) {
  
  h4_data <- section_h_hh %>% 
    filter(
      rowSums(select(., matches('H3_ENTRE_\\d{2}')), na.rm = T) < 44,
      !!as.name(paste0('H4_CODE_', i)) != '' | !!as.name(paste0('H4_NAME_', i)) != ''
    )
  
  h4_list[[paste0('cv_h05_psic_', i)]] <- h4_data %>%
    filter(!!as.name(paste0('H4_CODE_', i)) == '' && 
             !!as.name(paste0('NAME_', i)) == '' &&
             !!as.name(paste0('PSIC_', i)) == '') %>% 
    select(case_id, pilot_area, matches(paste0('H[45]_(CODE|NAME|PSIC)_', i)))
  
  # H06 - Ecommerce
  h4_list[[paste0('cv_h06_ecom_', i, '_missing')]] <- h4_data %>% 
    filter(!(!!as.name(paste0('H6_ENTRE_', i)) %in% c(1, 2))) %>% 
    select(case_id, pilot_area, matches(paste0('H[46]_(CODE|NAME|ENTRE)_', i)))
  
  # H07 - Social Media
  h4_list[[paste0('cv_h07_social_', i, '_missing')]] <- h4_data %>% 
    filter(!(!!as.name(paste0('H7_SOCIAL_MEDIA_', i)) %in% c(1, 2))) %>% 
    select(case_id, pilot_area, matches(paste0('H[47]_(CODE|NAME|SOCIAL_MEDIA)_', i)))
  
  # H08 - Year
  h4_list[[paste0('cv_h08_year_', i, '_missing')]] <- h4_data %>% 
    filter(!(!!as.name(paste0('H8_YEAR_STARTED_', i)) %in% c(1:2021))) %>% 
    select(case_id, pilot_area, matches(paste0('H[48]_(CODE|NAME|YEAR_STARTED)_', i)))
  
  # # H09 - Months
  # h4_list[[paste0('cv_h09_month_', i, '_missing')]] <- h4_data %>% 
  #   filter(!(grepl('[A-L]+', eval(!!as.name(paste0('H9_MONTH_', i)))) | !!as.name(paste0('H9_MONTH_', i))) == 'M') %>% 
  #   select(case_id, pilot_area, matches(paste0('H[49]_(CODE|NAME|MONTH)_', i)))
  
  # H10 - Workers
  h4_list[[paste0('cv_h10_workers_', i, '_missing')]] <- h4_data %>% 
    filter(
      !(!!as.name(paste0('H10A_', i)) >= 0 & !!as.name(paste0('H10B_', i)) >= 0 & !!as.name(paste0('H10C_', i)) >= 0) |
        is.na(rowSums(select(., matches(paste0('H10[A-C]_', i)))))
    ) %>% 
    select(case_id, pilot_area, matches(paste0('H(4_|10)(CODE|NAME|[A-C])_', i)))
  
  # H10 - Workers
  h4_list[[paste0('cv_h10_workers_count_', i)]] <- h4_data %>% 
    mutate(
      check = if_else(!!as.name(paste0('H10A_', i)) + !!as.name(paste0('H10B_', i)) == !!as.name(paste0('H10C_', i)), 1, 0)
    ) %>% 
    filter(check == 0) %>% 
    select(case_id, pilot_area, matches(paste0('H(4_|10)(CODE|NAME|[A-C])_', i)))
  
  # H11 - Registered at
  h4_list[[paste0('cv_h11_reg_', i, '_missing')]] <- h4_data %>% 
    filter(!(grepl('[A-FX]+', !!as.name(paste0('H11_AGENCY_', i))))) %>% 
    select(case_id, pilot_area, matches(paste0('H(4|11)_(CODE|NAME|AGENCY)_', i)))
}

list2env(h3_list, envir = .GlobalEnv)
list2env(h4_list, envir = .GlobalEnv)
rm(h3_list, h4_list, section_h_hh, h4_data)
