print('Processing Section D...')

section_d <- hpq_individual %>%
  filter(HSN < 7777, RESULT_OF_VISIT == 1) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A07AGE, age_computed, starts_with('D'))

# Checking 15 years old and below with answer
cv_registered_below_15 <- section_d %>% 
  filter(age_computed < 15, !is.na(D01REGVOTER)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, D01REGVOTER)

# Checking registered 15 years old and over without answer in D01REGVOTER
cv_registered_15_and_over_na <- section_d %>% 
  filter(is.na(D01REGVOTER) , age_computed >= 15) %>% 
  select(case_id, pilot_area, LINENO, age_computed, A01HHMEM, D01REGVOTER)

# Checking registered 15 years old and over answered yes in D01REGVOTER but without answer in D02VOTE
cv_yes_01_woanswer_02 <- section_d %>% 
  filter(D01REGVOTER == 1, is.na(D02VOTE) , age_computed >= 15) %>% 
  select(case_id, pilot_area, LINENO, age_computed, A01HHMEM, D01REGVOTER, D02VOTE)

# Checking 15 years old and over without answer in attend the last Barangay Assembly
cv_attend_15_and_over_na <- section_d %>% 
  filter(is.na(D03ATTEND) , age_computed >= 15) %>% 
  select(case_id, pilot_area, LINENO, age_computed, A01HHMEM, D03ATTEND)

# Checking answered no in 03 with  answer in 04 
cv_no_03_wanswer_04 <- section_d %>% 
  filter(D03ATTEND == 2, !(D041NOTATTEND %in% c(1, 2, 3, 9))) %>%
  select(case_id, pilot_area, LINENO, age_computed, A01HHMEM, D03ATTEND, D041NOTATTEND)

# D-2 ============================================================================
# check consistency if answers in D01 is not in the value set or blank
cv_d01_regvoter <- section_d %>%
  filter(!(D01REGVOTER %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, D01REGVOTER)

# check consistency if answers in D02 is not in the value set or blank
cv_d02_vote <- section_d %>%
  filter(!(D02VOTE %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, D02VOTE)  

# check consistency if answers in D03 is not in the value set or blank
cv_d03_attend <- section_d %>%
  filter(!(D03ATTEND %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, D03ATTEND)  

# check consistency if answers in D04 is not blank
cv_d04_not_attend <- section_d %>% 
  filter(!(D041NOTATTEND %in% c(1, 2, 3, 9, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, D041NOTATTEND)

# check consistency if answers in D05 is not in the value set or blank
cv_d05_suggestions <- section_d %>%
  filter(!(D05SUGGESTIONS %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, D05SUGGESTIONS)

# check consistency if answers in D06 is not in the value set or blank
cv_d06_volunteer <- section_d %>%
  filter(!(D06VOLUNTEER %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, D06VOLUNTEER) 

# check consistency if answers in D07 is not in the value set or blank
cv_d07_receive <- section_d %>%
  filter(!(D07RECEIVE %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, D07RECEIVE) 

# check consistency if answers in D08 is not blank
cv_d08 <- section_d %>% 
  filter(D06VOLUNTEER == 1, str_trim(D08) == '') %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, D08)


rm(section_d)
