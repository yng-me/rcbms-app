
print('Processing Section J...')

section_j_hh <- suppressWarnings(
  hpq_data$SECTION_J %>%
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  collect() %>% 
  mutate_at(
    vars(
      J02LNO_01:J02LNO_30, 
      J08_LNO_01:J08_LNO_30, 
      J21_LNO_01:J21_LNO_30, 
      J33_01:J33_30, 
      J06_LNO_01:J06_LNO_30,
      contains('J12_')
    ), 
    as.integer
  ) %>%
  mutate_at(vars(contains('J12_')), ~ if_else(. == 0L, 1L, .)) %>% 
  select(case_id, HSN, pilot_area, starts_with('J'), -contains('SPECIFY'))
)

with_female <- hpq_individual %>%
  mutate(with_female = if_else(A05SEX == 2, 1L, 0L)) %>% 
  group_by(case_id) %>% 
  summarise(with_female = max(with_female), .groups = 'drop') %>% 
  filter(with_female == 1)

d_j_sex <- section_j_hh %>% 
  left_join(with_female, by = 'case_id') %>% 
  select(case_id, pilot_area, with_female, J1:J14)

d_individual_ref <- hpq_individual %>% 
  filter(HSN < 7777) %>% 
  select(case_id_m, LINENO, A05SEX, age_computed) 

# ===============================================================================
# All male members but with answer in J01
cv_j01_no_females_with_ans <- d_j_sex %>% 
  filter(is.na(with_female), !is.na(J1)) %>% 
  select(case_id, pilot_area, J1)

# With female members but missing an answer in J01
cv_j01_with_females_but_na <- d_j_sex %>% 
  filter(with_female == 1, is.na(J1)) %>% 
  select(case_id, pilot_area, J1)

# J01 not in the value set
cv_j01_not_in_the_vs <- section_j_hh %>% 
  filter(!(J1 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J1)

# Not applicable but with answer
# cv_j2_is_2_but_with_ans <- section_j_hh %>%
 #  filter(J1 == 2, rowSums(select(., J02LNO_01:J02LNO_30), na.rm = T) > 0) %>% 
#  select(case_id, pilot_area, J1, J02LNO_01:J02LNO_30)

# J02 = 1 but value missing for J02
cv_j02_lineno_na <- section_j_hh %>%
  mutate_at(vars(J02LNO_01:J02LNO_30), as.integer) %>% 
  mutate(s = rowSums(select(., J02LNO_01:J02LNO_30), na.rm = T)) %>% 
  filter(J1 == 1, s == 0) %>% 
  select(case_id, pilot_area, J1, s, J02LNO_01:J02LNO_30)

# ==================
d_j1 <- section_j_hh %>% 
  filter(J1 == 1) %>% 
  select(J02LNO_01:J02LNO_30) %>% 
  select(where(notAllBlank))

j2_list <- list()
for(i in 1:length(d_j1)) {
  j2_list[[i]] <- section_j_hh %>% 
    select(
      case_id, pilot_area, J1,
      contains(c(paste0('J02LNO_', sprintf('%02d', i))))
    ) %>% 
    filter(J1 == 2, !is.na(!!as.name(paste0('J02LNO_', sprintf('%02d', i))))) %>% 
    rename(J02 = 4)
}
cv_j02_with_ans <- do.call('rbind', j2_list) %>% tibble()

# ===============================================================================
d_j2 <- hpq_data$SECTION_J2 %>% 
  collect() %>% 
  filter(pilot_area == eval_area, HSN < 7777) %>% 
  mutate(case_id_m = paste0(case_id, sprintf('%02d', as.integer(J02LNO)))) %>% 
  filter(!is.na(J02LNO)) %>% 
  left_join(d_individual_ref, by = 'case_id_m')

# male who gave birth
cv_j02_male_gave_birth <- d_j2 %>% 
  filter(A05SEX == 1) 

# gave birth below 10 years old
cv_j02_gave_birth_below_10 <- d_j2 %>% 
  filter(A05SEX == 2, age_computed < 10)

# gave birth 50 years old and above
cv_j02_gave_birth_50_above <- d_j2 %>% 
  filter(A05SEX == 2, age_computed > 49)

# J03 not in the value set (number of live births must be 1-10)
cv_j03_not_in_vs <- section_j_hh %>% 
  filter(J1 == 1) %>% 
  select(case_id, pilot_area, J1, J03_01:J03_30) %>% 
  pivot_longer(cols = J03_01:J03_30) %>% 
  filter(!(value %in% c(1:10, NA))) %>% 
  select(-name) %>%
  rename('Number of Live Births' = value)

cv_j04_month_not_in_vs <- section_j_hh %>% 
  filter(J1 == 1) %>% 
  select(case_id, pilot_area, J1, J04_MONTH_01:J04_MONTH_30) %>% 
  pivot_longer(cols = J04_MONTH_01:J04_MONTH_30) %>% 
  filter(!(value %in% c(1:12, 98, NA))) %>% 
  select(-name) %>% 
  rename('First Birth (Month)' = value)

cv_j04_year_not_in_vs <- section_j_hh %>% 
  filter(J1 == 1) %>% 
  select(case_id, pilot_area, J1, J04_YEAR_01:J04_YEAR_30) %>% 
  pivot_longer(cols = J04_YEAR_01:J04_YEAR_30) %>% 
  filter(!(value %in% c(1970:2021, 9998, NA))) %>% 
  select(-name) %>% 
  rename('First Birth (Year)' = value)

# ===============================================================================
# All male members but with answer in J05
cv_j05_no_females_with_ans <- d_j_sex %>% 
  filter(is.na(with_female), !is.na(J5)) %>% 
  select(case_id, pilot_area, J5)

# With female members but missing an answer in J05
cv_j5_with_females_but_na <- d_j_sex %>% 
  filter(with_female == 1, is.na(J5)) %>% 
  select(case_id, pilot_area, J5)

# J05 not in the value set
cv_j05_not_in_the_vs <- section_j_hh %>% 
  filter(!(J5 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J5)

# ===============================================================================
d_j6 <- section_j_hh %>% 
  filter(J5 == 1) %>% 
  select(J06_LNO_01:J06_LNO_30) %>% 
  select(where(notAllBlank))

j6_list <- list()
# j6_list_na <- list()
for(i in 1:length(d_j6)) {
  j6_list[[i]] <- section_j_hh %>% 
    select(
      case_id, pilot_area, J5,
      contains(c(paste0('J06_LNO_', sprintf('%02d', i))))
    ) %>% 
    filter(J5 == 2, !is.na(!!as.name(paste0('J06_LNO_', sprintf('%02d', i))))) %>% 
    rename(J06 = 4)

  #j6_list_na[[i]] <- section_j_hh %>% 
   # select(
    #  case_id, pilot_area, J5,
    #  contains(c(paste0('J06_LNO_', sprintf('%02d', i))))
    #) %>% 
    #filter(J5 == 1, is.na(!!as.name(paste0('J06_LNO_', sprintf('%02d', i))))) %>% 
    #rename(J06 = 4)
  
}
cv_j06_with_ans <- do.call('rbind', j6_list) %>% tibble()
#cv_j6_na <- do.call('rbind', j6_list_na) %>% tibble()

# J05 Not applicable but with answer in J06
#c_j6_is_2_but_with_ans <- section_j_hh %>%
 # filter(J5 == 2, rowSums(select(., J06_LNO_01:J06_LNO_30), na.rm = T) > 0) %>% 
  #select(case_id, pilot_area, J5, J06_LNO_01:J06_LNO_30)

# J05 = 1 but not answer in J06
cv_j06_lineno_na <- section_j_hh %>%
  mutate(s = rowSums(select(., J06_LNO_01:J06_LNO_30), na.rm = T)) %>% 
 filter(J5 == 1, s == 0 & str_trim(J6TLNO) == '') %>% 
 select(case_id, pilot_area, J5, J6TLNO, J06_LNO_01:J06_LNO_30) 

d_pregnant <- hpq_data$SECTION_J6 %>%
  collect() %>% 
  filter(pilot_area == eval_area, HSN < 7777) %>% 
  mutate(case_id_m = paste0(case_id, sprintf('%02d', as.integer(J06_LNO)))) %>% 
  filter(!is.na(J06_LNO)) %>% 
  left_join(d_individual_ref, by = 'case_id_m')

# Male breastfeeding
cv_j06_pregnant_male <- d_pregnant %>% 
  filter(A05SEX == 1)

# Breastfeeding below 10
cv_j06_pregnant_below_10 <- d_pregnant %>% 
  filter(age_computed < 10)

# Breastfeeding 50 and above
cv_j06_pregnant_50_above <- d_pregnant %>% 
  filter(age_computed > 49)

# ===============================================================================
# All male members but with answer in J07
cv_j07_no_females_with_ans <- d_j_sex %>% 
  filter(is.na(with_female), !is.na(J7)) %>% 
  select(case_id, pilot_area, J7)

# With female members but missing an answer in J07
cv_j07_with_females_but_na <- d_j_sex %>% 
  filter(with_female == 1, is.na(J7)) %>% 
  select(case_id, pilot_area, J7)

# J07 not in the value set
cv_j07_not_in_the_vs <- section_j_hh %>% 
  filter(!(J7 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J7)

# J08 Not applicable but with answer in J08
cv_j08_is_2_but_with_ans <- section_j_hh %>%
  filter(J7 == 2, rowSums(select(., J08_LNO_01:J08_LNO_30), na.rm = T) > 0) %>% 
  select(case_id, pilot_area, J7, J08_LNO_01:J08_LNO_30)

# J07 = 1 but not answer in J08
cv_j08_lineno_na <- section_j_hh %>%
  filter(J7 == 1, str_trim(J8TLNO) == '' & rowSums(select(., J08_LNO_01:J08_LNO_30), na.rm = T) == 0) %>% 
  select(case_id, pilot_area, J7, J8TLNO, J08_LNO_01:J08_LNO_30)

d_j8 <- hpq_data$SECTION_J8 %>% 
  collect() %>% 
  filter(pilot_area == eval_area, HSN < 7777) %>% 
  mutate(case_id_m = paste0(case_id, sprintf('%02d', as.integer(J08_LNO)))) %>% 
  filter(!is.na(J08_LNO)) %>% 
  left_join(d_individual_ref, by = 'case_id_m')

# Male breastfeeding
cv_j08_breastfeeding_male <- d_j8 %>% 
  filter(A05SEX == 1)

# Breastfeeding below 10
cv_j08_breastfeeding_below_10 <- d_j8 %>% 
  filter(age_computed < 10)

# Breastfeeding 50 and above
cv_j08_breastfeeding_50_above <- d_j8 %>% 
  filter(age_computed > 49)


# =================================================================================
# Former household member 

cv_j09_no_ans <- section_j_hh %>% 
  filter(is.na(J9)) %>% 
  select(case_id, pilot_area, J9)

# J01 not in the value set
cv_j09_not_in_the_vs <- section_j_hh %>% 
  filter(!(J9 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J9)


j9_list <- list()
for(i in 11:13) {
  # Not applicable but with answer
  j9_list[[paste0('cv_j', i,'_is_2_but_with_ans')]] <- section_j_hh %>%
    filter(J9 == 2, rowSums(select(., matches(paste0('J', i, '_\\d{2}'))), na.rm = T) > 0) %>% 
    select(case_id, pilot_area, J9, matches(paste0('J', i, '_\\d{2}')))
  
  # J09 = 1 but value missing for J11-J13
  j9_list[[paste0('cv_j', i, '_lineno_na')]] <- section_j_hh %>%
    filter(J9 == 1, rowSums(select(., matches(paste0('J', i, '_\\d{2}'))), na.rm = T) == 0) %>% 
    select(case_id, pilot_area, J9, matches(paste0('J', i, '_\\d{2}')))
}

list2env(j9_list, envir = .GlobalEnv)

cv_j11_not_in_vs <- section_j_hh %>% 
  filter(J9 == 1) %>% 
  select(case_id, pilot_area, J9, J11_01:J11_30) %>% 
  pivot_longer(cols = J11_01:J11_30) %>% 
  filter(!(value %in% c(1, 2, NA))) %>% 
  rename('Sex of Child or Baby' = value)

cv_j12_not_in_vs <- section_j_hh %>% 
  filter(J9 == 1) %>% 
  select(case_id, pilot_area, J9, J12_01:J12_30) %>% 
  pivot_longer(cols = J12_01:J12_30) %>% 
  filter(!(value %in% c(0:60, NA))) %>% 
  select(-name) %>%
  rename('Age in Months' = value)

cv_j13_not_in_vs <- section_j_hh %>% 
  filter(J9 == 1) %>% 
  select(case_id, pilot_area, J9, J13_01:J13_30) %>% 
  pivot_longer(cols = J13_01:J13_30) %>% 
  filter(!(value %in% c(1:10, 99, NA))) %>% 
  select(-name) %>%
  rename('Cause of Death' = value)


# =================================================================================
# Disability

cv_j14_no_ans <- section_j_hh %>% 
  filter(is.na(J14)) %>% 
  select(case_id, pilot_area, J14)

# J01 not in the value set
cv_j14_not_in_the_vs <- section_j_hh %>% 
  filter(!(J14 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J14)

# Not applicable but with answer
cv_j15_is_2_but_with_ans <- section_j_hh %>%
  filter(J14 == 2, rowSums(select(., J15_01:J15_30), na.rm = T) > 0) %>% 
  select(case_id, pilot_area, J14, J15_01:J15_30)

# J14 = 1 but value missing for J15
cv_j15_lineno_na <- section_j_hh %>%
  filter(J14 == 1, rowSums(select(., J15_01:J15_30), na.rm = T) == 0) %>% 
  select(case_id, pilot_area, J14, J15_01:J15_30)

cv_j16_not_in_vs <- section_j_hh %>% 
  filter(J14 == 1) %>% 
  select(case_id, pilot_area, J14, J16_01:J16_30) %>% 
  pivot_longer(cols = J16_01:J16_30) %>% 
  filter(str_trim(value) != '', !grepl('[A-HZ]+', str_trim(value))) %>% 
  select(-name) %>%
  rename('Type of Disability' = value)

cv_j17_not_in_vs <- section_j_hh %>% 
  filter(J9 == 1) %>% 
  select(case_id, pilot_area, J9, J17_01:J17_30) %>% 
  pivot_longer(cols = J17_01:J17_30) %>% 
  filter(!(value %in% c(1, 2, NA))) %>% 
  select(-name) %>%
  rename('Disability been Diagnosed' = value)

# =========================================================================
# Cancer Patient

cv_j18_no_ans <- section_j_hh %>% 
  filter(is.na(J18)) %>% 
  select(case_id, pilot_area, J18)

# J01 not in the value set
cv_j18_not_in_the_vs <- section_j_hh %>% 
  filter(!(J18 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J18)

# Not applicable but with answer
cv_j19_is_2_but_with_ans <- section_j_hh %>%
  filter(J18 == 2, rowSums(select(., J19_LNO_01:J19_LNO_30), na.rm = T) > 0) %>% 
  select(case_id, pilot_area, J18, J19_LNO_01:J19_LNO_30)

# J18 = 1 but value missing for J19
cv_j19_lineno_na <- section_j_hh %>%
  filter(J18 == 1, rowSums(select(., J19_LNO_01:J19_LNO_30), na.rm = T) == 0) %>% 
  select(case_id, pilot_area, J18, J19_LNO_01:J19_LNO_30)


# =========================================================================
# Cancer Survivor

cv_j20_no_ans <- section_j_hh %>% 
  filter(is.na(J20)) %>% 
  select(case_id, pilot_area, J20)

# J01 not in the value set
cv_j20_not_in_the_vs <- section_j_hh %>% 
  filter(!(J20 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J20)

# Not applicable but with answer
cv_j21_is_2_but_with_ans <- section_j_hh %>%
  filter(J20 == 2, rowSums(select(., J21_LNO_01:J21_LNO_30), na.rm = T) > 0) %>% 
  select(case_id, pilot_area, J20, J21_LNO_01:J21_LNO_30)

# J20 = 1 but value missing for J21
cv_j21_lineno_na <- section_j_hh %>%
  filter(J20 == 1,str_trim(J19TLNO) == ''  & rowSums(select(., J21_LNO_01:J21_LNO_30), na.rm = T) == 0) %>% 
  select(case_id, pilot_area, J20, J19TLNO, J21_LNO_01:J21_LNO_30)

# =========================================================================
# Rare Disease

cv_j22_no_ans <- section_j_hh %>% 
  filter(is.na(J22)) %>% 
  select(case_id, pilot_area, J22)

# J01 not in the value set
cv_j22_not_in_the_vs <- section_j_hh %>% 
  filter(!(J22 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J22)

# Not applicable but with answer
cv_j23_is_2_but_with_ans <- section_j_hh %>%
    filter(J22 == 2, rowSums(select(., J23_01:J23_30), na.rm = T) > 0) %>% 
    select(case_id, pilot_area, J22, J23_01:J23_30)

# J22 = 1 but value missing for J23
cv_j23_lineno_na <- section_j_hh %>%
  filter(J22 == 1, rowSums(select(., J23_01:J23_30), na.rm = T) == 0) %>% 
  select(case_id, pilot_area, J22, J23_01:J23_30)

cv_j24_not_in_vs <- section_j_hh %>% 
  filter(J22 == 1) %>% 
  select(case_id, pilot_area, J22, J24_01:J24_30) %>% 
  pivot_longer(cols = J24_01:J24_30) %>%
  filter(!(value %in% c(1, 2, NA))) %>% 
  select(-name) %>%
  rename('Rare Disease been Diagnosed' = value)

# ============================================================================
# PWD ID

cv_j28_no_ans <- section_j_hh %>% 
  filter(is.na(J28)) %>% 
  select(case_id, pilot_area, J28)

# J01 not in the value set
cv_j28_not_in_the_vs <- section_j_hh %>% 
  filter(!(J28 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J28)

# Not applicable but with answer
cv_j29_is_2_but_with_ans <- section_j_hh %>%
  filter(J28 == 2, rowSums(select(., J29_01:J29_30), na.rm = T) > 0) %>% 
  select(case_id, pilot_area, J28, J29_01:J29_30)

cv_j29_lineno_na <- section_j_hh %>%
  filter(J28 == 1, rowSums(select(., J29_01:J29_30), na.rm = T) == 0) %>% 
  select(case_id, pilot_area, J28, J29_01:J29_30)

cv_j30_not_in_vs <- section_j_hh %>% 
  filter(J28 == 1) %>% 
  select(case_id, pilot_area, J28, J30_01:J30_30) %>% 
  pivot_longer(cols = J30_01:J30_30) %>%
  filter(!(value %in% c(1, 2, NA))) %>% 
  select(-name) %>%
  rename('Shown PWD ID' = value)


# =======================================
d_j30 <- section_j_hh %>% 
  filter(J28 == 1) %>% 
  select(J30_01:J30_30) %>% 
  select(where(notAllBlank))

j31_list <- list()
for(i in 1:length(d_j30)) {
  j30_var <- paste0('J30_', sprintf('%02d', i))
  j31_var <- paste0('J31_', sprintf('%02d', i))
  j31_list[[i]] <- section_j_hh %>% 
    select(case_id, pilot_area, contains(c(j30_var, j31_var))) %>% 
    filter(!!as.name(j30_var) == 1, is.na(!!as.name(j31_var))) %>% 
    rename(J30 = 3, J31 = 4)
}

cv_j31_na <- do.call('rbind', j31_list) %>% tibble()

# =======================================

cv_j31_not_in_vs <- section_j_hh %>% 
  filter(J28 == 1) %>% 
  select(case_id, pilot_area, J28, J31_01:J31_30) %>% 
  pivot_longer(cols = J31_01:J31_30) %>%
  filter(!(value %in% c(1:10, NA))) %>% 
  select(-name) %>%
  rename('Disability in PWD ID' = value)


# =========================================================================
# Ill / Sick / Injured

cv_j32_no_ans <- section_j_hh %>% 
  filter(is.na(J32)) %>% 
  select(case_id, pilot_area, J32)

# J32 not in the value set
cv_j32_not_in_the_vs <- section_j_hh %>% 
  filter(!(J32 %in% c(1, 2, NA))) %>% 
  select(case_id, pilot_area, J32)

# Not applicable but with answer
cv_j33_is_2_but_with_ans <- section_j_hh %>%
  filter(J32 == 2, rowSums(select(., J33_01:J33_30), na.rm = T) > 0) %>% 
  select(case_id, pilot_area, J32, J33_01:J33_30)

cv_j33_lineno_na <- section_j_hh %>%
  filter(J32 == 1, rowSums(select(., J33_01:J33_30), na.rm = T) == 0) %>% 
  select(case_id, pilot_area, J32, J33_01:J33_30)

cv_j34_not_in_vs <- section_j_hh %>% 
  filter(J32 == 1) %>% 
  select(case_id, pilot_area, J32, J34_01:J34_30) %>% 
  pivot_longer(cols = J34_01:J34_30) %>%
  filter(!is.na(value), value < 1) %>% 
  select(-name) %>%
  rename('Number of Times Ill/Sick/Injured' = value)

cv_j37_not_in_vs <- section_j_hh %>% 
  filter(J32 == 1) %>% 
  select(case_id, pilot_area, J32, J37_01:J37_30) %>% 
  pivot_longer(cols = J37_01:J37_30) %>%
  filter(!(value %in% c(1:13, 99, NA))) %>% 
  select(-name) %>%
  rename('Recent Illness/Injury' = value)

cv_j38_not_in_vs <- section_j_hh %>% 
  filter(J32 == 1) %>% 
  select(case_id, pilot_area, J32, J38_01:J38_30) %>% 
  pivot_longer(cols = J38_01:J38_30) %>%
  filter(!(value %in% c(1, 2, NA))) %>% 
  select(-name) %>%
  rename('Avail Medical Treatment' = value)

# =======================================
# =======================================
d_j32 <- section_j_hh %>% 
  filter(J32 == 1) %>% 
  select(J33_01:J33_30) %>% 
  select(where(notAllBlank))

j36_list <- list()
j39_list <- list()
j40_list <- list()
j41_list <- list()
for(i in 1:length(d_j32)) {
  
  # J35 == 1 
  j36_list[[paste0('cd_j36_', i, '_na')]] <- section_j_hh %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('J35_', sprintf('%02d', i)), paste0('J36_', sprintf('%02d', i))))
    ) %>% 
    filter(
      !!as.name(paste0('J35_', sprintf('%02d', i))) == 1, 
      is.na(!!as.name(paste0('J36_', sprintf('%02d', i)))) | !!as.name(paste0('J36_', sprintf('%02d', i))) < 1
    ) %>% 
    rename(J35 = 3, J36 = 4)
  
  # J38 == 1 and J39 is NA
  j39_list[[paste0('cd_j39_', i, '_na')]] <- section_j_hh %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('J38_', sprintf('%02d', i)), paste0('J39_', sprintf('%02d', i))))
    ) %>% 
    filter(
      !!as.name(paste0('J38_', sprintf('%02d', i))) == 1, 
      str_trim(!!as.name(paste0('J39_', sprintf('%02d', i)))) != '',
      !grepl('[A-TZ]+', str_trim(!!as.name(paste0('J39_', sprintf('%02d', i)))))
    ) %>% 
    rename(J38 = 3, J39 = 4)

  # J38 == 1 and J40 is NA
  j40_list[[paste0('cd_j40_', i, '_na')]] <- section_j_hh %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('J38_', sprintf('%02d', i)), paste0('J40_', sprintf('%02d', i))))
    ) %>% 
    filter(
      !!as.name(paste0('J38_', sprintf('%02d', i))) == 1, 
      str_trim(!!as.name(paste0('J40_', sprintf('%02d', i)))) != '',
      !grepl('[A-HZ]+', str_trim(!!as.name(paste0('J40_', sprintf('%02d', i)))))
    ) %>% 
    rename(J38 = 3, J40 = 4)
    
  # J38 == 2
  j41_list[[paste0('cd_j41_', i, '_na')]] <- section_j_hh %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('J38_', sprintf('%02d', i)), paste0('J41_', sprintf('%02d', i))))
    ) %>% 
    filter(
      !!as.name(paste0('J38_', sprintf('%02d', i))) == 2, 
      !(!!as.name(paste0('J41_', sprintf('%02d', i))) %in% c(1:6, 9, NA))
    ) %>% 
    rename(J38 = 3, J41 = 4)
}

cv_j36_na <- do.call('rbind', j36_list) %>% tibble()
cv_j39_na <- do.call('rbind', j39_list) %>% tibble()
cv_j40_na <- do.call('rbind', j39_list) %>% tibble()
cv_j41_na <- do.call('rbind', j41_list) %>% tibble()
rm(j2_list, j6_list, j9_list, j31_list, j36_list, j39_list, j40_list, j41_list, d_j_sex, section_j_hh)

# ---------------------------------------------------------

section_a_reg <- hpq_individual %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1) %>% 
  mutate(A01HHMEM = str_trim(A01HHMEM)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, starts_with('A'))


ref_pwd <- hpq_data$SECTION_J15 %>% 
  filter(HSN < 7777, !is.na(J15), pilot_area == eval_area) %>% 
  collect() %>% 
  mutate(case_id_m = paste0(case_id, sprintf('%02d', J15))) %>% 
  select(case_id_m, J15) %>% 
  mutate(pwd_line_number = J15)

cv_a17_not_pwd <- section_a_reg %>%
  mutate(case_id_m = paste0(case_id, sprintf('%02d', LINENO))) %>% 
  filter_at(vars(matches('^A17[A-F]*')), any_vars(. > 3)) %>% 
  left_join(ref_pwd, by = 'case_id_m') %>% 
  select(case_id, pwd_line_number, matches('^A17[A-F]*')) %>% 
  filter(is.na(pwd_line_number)) 

cv_a17_pwd_functional <- section_a_reg %>% 
  mutate(case_id_m = paste0(case_id, sprintf('%02d', LINENO))) %>% 
  filter_at(vars(matches('^A17[A-F]*')), all_vars(. == 1)) %>% 
  inner_join(ref_pwd, by = 'case_id_m') %>% 
  select(case_id, pwd_line_number, matches('^A17[A-F]*')) 

cv_rare_disease <- hpq_data$SECTION_J23 %>% 
  filter(J25 == 99, HSN < 7777, !is.na(J25_SPECIFY), pilot_area == eval_area) %>% 
  select(case_id, J25, J25_SPECIFY) %>% 
  collect() 

# ---------------------------------------------------------


# print('Section J complete!')