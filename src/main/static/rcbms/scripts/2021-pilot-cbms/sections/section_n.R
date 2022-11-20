section_n <- hpq_data$SECTION_N %>%
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  select(case_id, pilot_area, HSN, starts_with('N')) %>% 
  collect() 

# Not in the value set N1
cv_n01 <- section_n %>%
  filter(!(N1 %in% c(1, 2))) %>% 
  select(case_id, pilot_area, N1)

# Not in the value set N2
cv_n02_1 <- section_n %>%
  filter(N1 == 1, !(N2_A %in% c(1, 2)) | !(N2_B %in% c(1, 2)) | 
    !(N2_C %in% c(1, 2)) | !(N2_D %in% c(1, 2)) | !(N2_E %in% c(1, 2)) | !(N2_Z %in% c(1, 2))) %>% 
  select(case_id, pilot_area, N1, N2_A:N2_Z)

# Inconsistency checking in N1 vs. N2
cv_n02_2 <- section_n %>%
  mutate(sum_n2 = rowSums(select(., N2_A:N2_Z))) %>% 
  filter(N1 == 2, !(is.na(sum_n2) | sum_n2 == 12)) %>% 
  select(case_id, pilot_area, starts_with('N2_'))

# Not in the value set N3
cv_n03_1 <- section_n %>%
  filter(N1 == 1, !(N3 %in% c(1, 2))) %>% 
  select(case_id, pilot_area, N1, N3)

# Inconsistency checking in N1 vs. N3
cv_n03_2 <- section_n %>%
  filter(N1 == 2, !is.na(N3)) %>% 
  select(case_id, pilot_area, N1, N3)

# Not in the value set N4
cv_n04_1 <- section_n %>%
  filter(N1 == 1, N3 == 1, !(N4_A %in% c(1, 2)) | !(N4_B %in% c(1, 2)) | 
    !(N4_C %in% c(1, 2)) | !(N4_D %in% c(1, 2))) %>% 
  select(case_id, pilot_area, N1, N4_A:N4_D)

# Inconsistency checking in N1 or N3 vs N4
cv_n04_2 <- section_n %>%
  mutate(sum_n4_a = rowSums(select(., N4_A:N4_D))) %>% 
  filter(N1 == 2 | N3 == 2, !is.na(sum_n4_a)) %>% 
  select(case_id, pilot_area, N1, N3, starts_with('N4_'))

# Not in the value set N5
cv_n05_1 <- section_n %>%
  filter(N1 == 1, !(N5 %in% c(1, 2))) %>% 
  select(case_id, pilot_area, N1, N5)

# Inconsistency in between N1 vs N5
cv_n05_2 <- section_n %>%
  filter(N1 == 2, !is.na(N5)) %>% 
  select(case_id, pilot_area, N1, N5)

# Not in the value set N6
cv_n06_1 <- section_n %>%
  filter(N1 == 1, !(N6_A %in% c(1, 2)) | !(N6_B %in% c(1, 2)) | !(N6_C %in% c(1, 2)) | 
    !(N6_D %in% c(1, 2)) | !(N6_E %in% c(1, 2)) | !(N6_F %in% c(1, 2)) | !(N6_G %in% c(1, 2)),
  ) %>% 
  select(case_id, pilot_area, N1, N6_A:N6_G)

# Inconsistency in N1 vs N6
cv_n06_2 <- section_n %>%
  mutate(sum_n6 = rowSums(select(., N6_A:N6_G))) %>%
  filter(N1 == 2, !is.na(sum_n6)) %>% 
  select(case_id, pilot_area, N1, starts_with('N6_'))

# Not in the value set N7
cv_n07_1 <- section_n %>%
  filter(N1 == 1, N6_C == 1, !(N7_A %in% c(1, 2)) | !(N7_B %in% c(1, 2)) | 
    !(N7_C %in% c(1, 2)) | !(N7_D %in% c(1, 2)) | !(N7_E %in% c(1, 2)) | 
    !(N7_F %in% c(1, 2)) | !(N7_G %in% c(1, 2)) | !(N7_Z %in% c(1, 2))) %>%
  select(case_id, pilot_area, N1, N6_C, N7_A:N7_Z)

# Inconsistency in N1 vs. N7
cv_n07_2 <- section_n %>%
  mutate(sum_n7 = rowSums(select(., N7_A:N7_G))) %>%
  filter(N1 == 2, !is.na(sum_n7)) %>% 
  select(case_id, pilot_area, N1, starts_with('N7_'))

# Not in the value set N8
cv_n08_1 <- section_n %>%
  filter(N1 == 1, !(N8 %in% c(1, 2))) %>% 
  select(case_id, pilot_area, N1, N8)

# Inconsistency in N1 vs. N8
cv_n08_2 <- section_n %>%
  filter(N1 == 2, !is.na(N8)) %>% 
  select(case_id, pilot_area, N1, N8)

# Not in the value set N9
cv_n09_1 <- section_n %>%
  filter(N1 == 1, !(N9 %in% c(1, 2))) %>% 
  select(case_id, pilot_area, N1, N9)

# Inconsistency in N1 vs. N9
cv_n09_2 <- section_n %>%
  filter(N1 == 2, !is.na(N9)) %>% 
  select(case_id, pilot_area, N1, N9)

# Not in the value set N10
cv_n10_1 <- section_n %>%
  filter(N1 == 1, N9 == 1, rowSums(select(., matches('^N10_[A-C]$')), na.rm = T) == 0) %>%
  select(case_id, pilot_area, N1, N9, N10_A:N10_C)

cv_n10z <- section_n %>%
  filter(
    N1 == 1, N9 == 1, 
    is.na(N10_B) | N10_B == 0,
    is.na(N10_A) | N10_A == 0,
    (N10_C > 0 & str_trim(N10_C_SPECIFY) == '') | N10_C == 0 & str_trim(N10_C_SPECIFY) != ''
  ) %>% 
  select(case_id, pilot_area, N1, N9, N10_A, N10_B, N10_C, N10_C_SPECIFY)


rm(section_n)

print('Section N complete!')