ref_wash <- hpq_data$SECTION_Q %>% 
  filter_reg_ts() %>% 
  select(-contains('SPECIFY')) %>% 
  mutate(
    Q1 = if_else(is.na(Q1), 98L, Q1),
    Q3 = if_else(is.na(Q3), 98L, Q3),
    Q14 = if_else(is.na(Q14), 98L, Q14),
    water_distance = case_when(
      Q1 %in% c(1, 9, 10) | Q2 == 0 ~ 1,
      Q2 < 10 ~ 2,
      Q2 < 100 ~ 3,
      Q2 < 500 ~ 4,
      Q2 < 1000 ~ 5,
      Q2 >= 1000 ~ 6
    ),
    improved_dw = if_else(
      Q3 %in% c(11:14, 21, 31, 41, 51, 61, 71) | 
        (Q3 %in% c(72, 91, 92) & !(Q4 %in% c(32, 42, 81, 99))), 1, 2),
    time_to_obtain_water = case_when(
      Q5 == 3 & Q6 >= 998 ~ 8,
      Q5 == 3 & Q6 >= 30 ~ 4,
      Q5 == 3 & Q6 > 0 ~ 3,
      Q5 == 3 & Q6 == 0 ~ 2,
      TRUE ~ 1
    ),
    service_level_dw = case_when(
      Q3 %in% c(81, 99) ~ 5,
      Q3 %in% c(32, 42) ~ 4,
      improved_dw == 1 & time_to_obtain_water >= 4 ~ 3,
      improved_dw == 1 & time_to_obtain_water %in% c(2, 3) ~ 2,
      TRUE ~ 1
    ),
    toilet = case_when(
      Q14 %in% c(95) ~ 4,
      Q14 %in% c(14, 15, 23, 41, 51, 71, 98, 99) ~ 3,
      Q19 == 1 ~ 2,
      TRUE ~ 1
    ),
    water_sufficiency = case_when(
      Q10 == 2 ~ 0,
      Q10 == 8 ~ 8,
      Q10 == 1 & Q11 == 1 ~ 1, 
      Q10 == 1 & Q11 == 2 ~ 2, 
      Q10 == 1 & Q11 == 3 ~ 3, 
      Q10 == 1 & Q11 == 8 ~ 8, 
      Q10 == 1 & Q11 == 9 ~ 9,
      TRUE ~ 8
    ),
    availabe_soap = if_else(Q25 == 1 | (Q28 == 1 & Q29 == 1), Q30, 'X'),
    service_level_hw = case_when(
      Q23 %in% c(4, 5, 9) ~ 3,
      Q23 %in% c(1, 2, 3) & Q25 == 2 ~ 2,
      TRUE ~ 1
    )
  ) %>% 
  mutate(
    q01_main_water_source_fct = factor_ts(Q1, code_ref = 'q01'),
    q02_water_distance_fct = factor_ts(water_distance, code_ref = 'q02'),
    q03_main_dw_fct = factor_ts(Q3, code_ref = 'q03_q04'),
    q03_improved_dw_fct = factor_ts(improved_dw, c(1, 2), c('Improved', 'Unimproved')),
    q04_service_level_dw_fct = factor_ts(service_level_dw, c(1:5), c('Safely managed', 'Basic', 'Limited', 'Unimproved', 'Surface water')),
    q05_time_to_obtain_water_fct = factor_ts(time_to_obtain_water, code_ref = 'q05.1'),
    q11_water_sufficiency_fct = factor_ts(water_sufficiency, code_ref = 'q11'),
    q14_toilet_fct = factor_ts(Q14, code_ref = 'q14'),
    q14_toilet_service_level_fct = factor_ts(toilet, code_ref = 'q14.1'),
    q23_handwashing_fct = factor_ts(Q23, code_ref = 'q23'),
    q23_service_level_hw_fct = factor_ts(service_level_hw, code_ref = 'q23.1')
  )
  