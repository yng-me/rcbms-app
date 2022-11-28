
# Section E {.unnumbered}

section_e <- hpq$section_e %>% collect()
section_e_ofi <- section_e %>% filter(b06_ofi %in% c(4, 5, 7))

section_e_employed <- section_e %>%
  filter(b06_ofi %in% c(4, 5, 7), e01_work == 1 | e03_jobbus == 1)

section_e_not_employed <- section_e %>%
  filter(age >= 15, b06_ofi %in% c(4, 5, 7), e01_work == 2, e03_jobbus %in% c(2, 3))


### E01 to E10 - Less than 5 y/o and OFWs did any work for at least 1hour

## If less than 5 y/o and are OFWs (B06 = 1,2,3, or 6), E01 to E10 should NOT have any response.
(
  cv_e01_working_less_five_years_old <- section_e %>%
    filter(age < 5 | b06_ofi %in% c(1:3, 6)) %>% 
    filter_at(vars(matches('^e(0[1-9]|10).*')), any_vars(!is.na(.))) %>% 
    select_cv(b06_ofi, matches('^e(0[1-9]|10).*'))
)[[1]]


### E01 - Missing/invalid answer for E01 (did any work)

## If HH member is 5 y/o and over, answer in E01 did any work) should not be blank or must be in the value set.
(
  cv_e01_do_any_work <- section_e_ofi %>%
    filter(age >= 5, !(e01_work %in% c(1, 2))) %>%
    select_cv(e01_work, h = 'e01_work')
)[[1]]


### E02 - Did not have any work (E01=2) but have answer in working arrangement (E02) 

## If HH member did not do any work (E01=2), skip E02 (working arrangement).
(
  cv_e01_no_working_arrangement <- section_e_ofi %>% 
    filter(age >= 5, e01_work == 2, !is.na(e02_workarrange)) %>% 
    select_cv(e01_work, e02_workarrange, h = 'e02_workarrange')
)[[1]]


### E02 - Working arrangement is blank or not in the value set 

## If E01 (did any work) is 1 (Yes), E02 (working arrangement) should not be blank or must be in the value set.
(
  cv_e02_working_arrangement <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1, !(e02_workarrange %in% c(1:6))) %>%
    select_cv(
      e01_work,
      e02_workarrange, 
      e02_workarrange_fct, 
      h = c(
        'e01_work',
        'e02_workarrange',
        'e02_workarrange_fct'
        ) 
      )
)[[1]]


### E02 - With entry in E02 (working arrangement) but E03 (have a job or business) is not skipped   

## If E02 (working arrangement) has an entry, then E03 should be blanked.
(
  cv_e01_is_1_with_jobbus <- section_e_ofi %>% 
    filter(age >= 5, e01_work == 1, !is.na(e03_jobbus)) %>% 
    select_cv(e01_work, e02_workarrange, e03_jobbus, h = c('e02_workarrange','e03_jobbus'))
)[[1]]


### E03 - Missing/invalid answer for E03 (have a job or business)   

## If answer in E01 (did any work) is 2 (No), E03 should not be blank or must be in the value set.
(
  cv_e03_have_a_job <- section_e_ofi %>%
    filter(age >= 5, e01_work == 2, !(e03_jobbus %in% c(1:3))) %>%
    select_cv(e03_jobbus, h='e03_jobbus')
)[[1]]


### E04 - Engagement in online platform or mobile application is blank or not in the value set

## If answer in E01 is 1 (Yes) and/or E03 is 1 (Yes), E04 should not be blank or must be in the value set.
(
  cv_e04_engage_platform <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, !(e04_engage %in% c(1, 2))) %>%
    select_cv(e01_work, e03_jobbus, e04_engage, h = 'e04_engage')
)[[1]]


### E05 - Location of work is not in the value set

## Province and City/Mun code must be in the value set and must be correct.
(
  cv_e05_work_location_prov <- section_e_ofi %>% 
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, !(e05_provcitymuncode %in% c(0:9999))) %>% 
    select_cv(e01_work, e03_jobbus, e05_provcitymuncode, h = 'e05_provcitymuncode')
)[[1]]


### E07 and E08 - Primary occupation is not specified but with PSOC code

## If E08 (PSOC) has an entry, then E07 (primary occupation) must also have an entry.
(
  cv_e07_e08_no_psoc <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, is.na(e07_procc) | is.na(e08_procccode)) %>%
    select_cv(e01_work, e03_jobbus, e07_procc, e08_procccode, h = c('e07_procc','e08_procccode'))
)[[1]]


### E07 - Invalid entry for primary occupation

## Answer in E07 (primary occupation) must be valid.
(
  cv_e07_invalid <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, grepl(ref_invalid_keyword, e07_procc, ignore.case = T)) %>%
    select_cv(e01_work, e03_jobbus, e07_procc, e08_procccode, h = 'e07_procc')
)[[1]]



### E08 - PSOC is for further verification

## Check primary occupation specified in E07 and edit E08 (PSOC code) accordingly.
(
  cv_e07_e10_psic <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, e08_procccode == 0) %>%
    select_cv(e01_work, e03_jobbus, e07_procc, e08_procccode, h = 'e08_procccode')
)[[1]]


### E09 and E10 - Kind of industry is not specified but with PSIC code

## If E10 (PSIC) has an entry, then E09 (kind of industry) must also have an entry.
(
  cv_e07_e10_psic <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1,  is.na(e09_industry) | is.na(e10_industrycode)) %>%
    select_cv(e01_work, e03_jobbus, e09_industry, e10_industrycode, h = c('e09_industry','e10_industrycode'))
)[[1]]


### E09 - Invalid entry for kind of industry

## Answer in E09 (kind of industry) must be valid.
(
  cv_e09_invalid <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, grepl(ref_invalid_keyword, e09_industry, ignore.case = T)) %>%
    select_cv(e01_work, e03_jobbus, e09_industry, e10_industrycode, h = 'e10_industrycode')
)[[1]]


### E10 - PSIC is for further verification

## Check kind of industry specified in E09 and edit E10 (PSIC code) accordingly.
(
  cv_e07_e10_psic <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, e10_industrycode == 0) %>%
    select_cv(e01_work, e03_jobbus, e09_industry, e10_industrycode, h = c('e09_industry','e10_industrycode'))
)[[1]]


### E11 - Nature of Employment is blank or not in value set

## If answer in E01 and/or E03 is 1, E11 (nature of employment) must not be blank and must be in the value set.
(
  cv_e11_nature_employment <- section_e_employed %>%
    filter(age >= 15, !(e11_employ %in% c(1:3))) %>%
    select_cv(e01_work, e03_jobbus, e11_employ, h = 'e11_employ')
)[[1]]


### E12 - Working hours per day is less than 1 hour or more than 16 hours

## Check cases of less than 1 hr and more 16 working hrs per day, if correct, please provide justification/remarks.
(
  cv_e12_normal_w_hr <- section_e_employed %>% 
    filter(age >= 15, !(e12_pwhrs %in% c(1:16))) %>% 
    select_cv(e01_work, e03_jobbus, e12_pwhrs, h = 'e12_pwhrs')
)[[1]]


### E13 - Days of work is not valid

## Days of work must not be shorter than 1 day and must not exceed 7 days. 
(
  cv_e13_w_day <- section_e_employed %>% 
    filter(age >= 15, !(e13_pwdays %in% c(1:7))) %>% 
    select_cv(e01_work, e03_jobbus, e13_pwdays, h = 'e13_pwdays')
)[[1]]


### E14 - Total number of hours work during the past week is not valid

## Hours work must not be shorter than 1 hour and must not exceed 112 hours. 
(
  cv_e14_total_hr <- section_e_ofi %>% 
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, !(e14_pwtothrs %in% c(1:112))) %>% 
    select_cv(e01_work, e03_jobbus, e14_pwtothrs, h = 'e14_pwtothrs')
)[[1]]


### E15 - Response in E15 is not in the value set or blank

## If answer in E01 and/or E03 is 1, E15 (want more hrs of work) must not be blank and must be in the value set.
(
  cv_e15_more_hours_work <- section_e_employed %>%
    filter(age >= 15, e01_work == 1 | e03_jobbus == 1, !(e15_pwmorhrs %in% c(1, 2))) %>%
    select_cv(e01_work, e03_jobbus, e15_pwmorhrs, h = 'e15_pwmorhrs')
)[[1]]


### E16 - Response in E16 is not in the value set or blank

## If answer in E01 and/or E03 is 1, E16 (additional work) must not be blank and must be in the value set.
(
  cv_e16_additional_work <- section_e_employed %>%
    filter(age >= 15, e01_work == 1 | e03_jobbus == 1, !(e16_pwaddwork %in% c(1, 2))) %>%
    select_cv(e01_work, e03_jobbus, e16_pwaddwork, h = 'e16_pwaddwork')
)[[1]]


### E17 - Response in E17 is not in the value set or blank

## If answer in E01 and/or E03 is 1, E17 (first time worker) must not be blank and must be in the value set.
(
  cv_e17_first_job <- section_e_employed %>% 
    filter(age >= 15, e01_work == 1 | e03_jobbus == 1, !(e17_frstwork %in% c(1, 2))) %>% 
    select_cv(e01_work, e03_jobbus, e17_frstwork, h = 'e17_frstwork') 
)[[1]]


### E18 - Response in E18 is not in the value set or blank

## If answer in E01 and/or E03 is 1, E18 (class of worker) must not be blank and must be in the value set.
(
  cv_e18_class_of_worker <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, !(e18_class %in% c(0:6))) %>%
    select_cv(e01_work, e03_jobbus, e18_class, h = 'e18_class')
)[[1]]


### E19 - Basis of Payment must have an entry if answer in E18 is 0, 1, 2 or 5

## If answer in E18 (class of worker) is 0, 1, 2, 5, E19 must have an entry or must be in the value set.
(
  cv_e18_e19_class_worker_payment <- section_e_employed %>%
    filter(age >= 15, e18_class %in% c(0:2, 5), !(e19_classpaycode %in% c(0:7))) %>%
    select_cv(age, e18_class, e19_classpaycode, h = 'e19_classpaycode')
)[[1]]


### E19 - Basis of Payment must be BLANK if answer in E18 (class of worker) is 3, 4, 6

## If answer in E18 (class of worker) is 3, 4, 6, E19 must be blank or skipped.
(
  cv_e18_e19_class_worker_no_payment <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, e18_class %in% c(3, 4, 6), !is.na(e19_classpaycode)) %>%
    select_cv(e01_work, e03_jobbus, e18_class, e19_classpaycode, h = c('e18_class','e19_classpaycode'))
)[[1]]


### E20 - Answer in E19 is 5, 6, 7 but E20 have an entry

## If answer in E19 is 5, 6, 7, E20 must be blank. 
(
  cv_e19_e20_basis_no_basic_pay <- section_e_employed %>%
    filter(age >= 15, e19_classpaycode %in% c(5, 6, 7), !is.na(e20_classpaypday)) %>%
    select_cv(e01_work, e03_jobbus, e19_classpaycode, e20_classpaypday, h = c('e19_classpaycode','e20_classpaypday'))
)[[1]]

 
### E20 - Answer in E19 is 0,1,2,3, or 4 but E20 is blank or less than 0

## If answer in E19 is code 0,1,2,3, or 4, E20 must have an entry greater than 0.
(
  cv_e19_e20_basis_basic_pay <- section_e_employed %>%
    filter(age >= 15, e19_classpaycode %in% c(0:4), is.na(e20_classpaypday) | e20_classpaypday == 0) %>%
    select_cv(e01_work, e03_jobbus, e19_classpaycode, e20_classpaypday, h = c('e19_classpaycode','e20_classpaypday'))
)[[1]]


### E21 - Response in E21 is not in the value set or blank

## If answer in E01 and/or E03 is 1, E21 (other job/business) must not be blank and must be in the value set.
(
  cv_e21_have_other_job <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, !(e21_pwojobbus %in% c(1, 2))) %>%
    select_cv(e01_work, e03_jobbus, e21_pwojobbus, h = 'e21_pwojobbus')
)[[1]]


### E22 - Number of other jobs is more than 10

## Check cases if answer in E22 is more than 10.
(
  cv_e22_other_jobs <- section_e_employed %>% 
    filter(age >= 15, e21_pwojobbus == 1, !(e22_pwtotjobs %in% (1:10))) %>% 
    select_cv(e01_work, e03_jobbus, e21_pwojobbus, e22_pwtotjobs, h = 'e22_pwtotjobs')
)[[1]]


### E24 - Normal working hours but with response in E24 

## If answer in E23 (total hours worked) is 40 to 48 hours, E24 must be blank.
(
  cv_e23_worked_40_to_48_hrs <- section_e_ofi %>%
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, !(e23_pwtothrsaj %in% c(40:48)), is.na(e24_pwreason)) %>%
    select_cv(e01_work, e03_jobbus, e23_pwtothrsaj, e24_pwreason, h = c('e23_pwtothrsaj', 'e24_pwreason'))
)[[1]]


### E23 - Total hours worked for all jobs is less than the past week

## Answer in E23 (total hrs worked for all jobs) should be greater than or equal to the answer in E13 (hours worked during the past week).
(
  cv_e23_e14_total_and_total_all_work <- section_e_ofi %>% 
    filter(age >= 5, e01_work == 1 | e03_jobbus == 1, e23_pwtothrsaj < e14_pwtothrs) %>%
    select_cv(e01_work, e03_jobbus, e14_pwtothrs, e23_pwtothrsaj, h = c('e14_pwtothrs','e23_pwtothrsaj'))
)[[1]]


### E24 - Reason for working more than 48 hours

## If answer in E24 is code 11:15,99, E23 should be greater than 48 hours.
(
  cv_e24_worked_more_than_48 <- section_e_employed %>%
    filter(age >= 15, e23_pwtothrsaj > 48, !(e24_pwreason %in% c(11:15, 99))) %>%
    select_cv(e01_work, e03_jobbus, e23_pwtothrsaj, e24_pwreason_fct, h = c('e23_pwtothrsaj','e24_pwreason_fct'))
)[[1]]


### E24 - Reason for working less than 40 hours

## If answer in E24 is code 20:32,99, E23 should be less than 40 hours.
(
  cv_e24_worked_less_than_40 <- section_e_employed %>%
    filter(age >= 15, e23_pwtothrsaj < 40, !(e24_pwreason %in% c(20:32, 99))) %>%
    select_cv(
      e01_work, e03_jobbus, e23_pwtothrsaj, e24_pwreason_fct, 
      h = c('e23_pwtothrsaj','e24_pwreason_fct')
    )
)[[1]]


### E24 - Answer is 99 (other) but not specified (> 48 hours)

#### Cases with inconsistency

## If responded 99 (other) to E24 (reason for working more than 48 hours), answer must be specified.
(
  cv_e24_worked_more_than_48_other <- section_e_employed %>%
    filter(age >= 15, e23_pwtothrsaj > 48, e24_pwreason == 99, is.na(e24a_pwreason)) %>%
    select_cv(
      e01_work, 
      e03_jobbus, 
      e23_pwtothrsaj, 
      e24_pwreason_fct, 
      e24a_pwreason,
      h = 'e24a_pwreason'
    )
)[[1]]


#### E24 - Other responses for recoding

## Recode answer for 'Others, specify' if necessary.
(
  cv_e24_other <- section_e %>% 
    filter(e24_pwreason == 99, e23_pwtothrsaj > 48, !is.na(e24a_pwreason)) %>% 
    select_cv(e23_pwtothrsaj, e24_pwreason_fct, e24a_pwreason)
)[[1]]


### E24 - Answer is 99 (other) but not specified (< 40 hours)


#### Cases with inconsistency

## If responded 99 (other) to E24 (reason for working less than 40 hours), answer must be specified.
(
  cv_e24_worked_less_than_40_other <- section_e_employed %>%
    filter(age >= 15, e23_pwtothrsaj < 40, e24_pwreason == 99, is.na(e24b_pwreason)) %>%
    select_cv(
      e01_work, 
      e03_jobbus, 
      e23_pwtothrsaj, 
      e24_pwreason_fct, 
      e24b_pwreason,
      h = 'e24b_pwreason'
    )
)[[1]]


#### E24 - Other responses for recoding

## Recode answer for 'Others, specify' if necessary.
(
  cv_e24_other <- section_e %>% 
    filter(e24_pwreason == 99, e23_pwtothrsaj < 40, !is.na(e24b_pwreason)) %>% 
    select_cv(e23_pwtothrsaj, e24_pwreason_fct, e24b_pwreason)
)[[1]]


### E25 - Response in E25 is not in the value set or blank

## If answer in E03 is 2 or 3, E25 (look for work) must not be blank and must be in the value set. 
(
  cv_e03_no_job_engage_platform <- section_e_not_employed %>%
    filter(!(e25_pwlookest %in% c(1, 2))) %>%
    select_cv(e03_jobbus, e25_pwlookest, h = 'e25_pwlookest')
)[[1]]


### E26 - Response in E26 is not in the value set or blank

## If answer in E25 is 1, E26 (first time to look for work) must not be blank and must be in the value set. 
(
  cv_e26_first_time <- section_e_not_employed %>%
    filter(e25_pwlookest == 1, !(e26_frstimelookest %in% c(1, 2))) %>%
    select_cv(e03_jobbus, e25_pwlookest, e26_frstimelookest, h = c('e25_pwlookest','e26_frstimelookest'))
)[[1]]


### E27 - Job search method is not in the value set or blank

## If answer in E25 is 1, E27 (job search method) must not be blank and must be in the value set. 
(
  cv_e27_job_search_method <- section_e_not_employed %>%
    filter(e25_pwlookest == 1, !(e27_findwork %in% c(1:5, 9))) %>%
    select_cv(e03_jobbus, e25_pwlookest, e27_findwork, h = c('e25_pwlookest','e27_findwork'))
)[[1]]



### E27 - Answered 9 (other) but not specified 


#### Cases with inconsistency

## If responded 9 (other) to E27 (job search method), answer must be specified.
(
  cv_e27_job_search_other <- section_e_not_employed %>%
    filter(e25_pwlookest == 1, e27_findwork == 9, is.na(e27a_findwork)) %>%
    select_cv(
      e25_pwlookest_fct, 
      e27_findwork_fct,
      e27a_findwork, 
      h = 'e27a_findwork'
    )
)[[1]]


#### E27 - Other responses for recoding

## Recode answer for 'Others, specify' if necessary.
(
  cv_e27_other <- section_e_not_employed %>% 
    filter(e27_findwork == 9, !is.na(e27a_findwork)) %>% 
    select_cv(e27_findwork_fct, e27a_findwork)
)[[1]]


### E28 - Job search duration is less than 1 week or more than 260 weeks

## If answer in E25 is 1, E28 (job search duration) must not be blank and must be between 1 and 260 weeks.
(
  cv_e28_job_search_duration <- section_e_not_employed %>%
    filter(e25_pwlookest == 1, !(e28_wkslooking %in% (1:260))) %>%
    select_cv(e03_jobbus, e25_pwlookest, e28_wkslooking, h = 'e28_wkslooking')
)[[1]]


### E29 - Reasons for not looking for work is not in the valueset

## If answer in E25 is 2, E29 must not be blank and must be in the value set.
(
  cv_e29_reason_not_look_work <- section_e_not_employed %>%
    filter(e25_pwlookest == 2, !(e29_reasonnlfwork %in% c(0:10, 99))) %>%
    select_cv(e03_jobbus, e25_pwlookest, e29_reasonnlfwork, h = 'e29_reasonnlfwork')
)[[1]]


### E29 - Answered is 99 (other) but not specified 


#### Cases with inconsistency

## If responded 99 (other) to E29 (reasons for not looking for work), answer must be specified.
(
  cv_e29_not_look_for_work_other <- section_e_not_employed %>%
    filter(e25_pwlookest == 1, e29_reasonnlfwork == 99, is.na(e29a_reasonnlfwork09)) %>%
    select_cv(
      e25_pwlookest_fct, 
      e29_reasonnlfwork,
      e29a_reasonnlfwork09, 
      h = 'e29a_reasonnlfwork09'
    )
)[[1]]


#### E29 - Other responses for recoding

## Recode answer for 'Others, specify' if necessary.
(
  cv_e27_other <- section_e_not_employed %>% 
    filter(e29_reasonnlfwork == 99, !is.na(e29a_reasonnlfwork09)) %>% 
    select_cv(e29_reasonnlfwork_fct, e29a_reasonnlfwork09)
)[[1]]



### E30 - Last time looked for work is not in the valueset

## If answer in E25 is 2 and E29 is 4 or 5, E30 must not be blank and must be in the value set.
(
  cv_e30_last_look_work <- section_e_not_employed %>% 
    filter(e25_pwlookest == 2, e29_reasonnlfwork %in% c(4, 5), !(e30_lastimelooked %in% c(1:3))) %>%
    select_cv(e03_jobbus, e25_pwlookest, e29_reasonnlfwork, e30_lastimelooked, h = 'e30_lastimelooked')
)[[1]]


### E31 - Missing/invalid answer for E31 (availability if opprotunity for work existed)

## If answer in E29 is 0, 1, 2, or 5, E31 must have an entry.
(
  cv_e31_opportunity <- section_e_not_employed %>%
    filter(e25_pwlookest == 1 | e29_reasonnlfwork %in% c(0:5), !(e31_opporlfw %in% c(1, 2))) %>%
    select_cv(e03_jobbus, e25_pwlookest, e29_reasonnlfwork, e31_opporlfw, h = c('e29_reasonnlfwork','e31_opporlfw'))
)[[1]]


### E32 - Missing/invalid answer for E32 (willing to take up work)

## If answer in E29 is 0, 1, 2, or 5, E32 must have an entry.
(
  cv_e32_willing <- section_e_not_employed %>%
    filter(e25_pwlookest == 1 | e29_reasonnlfwork %in% c(0:5), !(e32_willingtowork %in% c(1, 2))) %>%
    select_cv(e03_jobbus, e25_pwlookest, e29_reasonnlfwork, e32_willingtowork, h = c('e29_reasonnlfwork','e32_willingtowork'))
)[[1]]


### E33 - Response in E33 (ever work/had business) is not in the value set or blank

## E33 (ever work) must not blank or must be in the value set.
(
  cv_e33_ever_work <- section_e_not_employed %>% 
    filter(!(e33_prevwork %in% c(1, 2))) %>% 
    select_cv(e03_jobbus, e33_prevwork, h = 'e33_prevwork')
)[[1]]


### E34 to E38 - Did not work or had any business anytime in the past (E33=2) but did not skip E34 to E38

## If answer in E33 is 2, E34 to E38 should be skipped or blank.
(
  cv_e33_ever_work_date <- section_e_not_employed %>%
    filter(e33_prevwork == 2) %>%
    filter_at(vars(matches('^e3[4-8].*')), any_vars(!is.na(.))) %>% 
    select_cv(
      e03_jobbus, 
      matches('^e3[3-8].*'), 
      h = c(
        'e34_monthyear',
        'e34_monthyear1',
        'e35_lastocc',
        'e36_lastoccode',
        'e37_industry',
        'e38_industrycode'
        )
      )
)[[1]]


### E34 - Year and month last worked not in the value set

## If answer in E33 is 1, E34 must not be blank and must be in the value set.
(
  cv_e34_date_last_worked <- section_e_employed %>% 
    filter(
      e33_prevwork == 1, 
      !(as.integer(e34_monthyear) %in% c(1:12:98)), 
      !(as.integer(e34_monthyear1) %in% c(1960:2022, 9998))
    ) %>% 
    select_cv(e03_jobbus, e33_prevwork, e34_monthyear, e34_monthyear1, h = c('e34_monthyear','e34_monthyear1'))
)[[1]]


### E35 and E36 - Last occupation is not specified but with PSOC code

## If E36 (PSOC) has an entry, then E35 (last occupation) must also have an entry.
(
  cv_e35_e36_occ_psoc <- section_e_not_employed %>%
    filter(e33_prevwork == 1, is.na(e35_lastocc) | is.na(e36_lastoccode)) %>%
    select_cv(e03_jobbus, e33_prevwork, e35_lastocc, e36_lastoccode, h = c('e35_lastocc','e36_lastoccode'))
)[[1]]


### E35 - Invalid entry for last occupation

## Answer in E35 (last occupation) must be valid.
(
  cv_e35_invalid <- section_e_not_employed %>%
    filter(e33_prevwork == 1, grepl(ref_invalid_keyword, e35_lastocc, ignore.case = T)) %>%
    select_cv(e03_jobbus, e33_prevwork, e35_lastocc, e36_lastoccode, h = 'e35_lastocc')
)[[1]]


### E36 - PSOC is for further verification

## Check last occupation specified in E35 and edit E36 (PSOC code) accordingly.
(
  cv_e35_psoc <- section_e_not_employed %>% 
    filter(e33_prevwork == 1, e36_lastoccode == 0) %>%
    select_cv(e03_jobbus, e33_prevwork, e35_lastocc, e36_lastoccode, h = 'e36_lastoccode')
)[[1]]


### E37 and E38 - Kind of industry is not specified but with PSIC code

## If E38 (PSIC) has an entry, then E37 (kind of industry) must also have an entry.
(
  cv_e37_e38_ind_psic <- section_e_not_employed %>%
    filter(e33_prevwork == 1, is.na(e37_industry) | is.na(e38_industrycode)) %>%
    select_cv(e03_jobbus, e33_prevwork, e37_industry, e38_industrycode, h = c('e37_industry','e38_industrycode') )
)[[1]]


### E37 - Invalid entry for kind of industry

## Answer in E37 (kind of industry) must be valid.
(
  cv_e37_invalid <- section_e_not_employed %>%
    filter(e33_prevwork == 1, grepl(ref_invalid_keyword, e37_industry, ignore.case = T)) %>%
    select_cv(e03_jobbus, e33_prevwork, e37_industry, e38_industrycode, h = 'e37_industry')
)[[1]]


### E38 - PSIC is for further verification

## Check kind of industry specified in E37 and edit E38 (PSIC code) accordingly.
(
  cv_e36_psoc_for_verification <- section_e_not_employed %>%
    filter(e33_prevwork == 1, e38_industrycode == 0) %>%
    select_cv(e03_jobbus, e33_prevwork, e37_industry, e38_industrycode, h = c('e37_industry','e38_industrycode'))
)[[1]]


### E39 to E44 - Less than 15 y/o but have response in E39 to E44

## If age is less than 15 y/o, E39 to E44 should be skipped.
(
  cv_e39_agriland_age_less_15 <- section_e %>% 
    filter(age < 15) %>% 
    filter_at(vars(matches('^e(39|4[0-4])_.*'), -matches('fct$')), any_vars(!is.na(.))) %>% 
    select_cv(
      matches('^e(39|4[0-4])_.*'), 
      h = c(
        'e39_agriland_fct',
        'e40_agrilanduse_fct',
        'e41_agrilandrights_fct',
        'e42_agrilandowner_fct',
        'e43_agrilandrighttosell_fct',
        'e44_agrilandbequeath_fct'
        )
     )
)[[1]]


### E39 - Age is 15 y/o and over but response in E39 is NOT in valueset or missing

## If age is 15 y/o and over, E39 must not be blank and must be in the value set.
(
  cv_e39_agriland_NOT_valueset <- section_e %>% 
    filter(age >= 15, !(e39_agriland %in% c(1, 2))) %>%
    select_cv(age, e39_agriland, h = 'e39_agriland')
)[[1]]


### E39 - No ownership or rights over agri land (E39=2) but did not skip E40 to E44

## If answer in E39 is 2, E40 to E44 should be skipped.
(
  cv_e39_no_agri <- section_e %>% 
    filter(age >= 15, e39_agriland == 2) %>% 
    filter_at(vars(matches('^e4[0-4]_.*'), -matches('fct$')), any_vars(!is.na(.))) %>% 
    select_cv(
      e39_agriland, 
      matches('^e4[0-4]_.*'), 
      h = c(
        'e39_agriland',
        'e40_agrilanduse_fct',
        'e41_agrilandrights_fct',
        'e42_agrilandowner_fct',
        'e43_agrilandrighttosell_fct',
        'e44_agrilandbequeath_fct'
        )
      )
)[[1]]


### E40 - With ownership or rights over agri land (E39=1) but no response in E40

## If answer in E39 is 1, E40 must not be blank and must be in the value set.
(
  cv_e40_agrilanduse_NOT_valueset <- section_e %>% 
      filter(age >= 15, e39_agriland == 1, !(e40_agrilanduse %in% c(1, 2))) %>%
      select_cv(age, e39_agriland, e40_agrilanduse, h = 'e40_agrilanduse')
)[[1]]


### E41 - With ownership or rights over agri land (E39=1) but no response in E41

## If answer in E39 is 1, E41 must not be blank and must be in the value set.
(
  cv_e41_agrilandrights_NOT_valueset <- section_e %>% 
    filter(age >= 15, e39_agriland == 1, !(e41_agrilandrights %in% c(1, 2))) %>%
    select_cv(age, e39_agriland, e41_agrilandrights, h = 'e41_agrilandrights')
)[[1]]


### E42 - With ownership or rights over agri land (E39=1) but no response in E42

## If answer in E39 is 1, E42 must not be blank and must be in the value set.
(
  cv_e42_agrilandowner_NOT_valueset <- section_e %>% 
      filter(age >= 15, e39_agriland == 1, e41_agrilandrights == 1, !(e42_agrilandowner %in% c(1, 2, 8, 9))) %>%
      select_cv(age, e39_agriland, e41_agrilandrights, e42_agrilandowner, h = 'e42_agrilandowner')
)[[1]]


### E42 - Without formal document for agri land (E41=2) but did not skip E42

## If answer in E41 is 2, E42 should be blank or skipped.
(
  cv_e42_na <- section_e %>% 
    filter(age >= 15, e41_agrilandrights == 2, !is.na(e42_agrilandowner)) %>% 
    select_cv(e41_agrilandrights, e42_agrilandowner, h = c('e41_agrilandrights','e42_agrilandowner'))
)[[1]]


### E43 - With ownership or rights over agri land (E39=1) but no response in E43

## If answer in E39 is 1, E43 must not be blank and must be in the value set.
(
  cv_e43_agrilandrighttosell_NOT_valueset <- section_e %>% 
    filter(age >= 15, e39_agriland == 1, !(e43_agrilandrighttosell %in% c(1:3, 8, 9))) %>%
    select_cv(age, e39_agriland, e43_agrilandrighttosell, h = 'e43_agrilandrighttosell')
)[[1]]


### E44 - With ownership or rights over agri land (E39=1) but no response in E43

## If answer in E39 is 1, E44 must not be blank and must be in the value set.
(
  cv_e44_agrilandbequeath_NOT_valueset <- section_e %>% 
    filter(age >= 15, e39_agriland == 1, !(e44_agrilandbequeath %in% c(1:3, 8, 9))) %>%
    select_cv(age, e39_agriland, e44_agrilandbequeath, h = 'e44_agrilandbequeath')
)[[1]]