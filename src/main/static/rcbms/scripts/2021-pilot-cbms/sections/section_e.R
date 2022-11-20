section_e <- hpq_individual %>%
  filter(HSN < 7777, RESULT_OF_VISIT == 1, B06OFW %in% c(4, 5, 7)) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, starts_with('E'), B06OFW)


# B06 %in% c(1)

# check consistency if for 5 years old and over for E01 to E10
cv_five_years_old <- section_e %>%
  filter(age_computed < 5, E01WORK %in% c(1, 2)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E01WORK)

# check consistency if answers in E01 is not in the value set or blank
cv_e01_do_any_work <- section_e %>%
  filter(!(E01WORK %in% c(1, 2, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E01WORK)

# check consistency if No in E01, should skip E02
cv_e01_no_working_arrangement <- section_e %>% 
  filter(E01WORK == 2, !is.na(E02WORK), age_computed >= 5) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E01WORK, E02WORK)

# check consistency if answers in E02 is not in the value set or blank
cv_e02_working_arrangement <- section_e %>%
  filter(E01WORK == 1, !(E02WORK %in% c(1, 2, 3, 4, 5, 6, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E02WORK)

# check consistency if E02 have an entry and E03 should be blank
cv_e01_is_1_with_e03 <- section_e %>% 
  filter(E01WORK == 1 & E02WORK %in% c(1, 2, 3, 4, 5, 6), !is.na(E03NOTWORK), age_computed >= 5) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E01WORK, E02WORK, E03NOTWORK)

# check consistency if answers in E03 is not in the value set or blank
cv_e03_have_a_job <- section_e %>%
  filter(!(E03NOTWORK %in% c(1, 2, 3, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK)

# check consistency if answer in e03 is 2 or 3, and e22 should have an entry
cv_e03_no_job_engage_platform <- section_e %>%
  filter(E01WORK == 2, E03NOTWORK %in% c(2, 3), is.na(E22LOOK), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E01WORK, E03NOTWORK, E22LOOK)

#check consistency if answers in E04 is not in the value set or blank
cv_e04_engage_platform <- section_e %>%
  filter(!(E04ENGAGE %in% c(1,2, NA)), age_computed > 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E04ENGAGE)

# check consistency if answers in E05 is not in the value set or blank
cv_e05_work_location_prov <- section_e %>% 
  filter(E05PROVINCE < 0 & E05PROVINCE > 99, age_computed >= 5) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E05PROVINCE)

# check consistency if answers in E06 is not in the value set or blank
cv_e06_work_location_mun <- section_e %>% 
  filter(E06CITY < 0 & E06CITY > 99, age_computed >= 5) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E06CITY)

# check consistency if E07 is blank and E08 have an entry
cv_e07_e08_no_psoc <- section_e %>%
  filter(is.na(E07OCCUPATION) & (!is.na(E08PSOC) | E08PSOC <= 9999), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E07OCCUPATION, E08PSOC)

# check consistency if E09 is blank and E10 have an entry
cv_e09_e10_no_psic <- section_e %>%
  filter(is.na(E09INDUSTRY) & (!is.na(E10PSIC) | E10PSIC <= 9999), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E09INDUSTRY, E10PSIC)


cv_e08_psoc_0000 <- hpq_individual %>%
  filter(E08PSOC == 0, !is.na(E07OCCUPATION) | E01WORK == 1 | E03NOTWORK == 1) %>%
  select(case_id, pilot_area, LINENO, age_computed, E07OCCUPATION, E08PSOC, E09INDUSTRY, E10PSIC)

#===============================================================================

#PSIC still for verification
cv_e10_psic_0000 <- hpq_individual %>%
  filter(E10PSIC == 0, !is.na(E09INDUSTRY) | E01WORK == 1 | E03NOTWORK == 1) %>%
  select(case_id, LINENO, age_computed, E07OCCUPATION, E08PSOC, E09INDUSTRY, E10PSIC)


# check consistency if answers in E11 is not in the value set or blank
cv_e11_nature_employment <- section_e %>%
  filter(!(E11NATURE %in% c(1, 2, 3, NA)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E11NATURE)

# Check consistency. E13 should be greater than or equal to E12.
#cv_e12_e13_normal_and_total_work <-section_e %>% 
#  filter(E12NORMALHR > E13TOTALHRS, age_computed >=15) %>%
#  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E12NORMALHR, E13TOTALHRS)

# check consistency if answers in E14 is not in the value set or blank
cv_e14_more_hours_work <- section_e %>%
  filter(!(E14WANT %in% c(1, 2, NA)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E14WANT)

# check consistency if answers in E15 is not in the value set or blank
cv_e15_additional_work <- section_e %>%
  filter(!(E15ADDWORK %in% c(1, 2, NA)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E15ADDWORK)

#check consistency if answers in E16 is not in the value set or blank
cv_e16_class_of_worker <- section_e %>%
  filter(!(E16CLASSWORK %in% c(0, 1, 2, 3, 4, 5, 6, NA)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E16CLASSWORK)

#check consistency if answers in E17 is not in the value set or blank
cv_e17_basis_of_payment <- section_e %>%
  filter(!(E17BASIS %in% c(0, 1, 2, 3, 4, 5, 6, 7, NA)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E17BASIS)

# Check Consistency if code 0,1,2,5 in e16, e17 must have an entry!
cv_e16_e17_class_worker_payment <- section_e %>%
  filter(E16CLASSWORK %in% c(0, 1, 2, 5), is.na(E17BASIS), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E16CLASSWORK, E17BASIS)

# check Consistency if not code 0,1,2,5 in e16, e17 must be blank!
cv_e16_e17_class_worker_no_payment <- section_e %>%
  filter(!(E16CLASSWORK %in% c(0, 1, 2, 5, NA)), !is.na(E17BASIS), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E16CLASSWORK, E17BASIS)

# check Consistency if code 0,1,2,5 in e16, if e17 must have an entry!
# cv_e16_e17_class_payment_basic_pay <- section_e %>%
#   filter(E16CLASSWORK %in% c(0, 1, 2, 5), is.na(E17BASIS), age_computed >= 15) %>%
#   select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E16CLASSWORK, E17BASIS, E18BASIC)

# check Consistency if code 5,6,7 in e17, e18 must be blank!
cv_e17_e18_basis_no_basic_pay <- section_e %>%
  filter(E17BASIS %in% c(5, 6, 7), !is.na(E18BASIC), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E17BASIS, E18BASIC)

# check Consistency if not code 5,6,7 in e17, e18 must have an entry!
cv_e17_e18_basis_basic_pay <- section_e %>%
  filter(E17BASIS %in% c(0:4), is.na(E18BASIC), age_computed >=15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E17BASIS, E18BASIC)

# check consistency if answers in E19 is not in the value set or blank
cv_e19_have_other_job <- section_e %>%
  filter(!(E19OTHER %in% c(1, 2, NA)), age_computed >=15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E19OTHER)

# check Consistency if total hours is 40:48 hours, e21 must be blank!
cv_e20_worked_40_to_48_hrs <- section_e %>%
  filter(E20HRSPASTWEEK > 48 & E20HRSPASTWEEK < 40, is.na(E21REASON), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E20HRSPASTWEEK, E21REASON)

# check Consistency if total hrs worked for all jobs is >= total number of hours worked!
cv_e20_e13_total_and_total_all_work <- section_e %>% 
  filter(E20HRSPASTWEEK < E13TOTALHRS, age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E20HRSPASTWEEK, E13TOTALHRS)

# check Consistency if code 11:15,99 in E21 and E20 should be > 48 hours
cv_e21_worked_more_than_48 <- section_e %>%
  filter(!(E21REASON %in% c(11:15, 99)), E20HRSPASTWEEK > 48, E03NOTWORK == 1, age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E20HRSPASTWEEK, E21REASON)

# check Consistency if code 20:32 in E21 and E20 should be < 40 hours
cv_e21_worked_less_than_40 <- section_e %>%
  filter(!(E21REASON %in% c(20:32)), E20HRSPASTWEEK < 40, E03NOTWORK == 1, age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E20HRSPASTWEEK, E21REASON)

# check Consistency if e21 have an entry, e22 must be blank!
cv_e21_reason_look_for_work <- section_e %>%
  filter(!is.na(E21REASON), E22LOOK %in% c(1, 2), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E21REASON, E22LOOK)

# check Consistency if e03 is 2 or 3, e22 must not be blank!
cv_e22_look_for_work <- section_e %>%
  filter(E03NOTWORK == 2 | E03NOTWORK == 3, is.na(E22LOOK), age_computed >= 15) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E22LOOK)

# check consistency if answers in E23 is not in the value set or blank
cv_e23_reason_not_look_for_work <- section_e %>%
  filter(!(E23NOTLOOK %in% c(0:10, 99)), E03NOTWORK %in% c(2, 3), E22LOOK == 2, age_computed >=15) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM,  age_computed, E03NOTWORK, E23NOTLOOK)

# check Consistency if code 0,1,2,5 in e23, e24 must have an entry!
cv_e23_not_look_ever_work <- section_e %>%
  filter(E23NOTLOOK %in% c(0:5), is.na(E24AVAILABLE), E22LOOK == 2, E03NOTWORK %in% c(2, 3), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E23NOTLOOK, E24AVAILABLE)

# check Consistency if not code 0,1,2,5 in e23, e24 must be blank!
cv_e23_not_look_no_ever_work <- section_e %>%
  filter(E23NOTLOOK %in% c(6:10, 99), !is.na(E24AVAILABLE), E03NOTWORK %in% c(2, 3), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E23NOTLOOK, E24AVAILABLE)

# check consistency if E22 is N0, answers in E24 is in the value set
cv_e24_look_opportunity_for_work <- section_e %>%
  filter(!(E24AVAILABLE %in% c(1, 2)), E22LOOK == 1, E03NOTWORK %in% c(2, 3), age_computed >= 15) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E22LOOK, E23NOTLOOK, E24AVAILABLE)

# check consistency if E22 is No, should skip E23
cv_e24_opportunity_for_work <- section_e %>%
  filter(!(E24AVAILABLE %in% c(1, 2, NA)), E03NOTWORK %in% c(2, 3), age_computed >= 15) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E22LOOK, E23NOTLOOK, E24AVAILABLE)

# check Consistency if code 6,7,8,9,10,99 in e23, e25 must have an entry!
cv_e23_reason_not_look_1 <- section_e %>%
  filter(E23NOTLOOK %in% c(6:10, 99), is.na(E25ANYTIME), E03NOTWORK %in% c(2, 3), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E23NOTLOOK, E25ANYTIME)

#check consistency if answers in E25 is not in the value set or blank
cv_e25_ever_work <- section_e %>%
  filter(!(E25ANYTIME %in% c(1, 2)), E03NOTWORK %in% c(2, 3), age_computed >= 15) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E25ANYTIME)

# check Consistency if e25 have an entry, e26 must be blank!
cv_e25_ever_work_date <- section_e %>%
  filter(!is.na(E26MONTH) & E25ANYTIME == 2, E03NOTWORK %in% c(2, 3), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E25ANYTIME , E26MONTH)

#check consistency if answers in E26 is not in the value set or blank
cv_e26_date_last_worked <- section_e %>% 
  filter(!(E26MONTH %in% c(0:99)), !(E26YEAR %in% c(0:9999)), E25ANYTIME == 1, age_computed >= 5) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E25ANYTIME, E26MONTH, E26YEAR)

#check consistency if E27 is blank and E28 have an entry
cv_e27_e28_occ_psoc <- section_e %>%
  filter(is.na(E27LASTOCC), !is.na(E28PSOC) | E28PSOC <= 9999, E03NOTWORK %in% c(2, 3), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E03NOTWORK, E27LASTOCC, E28PSOC)

#check consistency if E29 is blank and E30 have an entry
cv_e29_e30_ind_psic <- section_e %>%
  filter(E25ANYTIME == 1, is.na(E29LASTINDUSTRY), !is.na(E30PSIC) | E30PSIC <= 9999, E03NOTWORK %in% c(2, 3), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, E29LASTINDUSTRY, E30PSIC)

#check consistency if B06OFW is 4,5, or 7 and E01 is Yes
cv_ofw <- section_e %>%
  filter(!(B06OFW %in% c(4, 5, 7)), E01WORK == 1) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, E01WORK)


rm(section_e)



print('Section E complete!')