# ====================================================================
section_c <- hpq_individual %>%
  filter(HSN < 7777, RESULT_OF_VISIT == 1) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A07AGE, starts_with('C'), -case_id_m)

# 1. =================================================================
# age is less than 5 but with response in literacy
cv_literacy_age <- section_c %>% 
  filter(!is.na(C01READ), age_computed < 5 & age_computed >= 0) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C01READ)

# 2. =================================================================
# age is greater than 5 but without response in literacy
cv_literacy_age_na <- section_c %>% 
  filter(is.na(C01READ), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C01READ, C02HGC, C05SPECIFY)

# 3. =================================================================
# age is greater than 5 but response in literacy is not in the valueset
cv_literacy_age_valueset <- section_c %>% 
  filter(!(C01READ %in% c(1, 2, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C01READ)

# 4. =================================================================
# with C02 but no C02HGC
cv_hgc_c02blankC02hgc <- section_c %>% 
  filter(!is.na(C02), is.na(C02HGC), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C02, C02HGC)

# 5. =================================================================
# with C02 is not equal to first digit of C02HGC
cv_hgc_c02neC02hgc <- section_c %>% 
  filter(!is.na(C02HGC)) %>% 
  mutate(
    C02HGC1st = if_else(nchar(C02HGC) == 5, as.integer(substr(C02HGC, 1, 1)), 0L),
    check_c02c02hgc1st = if_else(C02 == C02HGC1st, 1, 0)
  ) %>% 
  filter(check_c02c02hgc1st == 0) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C02, C02HGC)

# 6. =================================================================
# with C02HGC but no C02
cv_hgc_c02hgcblankC02 <- section_c %>% 
  filter(!is.na(C02HGC), is.na(C02), age_computed > 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C02, C02HGC)

# 7. =================================================================
# age is less than 5 but with response in HGC
cv_hgc_age <- section_c %>% 
  filter(!is.na(C02), age_computed < 5 & age_computed >= 0) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C02, C02HGC)

# 8. =================================================================
## age is greater than 5 but without response in HGC
cv_hgc_age_na <- section_c %>% 
  filter(is.na(C02), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C02, C02HGC)

# 9. =================================================================
# age is greater than 5 but response in HGC is not in the valueset
cv_hgc_age_valueset <- section_c %>% 
  filter(C02 < 0 & C02 > 8, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C02, C02HGC)

# 10. ================================================================
# hgc > 24015 (high school graduate), but not literate
cv_hgc_literacy <- section_c %>% 
  filter(C01READ == 2, C02HGC >= 24015, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C01READ, C02HGC)

# 11. ================================================================
# hgc vs age cross (young achievers?)
cv_hgc_age_cross <- section_c %>% 
  filter(
    (age_computed <= 9 & age_computed >= 5 & C02HGC >= 10018) | 
    (age_computed <= 14 & age_computed >= 10 & C02HGC >= 24015) |
    (age_computed <= 19 & age_computed >= 15 & C02HGC >= 69999) | 
    (age_computed <= 24 & age_computed >= 20 & C02HGC > 89999)
  ) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C02, C02HGC)

# 12. ================================================================
# age is not between 3 to 24 but with response in school attendance
cv_schoolattendance_age <- section_c %>% 
  filter(!is.na(C03ATTEND), age_computed > 24 | age_computed < 3) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND)

# 13. ================================================================
# age is between 3 to 24 but without response in school attendance  
cv_schoolattendance_age_na <- section_c %>% 
  filter(is.na(C03ATTEND), age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND)

# 14. ================================================================
# age is is between 3 to 24 but response in school attendance is not in the valueset
cv_schoolattendance_valueset <- section_c %>% 
  filter(!(C03ATTEND %in% c(1, 2, NA)), age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND)

# 15. ================================================================
# age is not between 3 to 24 but with response in school type
cv_school_age <- section_c %>% 
  filter(!is.na(C04SCHOOL), age_computed > 24 | age_computed < 3) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C04SCHOOL)

# 16. ================================================================
# age is between 3 to 24 and currently attending school but without response in school type  
cv_school_age_na <- section_c %>% 
  filter(is.na(C04SCHOOL), C03ATTEND == 1, age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C04SCHOOL)

# 17. ================================================================
# age is between 3 to 24 and not currently attending school but with response in school type  
cv_school_age_notna <- section_c %>% 
  filter(!is.na(C04SCHOOL), C03ATTEND == 2, age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C04SCHOOL)

# 18. ================================================================
# age is between 3 to 24 but response in school type is not in the valueset
cv_school_valueset <- section_c %>% 
  filter(!(C04SCHOOL %in% c(1, 2, 3, NA)), age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C04SCHOOL)

# 19. ================================================================
# with C05CURGRADE but no C05SPECIFY
cv_curgrade_c05cgblankC05spec <- section_c %>% 
  filter(!is.na(C05CURGRADE), C03ATTEND == 1, age_computed >= 3 & age_computed <= 24, is.na(C05SPECIFY)) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C05CURGRADE, C05SPECIFY)

# 20. ================================================================
# C05HGC is not equal to first digit of C05specify
cv_hgc_c05hgc_specify <- section_c %>%
  filter(!is.na(C05CURGRADE), C03ATTEND == 1, age_computed >= 3 & age_computed <= 24) %>% 
  mutate(check_specify = if_else(nchar(C05SPECIFY) == 5, as.integer(substr(C05SPECIFY, 1, 1)), 0L)) %>% 
  filter(check_specify != C05CURGRADE) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C05CURGRADE, C05SPECIFY)

# 21. ================================================================
# with blank C05CURGRADE but with C05SPECIFY
cv_curgrade_c05specblankC05cg <- section_c %>% 
  filter(!is.na(C05SPECIFY), C03ATTEND == 1, is.na(C05CURGRADE), age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C05CURGRADE, C05SPECIFY)

# 22. ================================================================
# age is not between 3 to 24 but with response in curgrade
cv_curgrade_age <- section_c %>% 
  filter(!is.na(C05CURGRADE), age_computed > 24 | age_computed < 3) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C05CURGRADE)

# 23. ================================================================
# age is between 3 to 24 and currently attending school but without response in curgrade  
cv_curgrade_age_na <- section_c %>% 
  filter(is.na(C05CURGRADE), C03ATTEND == 1, age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C05CURGRADE)

# 24. ================================================================
# age is between 3 to 24 and not currently attending school but with response in curgrade   
cv_curgrade_age_notna <- section_c %>% 
  filter(!is.na(C05CURGRADE), C03ATTEND == 2, age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C05CURGRADE)

# 25. ================================================================
# age is between 3 to 24 but response in school type is not in the valueset
cv_curgrade_valueset <- section_c %>% 
  filter(!(C05CURGRADE %in% c(0:8, NA)), age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C05CURGRADE)

# 26. ================================================================
# curgrade vs age cross
cv_curgrade_age_cross <- section_c %>% 
  filter(
    (age_computed < 5 & C05SPECIFY > 10012) | 
    (age_computed <= 9 & age_computed >= 5 & C05SPECIFY >= 10018) |
    (age_computed <= 14 & age_computed >= 10 & C05SPECIFY >= 24015) |
    (age_computed <= 19 & age_computed >= 15 & C05SPECIFY >= 69999) | 
    (age_computed <= 24 & age_computed >= 20 & C05SPECIFY >= 89999)
  ) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C05CURGRADE, C05SPECIFY) 

# 27. ================================================================
# curgrade is greater or equal to hgc
cv_curgrade_hgc_equal <- section_c %>%
  filter(!(C02HGC %in% c(10003:10006) | C05SPECIFY %in% c(10003:10006))) %>% 
  filter(C02HGC >= C05SPECIFY) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C05SPECIFY, C02HGC) 

# 28. ================================================================
# age is not between 3 to 24 but with response in reason for not attending school
cv_reasonnoschool_age <- section_c %>% 
  filter(!is.na(C06NOTATTEND), age_computed > 24 | age_computed < 3) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C06NOTATTEND)

# 29. ================================================================
# age is between 3 to 24 and not currently attending school but without response in reason for not attending school  
cv_reasonnoschool_age_na <- section_c %>% 
  filter(is.na(C06NOTATTEND), C03ATTEND == 2, age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C06NOTATTEND)

# 30. ================================================================
# age is between 3 to 24 and currently attending school but with response in reason for not attending school 
cv_reasonnosch_attend_notna <- section_c %>% 
  filter(!is.na(C06NOTATTEND), C03ATTEND == 1, age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C06NOTATTEND)

# 31. ================================================================
# age is between 3 to 24 but response in reason for not attending school is not in the valueset
cv_reasonnosch_valueset <- section_c %>% 
  filter(!(C06NOTATTEND %in% c(0:13, 99, NA)), C03ATTEND == 2, age_computed >= 3 & age_computed <= 24) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C03ATTEND, C06NOTATTEND)

# C-2 ==================================================================================

## ================================== C07TVET ================================== ##
### age is less than 15 but with response in C07
cv_c07_notblank <- section_c %>% 
  filter(!is.na(C07TEACH), age_computed < 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C07TEACH)

### age is 15 years and over but no response in C07
cv_c07_blank <- section_c %>% 
  filter(is.na(C07TEACH), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C07TEACH)

### response in c07 is not in the valueset
cv_c07_valueset <- section_c %>% 
  filter(!(C07TEACH %in% c(1,2, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C07TEACH)

## ================================== C08TECHVOC ================================== ##

## age is less than 15 but with response in C08
cv_c08_notblank <- section_c %>% 
  filter(!is.na(C08TECHVOC), age_computed < 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C08TECHVOC)

### age is 15 years and over but no response in C08
cv_c08_blank <- section_c %>% 
  filter(is.na(C08TECHVOC), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C08TECHVOC)

### response in C08 is not in the valueset
cv_c08_valueset <- section_c %>% 
  filter(!(C08TECHVOC %in% c(1,2, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, C08TECHVOC)

## ================================== C09 ================================== ##

cv_c09_skills_na <- section_c %>% 
  mutate(s = rowSums(select(., matches('C09[A-QZ]')))) %>% 
  filter(C07TEACH == 1 | C08TECHVOC == 1, is.na(s)) %>% 
  select(case_id, pilot_area, C07TEACH, C08TECHVOC, matches('C09[A-QZ]'))

cv_c09_skills_not_na <- section_c %>% 
  mutate(s = rowSums(select(., matches('C09[A-QZ]')))) %>% 
  filter(C07TEACH == 2 & C08TECHVOC == 2, !is.na(s)) %>% 
  select(case_id, pilot_area, C07TEACH, C08TECHVOC, matches('C09[A-QZ]'))

# ==============================================================================
# Not in the value set

c09_not_in_vs <- list()
c09_na <- list()
c09_letters <- c(LETTERS[1:17], 'Z')
c09_letters <- paste0('C09', c09_letters)

for(i in seq_along(c09_letters)) {
  c09_name <- paste0('cv_', tolower(c09_letters[i]), '_not_in_vs')
  c09_na[[c09_name]] <- section_c %>% 
    filter(!(eval(as.name(paste(c09_letters[i]))) %in% c(1, 2, NA))) %>% 
    select(case_id, pilot_area, !!as.name(paste(c09_letters[i])))
}

for(i in seq_along(c09_letters)) {
  c09_name <- paste0('cv_', tolower(c09_letters[i]), '_na')
  c09_not_in_vs[[c09_name]] <- section_c %>% 
    filter(C07TEACH == 1 | C08TECHVOC == 1, is.na(eval(as.name(paste(c09_letters[i]))))) %>% 
    select(case_id, pilot_area, !!as.name(paste(c09_letters[i])))
}

list2env(c09_not_in_vs, envir = .GlobalEnv)
list2env(c09_na, envir = .GlobalEnv)

rm(c09_not_in_vs, c09_na, section_c)

cv_c02_hgc_group1 <- hpq_individual %>%
  filter(age_computed >= 10 & age_computed <= 14, C02HGC >= 24024) %>%
  select(case_id, LINENO, age_computed, C02, C02HGC)

cv_c02_hgc_group2 <- hpq_individual %>%
  filter(age_computed >= 15 & age_computed <= 19, C02HGC >= 69998) %>%
  select(case_id, LINENO, age_computed, C02, C02HGC)

cv_C03ATTEND1 <- hpq_individual %>%
  filter(age_computed %in% c(3:4), C03ATTEND == 1, C05CURGRADE >= 1) %>%
  select(case_id, LINENO, age_computed, C03ATTEND, C05CURGRADE)

cv_C03ATTEND2 <- hpq_individual %>%
  filter(age_computed %in% c(5:11), C03ATTEND == 1, C05CURGRADE >= 2) %>%
  select(case_id, LINENO, age_computed, C03ATTEND, C05CURGRADE)

cv_C03ATTEND3 <- hpq_individual %>%
  filter(age_computed %in% c(12:15), C03ATTEND == 1, C05CURGRADE >= 5) %>%
  select(case_id, LINENO, age_computed, C03ATTEND, C05CURGRADE)

cv_C03ATTEND4 <- hpq_individual %>%
  filter(age_computed %in% c(16:17), C03ATTEND == 1, C05CURGRADE >= 6) %>%
  select(case_id, LINENO, age_computed, C03ATTEND, C05CURGRADE)

cv_C03ATTEND5 <- hpq_individual %>%
  filter(age_computed %in% c(18:24), C03ATTEND == 1, C05CURGRADE >= 8) %>%
  select(case_id, LINENO, age_computed, C03ATTEND, C05CURGRADE)

cv_c06_reason_not_in_school_male_pregnant <- hpq_individual %>%
  filter(age_computed %in% c(3:24), A05SEX == 2, C03ATTEND == 2, C06NOTATTEND == 3) %>%
  select(case_id, LINENO, age_computed, A05SEX, C03ATTEND, C06NOTATTEND)

cv_c06_reason_5_years_old_employed <- hpq_individual %>%
  filter(age_computed <= 5, C03ATTEND == 2, C06NOTATTEND == 6) %>%
  select(case_id, LINENO, age_computed, C03ATTEND, C06NOTATTEND, E01WORK)


print('Section C complete!')