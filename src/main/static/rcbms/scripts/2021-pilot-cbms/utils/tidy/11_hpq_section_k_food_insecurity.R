ref_food_insecurity <- hpq_data$SECTION_K %>% 
  filter(case_id %in% ref_rov_reg) %>% 
  collect() %>% 
  select(case_id, pilot_area, brgy_name, matches('^K[1-8]')) %>% 
  mutate_at(vars(matches('^K[1-8]')), as.integer) %>% 
  mutate_at(vars(matches('^K[1-8]')), ~ if_else(. == 1L, ., 0L)) %>% 
  rename(
    K1_WORRIED = K1,
    K2_HEALTHY = K2,
    K3_FEWFOOD = K3,
    K4_SKIPPED = K4,
    K5_ATELESS = K5,
    K6_RANOUT = K6,
    K7_HUNGRY = K7,
    K8_WHLDAY = K8
  ) %>% 
  mutate(score = rowSums(select(., matches('^K[1-8]')), na.rm = T)) 
