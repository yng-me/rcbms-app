ref_housing <- hpq_data$SECTION_R %>% 
  filter_reg_ts() %>% 
  select(-contains('SPECIFY')) %>% 
  mutate(
    with_tv_service = if_else(grepl('[a-eA-E]', R17), 1, 2),
    floor_area = case_when(
      R7 < 10 ~ 1,
      R7 < 30 ~ 2,
      R7 < 50 ~ 3,
      R7 < 80 ~ 4,
      R7 < 120 ~ 5,
      R7 < 150 ~ 6,
      R7 < 200 ~ 7,
      R7 >= 200 ~ 8,
      TRUE ~ 9
    ),
    year_constructed = case_when(
      R10_1 >= 2020 ~ 1,
      R10_1 > 2010 ~ 2,
      R10_1 > 2000 ~ 3,
      R10_1 > 1990 ~ 4,
      R10_1 > 1980 ~ 5,
      R10_1 > 1970 ~ 6,
      R10_1 > 1960 ~ 7,
      R10_1 > 1950 ~ 8,
      R10_1 > 1940 ~ 9,
      R10_1 > 1930 ~ 10,
      R10_1 > 1920 ~ 11,
      R10_1 > 1910 ~ 12,
      R10_1 > 1900 ~ 13,
      R10_1 <= 1900 ~ 14,
      TRUE ~ 98
    )
  ) %>%
  mutate(
    r01_fct = factor_ts(R1, code_ref = 'r01'),
    r03_fct = factor_ts(R3, code_ref = 'r03'),
    r04_fct = factor_ts(R4, code_ref = 'r04'),
    r10_fct = factor_ts(R10, code_ref = 'r10'),
    r07_floor_area_fct = factor_ts(floor_area, code_ref = 'r07'),
    r12_electricity_fct = factor_ts(R12, c(1, 2), c('With Electricity', 'No Electricity')),
    r10_year_constructed_fct = factor_ts(year_constructed, code_ref = 'r10.1'),
    r17_with_tv_service_fct = factor_ts(with_tv_service, c(1, 2), c('With Television Service', 'No Television Service'))
  )
