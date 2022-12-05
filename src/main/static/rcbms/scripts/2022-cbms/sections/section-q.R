
# Section Q {.unnumbered}


section_q <- hpq$section_q %>% 
  collect() %>% 
  filter_at(vars(matches('^q\\d.*')), any_vars(!is.na(.))) 



### Q01 - Main Source of Water Supply is blank/not in the valueset

## Main Source of Water Supply should not be blank and should be 01:10 or 99.
(
  cv_q01_mswater_nitv <- section_q %>% 
    filter(!(q01_mswater%in% c(1:10, 99))) %>% 
    select_cv(q01_mswater, h = 'q01_mswater')
)[[1]]


### Q01 - Main Source of Water Supply OTHERS is blank


#### Cases with inconsistency

## If Q01 = 99 (Others, specify), Others Specify field must not be blank. Others specify field must have an entry if Q01 = 99.
(
  cv_q01a_mswater_blank <- section_q %>% 
    filter(q01_mswater == 99, is.na(q01a_mswater)) %>% 
    select_cv(q01_mswater, q01a_mswater, h = 'q01_mswater')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q01a_mswater_blank_o <- section_q %>% 
    filter(q01_mswater == 99, !is.na(q01a_mswater)) %>% 
    select_cv(q01_mswater_fct, q01a_mswater)
)[[1]]


### Q01 - Main Source of Water Supply is not OTHERS but not blank

## If Q01 in not 99 (Others, specify), Others Specify field must be blank.
(
  cv_q01a_mswater_notblank <- section_q %>% 
    filter(q01_mswater != 99, !is.na(q01a_mswater)) %>% 
    select_cv(q01_mswater, q01a_mswater, h = 'q01a_mswater')
)[[1]]


### Q02 - Distance of the water source from the housing unit is blank

## If Q01 is 2:8 and 99, Distance of the water source from the housing should not be blank.
(
  cv_q02_distance_nitv <- section_q %>% 
    filter(q01_mswater %in% c(2:8, 99), is.na(q02_far)) %>% 
    select_cv(q01_mswater, q02_far, h = 'q02_far')
)[[1]]


### Q02 - Q02 with values if Q01 is 1,9, 10

## If Q01 is 1, 9, 10, distance of the water source from the housing should be blank.
(
  cv_q02_distance_wval <- section_q %>% 
    filter(q01_mswater %in% c(1,9, 10), !is.na(q02_far)) %>% 
    select_cv(q01_mswater, q02_far, h = 'q02_far')
)[[1]]


### Q03 - Main Source of Drinking Water is blank/not in the valueset

## Main Source of Drinking Water should not be blank and should be should be 11:14, 21, 31, 32, 41, 42, 51, 61, 71, 72, 81, 91, 92, 99.
(
  cv_q03_wdrink_nitv <- section_q %>% 
    filter(!(q03_wdrink %in% c(11:14, 21, 31, 32, 41, 42, 51, 61, 71, 72, 81, 91, 92, 99))) %>%
    select_cv(q01_mswater, q03_wdrink, h = 'q03_wdrink')
)[[1]]


### Q03 - Main Source of Drinking Water OTHERS is blank



#### Cases with inconsistency

## If Q03 (Main Source of Drinking Water) = 99 (Others, specify), Others Specify field must not be blank. Others specify field must have an entry if Q03 = 99.
(
  cv_q03a_wdrink_blank <- section_q %>% 
    filter(q03_wdrink == 99, is.na(q03a_wdrink)) %>% 
    select_cv(q01_mswater_fct, q03_wdrink_fct, q03a_wdrink, h = 'q03a_wdrink')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q03a_wdrink_blank_o <- section_q %>% 
    filter(q03_wdrink == 99, !is.na(q03a_wdrink)) %>% 
    select_cv(q03_wdrink_fct, q03a_wdrink)
)[[1]]



### Q03 - Main Source of Drinking Water not OTHERS is not blank

## If Q03 (Main Source of Drinking Water) is not 99 (Other, Specify), Others Specify field must be blank.
(
  cv_q03a_wdrink_notblank <- section_q %>% 
    filter(q03_wdrink != 99, !is.na(q03a_wdrink)) %>% 
    select_cv(q01_mswater, q03_wdrink, q03a_wdrink, h = 'q03a_wdrink')
)[[1]]


### Q04 - Main Source for Cooking and Handwashing is blank/not in the valueset

## If Q03 (Main Source of Drinking Water) = 72, 91, 92, Main Source for Cooking and Handwashing should not be blank and should be 11:14, 21, 31, 32, 41, 42, 51, 61, 71, 72, 81, 91, 92, 99.
(
  cv_q04_wcook_blank <- section_q %>% 
    filter(q03_wdrink %in% c(72, 91, 92), is.na(q04_wcook)) %>% 
    select_cv(q03_wdrink, q04_wcook, h = 'q04_wcook')
)[[1]]


### Q04 - Q04 with values if Q03 is 11, 12, 13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 81, 99

## If Q03 (Main Source of Drinking Water) is 11, 12, 13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 81, 99, Main Source for Cooking and Handwashing should be blank.
(
  cv_q04_wcook_wval <- section_q %>% 
    filter(q03_wdrink %in% c(11:14, 21, 31, 32, 41, 42, 51, 61, 71, 81, 99), !is.na(q04_wcook)) %>% 
    select_cv(q03_wdrink, q04_wcook, h = 'q04_wcook')
)[[1]]


### Q04 - Main Source of Cooking and Handwashing OTHERS is blank


#### Cases with inconsistency

## If Q04 = 99 (Others, specify), Others Specify field should not be blank. Others specify field must have an entry if Q04 = 99.
(
  cv_q04a_wcook_blank <- section_q %>% 
    filter(q04_wcook == 99, is.na(q04a_wcook)) %>% 
    select_cv(q04_wcook_fct, q04a_wcook, h = 'q04a_wcook')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q04a_wcook_blank_o <- section_q %>% 
    filter(q04_wcook == 99, !is.na(q04a_wcook)) %>% 
    select_cv(q04_wcook_fct, q04a_wcook)
)[[1]]



### Q04 - Main Source of Cooking and Handwashing not OTHERS is not blank

## If Q04 (Main Source for Cooking and Handwashing) is not 99 (Other, Specify), Others Specify field should be blank.
(
  cv_q04a_wcook_notblank <- section_q %>% 
    filter(q04_wcook != 99, !is.na(q04a_wcook)) %>% 
    select_cv(q04_wcook, q04a_wcook, h = 'q04a_wcook')
)[[1]]


### Q05 - Source of water location is blank/not in the valueset

## If Q03 (Main Source of Drinking Water) = 13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 72, 81, 91, 92, 99, Source of water location should not be blank and should be 1, 2, or 3.
(
  cv_q05_wsource_nitv <- section_q %>% 
    filter(q03_wdrink %in% c(13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 72, 81, 91, 92, 99), !(q05_wsource %in% c(1:3))) %>% 
    select_cv(q03_wdrink, q05_wsource, h = 'q05_wsource')
)[[1]]


### Q05 - Q05 with values if Q03 is 11,12

## If Q03 (Main Source of Drinking Water) = 11, 12, Source of water location should be blank.
(
  cv_q05_wsource_wval <- section_q %>% 
    filter(q03a_wdrink %in% c(11, 12), !is.na(q05_wsource)) %>% 
    select_cv(q03a_wdrink, q05_wsource, h = 'q05_wsource')
)[[1]]


### Q06 - Length of time to collect water is blank/not in the valueset

## If Q05 (Source of water location) = 3 (ELSEWHERE), Length of time to collect water should not be blank and should be 001 to 480 minutes.
(
  cv_q06_wget_nitv <- section_q %>% 
    filter(q05_wsource == 3, is.na(q06_wget)) %>% 
    select_cv(q05_wsource, q06_wget, h = 'q06_wget')
)[[1]]


### Q06 - Answer in Q05 is 1,2 but Length of time to collect water is in the valueset. 

## If Q05 (Source of water location) = 1, 2, Length of time to collect water should be blank.
(
  cv_q06_wget_ <- section_q %>% 
    filter(q05_wsource %in% c(1, 2), !is.na(q06_wget)) %>% 
    select_cv(q05_wsource, q06_wget, h = 'q06_wget')
)[[1]]


### Q06 - Length of time to collect water is greater 480 mins

## If Q05 (Source of water location) = 3 (ELSEWHERE), answer for Q06 (Length of time to collect water) should be 001 to 480 minutes.
(
  cv_q06_wget_480 <- section_q %>%
    filter(q05_wsource == 3, q06_wget > 480) %>%
    select_cv(q05_wsource, q06_wget, h = 'q06_wget')
)[[1]]


### Q07 - Distance of source of water from the housing unit is blank/not in the valueset

## If Q03 (Main Source of Drinking Water) = 13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 81,  91, 92, 99 and Q05 (Source of water location) = 3 (ELSEWHERE), and Q06 (Length of time to collect water) = 001 to 480, Distance of source of water from the housing unit should not be blank. 
(
  cv_q07_far_nitv <- section_q %>% 
    filter(
      q03_wdrink %in% c(13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 81,  91, 92, 99), 
      q05_wsource == 3,
      q06_wget %in% c(001:480), is.na(q07_far)
    ) %>% 
    select_cv(q05_wsource, q06_wget, q07_far, h = 'q07_far')
)[[1]]


### Q07 - Answer in Q03 is 11,12 but Distance of source of water from the housing unit is not blank

## If Q03 (Main Source of Drinking Water) = 11, 12, Distance of source of water from the housing unit should be blank.
(
  cv_q07_far_wval<- section_q %>% 
    filter(q03_wdrink %in% c(11, 12), !is.na(q07_far)) %>% 
    select_cv(q03_wdrink, q07_far, h = 'q07_far')
)[[1]]


### Q08 - Name of household member hauling the water is blank/not in the household

## If Q03 (Main Source of Drinking Water) = 13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 81,  91, 92, 99 and Q05 (Source of water location) = 3 (ELSEWHERE), and Q06 (Length of time to collect water) = 001 to 480,Name of household member hauling the water should not be blank or should be from the household member. 
(
  cv_q08_wcollect_nitv <- section_q %>% 
    filter(
      q03_wdrink %in% c(13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 81,  91, 92, 99),
      q05_wsource == 3,
      q06_wget %in% c(001:480),
      is.na(q08_wcollect)
    ) %>% 
    select_cv(q03_wdrink, q05_wsource, q06_wget, q08_wcollect, h = 'q08_wcollect')
)[[1]]


### Q09 - Number of times collecting water is blank/not in the valueset

## If Q03 (Main Source of Drinking Water) = 13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 81,  91, 92, 99 and Q05 (Source of water location) = 3 (ELSEWHERE), and Q06 (Length of time to collect water) = 001 to 480,Number of times collecting water should not be blank or should be 01 to 20, or 98.
(
  cv_q09_wtimes_nitv<- section_q %>%  
    filter(
      q03_wdrink %in% c(13, 14, 21, 31, 32, 41, 42, 51, 61, 71, 81,  91, 92, 99),
      q05_wsource == 3,
      q06_wget %in% c(001:480),
      is.na(q09_wtimes)
    ) %>% 
    select_cv(q03_wdrink, q05_wsource, q06_wget, q08_wcollect, q09_wtimes, h = 'q09_wtimes')
)[[1]]


### Q10 - Sufficiency of drinking water is blank/not in the valueset

## Sufficiency of drinking water should not be blank or should be 1, 2, or 8.
(
  cv_q10_wsufcient_nitv <- section_q %>% 
    filter(!(q10_wsufcient %in% c(1, 2, 8))) %>% 
    select_cv(q10_wsufcient, h = 'q10_wsufcient')
)[[1]]


### Q11 - Main reason for inability to access sufficient quantities of drinking water is blank/not in the valueset

## If Q10 (Sufficiency of drinking water) = 1 (YES, AT LEAST ONCE), Main reason for inability to access sufficient quantities of drinking water should not be blank or should be 1, 2, 3, 8, or 9.
(
  cv_q11_waccess_nitv <- section_q %>% 
    filter(q10_wsufcient == 1, !(q11_waccess %in% c(1:3, 8, 9))) %>% 
    select_cv(q10_wsufcient, q11_waccess, h = 'q11_waccess')
)[[1]]


### Q11 - Answer is 9 but not specified 



#### Cases with inconsistency

## If responded 9 to Q11 (other reason unable to access drinking water), answer must be specified.
(
  cv_q11_other_missing <- section_q %>% 
    filter(q11_waccess == 9, is.na(q11a_access)) %>% 
    select_cv(q11_waccess_fct, q11a_access, h = 'q11a_access')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q11_other_missing <- section_q %>% 
    filter(q11_waccess == 9, !is.na(q11a_access)) %>% 
    select_cv(q11_waccess_fct, q11a_access)
)[[1]]



### Q11 - Answer in Q10 is 2,8 but main reason for inability to access sufficient quantities of drinking water is not blank

## If Q10 (Sufficiency of drinking water) = 2, 8, Main reason for inability to access sufficient quantities of drinking water should be blank.
(
  cv_q11_waccess_wval <- section_q %>% 
    filter(q10_wsufcient %in% c(2, 8), !is.na(q11_waccess)) %>% 
    select_cv(q10_wsufcient, q11_waccess, h = 'q11_waccess')
)[[1]]


### Q12 - Water Treatment is blank/not in the valueset

## Water Treatment should not be blank and should be 1, 2, or 8.
(
  cv_q12_wsafe_nitv <- section_q %>% 
    filter(!(q12_wsafe %in% c(1, 2, 8))) %>% 
    select_cv(q12_wsafe, h = 'q12_wsafe')
)[[1]]

 
### Q13A-FXZ - Water Treatment Methods

## If Q12 (Water treatment) = 1, the answer in the water treatment methods should be either from A to F, X, or Z.  
(
  cv_q13_nitv <- section_q %>%
    filter(q12_wsafe == 1) %>%
    filter_at(vars(matches('^q13[a-fz].*'), -matches("fct$")), all_vars(!(. %in% c(1, 2)))) %>%
    select_cv(
      q12_wsafe, 
      matches('^q13[a-fz].*'), 
      h = c(
        'q13a_boiled',
        'q13b_bleachchlorine',
        'q13c_strain',
        'q13d_waterfilter',
        'q13e_solardis',
        'q13f_standandsettle',
        'q13zx_dontknow',
        'q13za_wsaferothers',
        'q13zb_wsaferothers'
        )
      )
)[[1]]


### Q13 - Q12 is Yes but all no in Q13

## If Q12 (Water Treatment) =  1, there should be one yes in Q13 (Water treatment methods)
(
  cv_q13_atleast1yes <- section_q %>%
    filter(q12_wsafe == 1) %>%
    filter_at(vars(matches('^q13[a-fxz].*'), -matches("fct$")), all_vars(. == 2)) %>%
    select_cv(
      q12_wsafe, 
      matches('^q13[a-fxz].*'), 
      h = c(
        'q13a_boiled',
        'q13b_bleachchlorine',
        'q13c_strain',
        'q13d_waterfilter',
        'q13e_solardis',
        'q13f_standandsettle',
        'q13zx_dontknow',
        'q13za_wsaferothers',
        'q13zb_wsaferothers'
        )
      )
)[[1]]


### Q13AX - Q12 is no but with values in Q13

## If Q12 (Water Treatment) =  2, Water treatment methods should be blank
(
  cv_q13_wval <- section_q %>% 
    filter(q12_wsafe == 2) %>% 
    filter_at(vars(matches('^q13[a-fxz].*'), -matches("fct$")), all_vars(!is.na(.))) %>% 
    select_cv(
      q12_wsafe, 
      matches('^q13[a-fxz].*'), 
      h = c(
        'q13a_boiled',
        'q13b_bleachchlorine',
        'q13c_strain',
        'q13d_waterfilter',
        'q13e_solardis',
        'q13f_standandsettle',
        'q13zx_dontknow',
        'q13za_wsaferothers',
        'q13zb_wsaferothers'
        )
      )
)[[1]]


### Q13Z - Answer is 'Yes' but not specified 



#### Cases with inconsistency

## If responded 'Yes' to Q13Z (other water treatment), answer must be specified.
(
  cv_q13_other_missing <- section_q %>% 
    filter(q13za_wsaferothers == 1, is.na(q13zb_wsaferothers)) %>% 
    select_cv(q13za_wsaferothers_fct, q13zb_wsaferothers, h = 'q13zb_wsaferothers')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q13_other <- section_q %>% 
    filter(q13za_wsaferothers == 1, !is.na(q13zb_wsaferothers)) %>% 
    select_cv(q13za_wsaferothers_fct, q13zb_wsaferothers)
)[[1]]



### Q14 - Kind of toilet facility is blank/not in the valueset

## Kind of toilet facility should not be blank or should be 11:15, 21:23, 31, 41, 51, 71, 95, 99.
(
  cv_q14_toilet_nitv <- section_q %>% 
    filter(!(q14_toilet %in% c(11:15, 21:23, 31, 41, 51, 71, 95, 99))) %>% 
    select_cv(
      q14_toilet, h = 'q14_toilet')
)[[1]]


### Q14 - Answer is 99 but not specified 



#### Cases with inconsistency

## If responded 99 to Q14 (other toilet facility), answer must be specified.
(
  cv_q14_other_missing <- section_q %>% 
    filter(q14_toilet == 99, is.na(q14a_toilet)) %>% 
    select_cv(q14_toilet_fct, q14a_toilet, h = 'q14a_toilet')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q14_other <- section_q %>% 
    filter(q14_toilet == 99, !is.na(q14a_toilet)) %>% 
    select_cv(q14_toilet_fct, q14a_toilet)
)[[1]]



### Q15 - Outlet of the septic tank is blank/not in the valueset

## If Q14 (Kind of toilet facility) = 12, Outlet of the septic tank should not be blank or should be 1:5, 8, 9.
(
  cv_q15_outlet_nitv <- section_q %>% 
    filter(q14_toilet == 12, !(q15_outlet %in% c(1:5, 8, 9))) %>% 
    select_cv(q14_toilet, q15_outlet, h = 'q15_outlet')
)[[1]]


### Q15 - Q14 is not 12 but with answer in Q15

## If Q14 (Kind of toilet facility) is not 12, Outlet of the septic tank should be blank.
(
  cv_q15_outlet_wval <- section_q %>% 
    filter(q14_toilet != 12, !is.na(q15_outlet)) %>% 
    select_cv(q14_toilet, q15_outlet, h = 'q15_outlet')
)[[1]]


### Q15 - Answer is 9 but not specified 



#### Cases with inconsistency

## If responded 9 to Q15 (septic tank outlet), answer must be specified.
(
  cv_q15_other_missing <- section_q %>% 
    filter(q15_outlet == 9, is.na(q15a_outlet)) %>% 
    select_cv(q15_outlet_fct, q15a_outlet, h = 'q15a_outlet')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q15_other <- section_q %>% 
    filter(q15_outlet == 9, !is.na(q15a_outlet)) %>% 
    select_cv(q15_outlet_fct, q15a_outlet)
)[[1]]



### Q16 - Empties toilet facility is blank/not in the valueset

## If Q14 (Kind of toilet facility) = 12, 13, 21:23, 31, Empties toilet facility should not be blank or should be 1 to 6 or 8.
(
  cv_q16_emptied_nitv <- section_q %>% 
    filter(q14_toilet %in% c(12, 13, 21:23, 31), !(q16_emptied %in% c(1:6, 8))) %>% 
    select_cv(q14_toilet, q16_emptied, h = 'q16_emptied')
)[[1]]


### Q16 - Q14 is not 12,13,21,22,23,31 but with answer in Q16

## If Q14 (Kind of toilet facility) is not 12, 13, 21:23, 31, Empties toilet facility should be blank.
(
  cv_q16_emptied_wval <- section_q %>% 
    filter(!(q14_toilet %in% c(12, 13, 21:23, 31)), !is.na(q16_emptied)) %>% 
    select_cv(q14_toilet, q16_emptied, h = 'q16_emptied')
)[[1]]


### Q17 - Septic tank sludge treatment is blank/not in the valueset

## If Q14 (Kind of toilet facility) = 12, 13, 21:23, 31 and Q16 (Empties toilet facility) = 1:3, Septic tank sludge treatment should not be blank or should be 1:5, 8 or 9.
(
  cv_q17_timempt_nitv <- section_q %>% 
    filter(
      q14_toilet %in% c(11:15, 21:23, 31, 41, 51, 99), 
      q16_emptied %in% c(1:3), 
      !(q17_timempt %in% c(1:5,8,9))
    ) %>% 
    select_cv(q14_toilet, q15_outlet, q16_emptied, q17_timempt, h = 'q17_timempt')
)[[1]]


### Q17 - Q14 is not 12,13,21,22,23,31 and q16 is not 1,2,3 but with answer in Q17

## If Q14 (Kind of toilet facility) is not 12, 13, 21:23, 31 and Q16 (Empties toilet facility) is not 1, 2, 3, Septic tank sludge treatment should be blank.
(
  cv_q17_timempt_nitv <- section_q %>% 
    filter(
      !q14_toilet %in% c(11:15, 21:23, 31, 41, 51, 99), 
      !(q16_emptied %in% c(1:3)), 
      !is.na(q17_timempt)
    ) %>% 
    select_cv(q14_toilet, q15_outlet, q16_emptied, q17_timempt, h = 'q17_timempt')
)[[1]]


### Q17 - Answer is 9 but not specified 



#### Cases with inconsistency

## If responded 9 to Q17 (septic tank emptied to), answer must be specified.
(
  cv_q17_other_missing <- section_q %>% 
    filter(q17_timempt == 9, is.na(q17a_timempt)) %>% 
    select_cv(q17_timempt_fct, q17a_timempt, h = 'q17a_timempt')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q17_other <- section_q %>% 
    filter(q17_timempt == 9, !is.na(q17a_timempt)) %>% 
    select_cv(q17_timempt_fct, q17a_timempt)
)[[1]]



### Q18 - Location of the toilet facility is blank/not in the valueset

## If Q14 (Kind of toilet facility) = 11:15, 21:23, 31, 41, 51, 99, Q15 (Outlet of the septic tank) = 1:5, 8, 9, Q16 (Empties toilet facility) is 1, 2, 3, Q17 (Septic tank sludge treatment) = 1:6, 8, Location of the toilet facility should not be blank or should be 1, 2, or 3.
(
  cv_q18_loc_nitv <- section_q %>% 
    filter(
      q14_toilet %in% c(11:15, 21:23, 31, 41, 51, 99), 
      q15_outlet %in% c(1:5,8,9),
      q16_emptied %in% c(1:3), 
      q17_timempt %in% c(1:6,8), 
      !(q18_loc %in% c(1:3))
    ) %>% 
    select_cv(q14_toilet, q15_outlet, q16_emptied, q17_timempt, q18_loc, h = 'q18_loc')
)[[1]]


### Q18 - Q14 is 71 and 95 but with answer in Q18

## If Q14 (Kind of toilet facility) = 71 and 95, Location of the toilet facility should be blank
(
  cv_q18_loc_wval <- section_q %>% 
    filter(q14_toilet %in% c(71, 95), !is.na(q18_loc)) %>% 
    select_cv(q14_toilet, q15_outlet, q16_emptied, q17_timempt, q18_loc, h = 'q18_loc')
)[[1]]


### Q19 - Sharing of toilet facility is blank/not in the valueset

## If Q14 (Kind of toilet facility) = 11:15, 21:23, 31, 41, 51, 99, Sharing of toilet facility should not be blank or should be 1 or 2.
(
  cv_q19_tshare_nitv <- section_q %>% 
    filter(q14_toilet %in% c(11:15, 21:23, 31, 41, 51, 99), !(q19_tshare %in% c(1,2))) %>% 
    select_cv(q14_toilet, q15_outlet, q16_emptied, q17_timempt, q18_loc, q19_tshare, h = 'q19_tshare')
)[[1]]


### Q19 - Q14 is 71 and 95 but with answer in Q19

## If Q14 (Kind of toilet facility) = 75, 95, Sharing of toilet facility should be blank
(
  cv_q19_tshare_wval <- section_q %>% 
    filter(q14_toilet %in% c(71, 95), !is.na(q19_tshare)) %>% 
    select_cv(q14_toilet, q15_outlet, q16_emptied, q17_timempt, q18_loc, q19_tshare, h = 'q19_tshare')
)[[1]]


### Q20 - Number of households sharing the toilet facility is blank/not in the valueset

## If Q19 (Sharing of toilet facility) = 1, Number of households sharing the toilet facility should not be blank or should be 01 to 10.
(
  cv_q20_tothhuse_nitv <- section_q %>% 
    filter(q19_tshare == 1, is.na(q20_tothhuse)) %>% 
    select_cv(q19_tshare, q20_tothhuse, h = 'q20_tothhuse')
)[[1]]


### Q20 - Q19 is 2 but with answer in Q20

## If Q19 (Sharing of toilet facility) = 2, Number of households sharing the toilet facility should be blank.
(
  cv_q20_tothhuse_wval <- section_q %>% 
    filter(q19_tshare == 2, !is.na(q20_tothhuse)) %>% 
    select_cv(q19_tshare, q20_tothhuse, h = 'q20_tothhuse')
)[[1]]


### Q21 - Toilet facility used by general public is blank/not in the valueset

## If Q19 (Sharing of toilet facility) = 1, Toilet facility used by general public should not be blank or should be 1 or 2.
(
  cv_q21_tshared_nitv <- section_q %>% 
    filter(q19_tshare == 1, is.na(q21_tshared)) %>% 
    select_cv(q19_tshare, q20_tothhuse, q21_tshared, h = 'q21_tshared')
)[[1]]


### Q21 - Q19 is 2 but with answer in Q21

## If Q19 (Sharing of toilet facility) = 2, Toilet facility used by general public should be blank.
(
  cv_q21_tshared_wval <- section_q %>% 
    filter(q19_tshare == 2, !is.na(q21_tshared)) %>% 
    select_cv(q19_tshare, q20_tothhuse, q21_tshared, h = 'q21_tshared')
)[[1]]


### Q22A-IZ - Segregating waste is blank/not in the valueset

## Segregating waste should not be blank or should be either from A to I, or Z 
(
  cv_q22_segregate_nitv <- section_q %>% 
    filter_at(vars(matches('^q22[a-iz]_.*'), -matches("fct$")), all_vars(!(. %in% c(1, 2)))) %>% 
    select_cv(
      matches('^q22[a-iz]_.*'), 
      h = c(
        'q22a_segregate',
        'q22b_truck',
        'q22c_rcycle',
        'q22d_sell',
        'q22e_compost',
        'q22f_burn',
        'q22g_dumpcover',
        'q22h_nocover',
        'q22i_throw',
        'q22z_others'
        )
      )
)[[1]]


### Q22 - There must be at least 1 yes in Q22

## From A to I and Z category in Segregating waste, There must be at least 1 yes.
(
  cv_q22allno <- section_q %>%
    filter_at(vars(matches('^q22[a-iz]_.*'), -matches("fct$")), all_vars(. == 2))%>%
    select_cv(
      matches('^q22[a-iz]_.*'), 
      h = c(
        'q22a_segregate',
        'q22b_truck',
        'q22c_rcycle',
        'q22d_sell',
        'q22e_compost',
        'q22f_burn',
        'q22g_dumpcover',
        'q22h_nocover',
        'q22i_throw',
        'q22z_others'
        ))
)[[1]]


### Q22Z - Answer is 'Yes' but not specified 


#### Cases with inconsistency

## If responded 'Yes' to Q22Z (other ways to dispose waste/garbage), answer must be specified.
(
  cv_q22_other_missing <- section_q %>% 
    filter(q22z_others == 1, is.na(q22za_others)) %>% 
    select_cv(q22z_others_fct, q22za_others, h = 'q22za_others')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q22_other <- section_q %>% 
    filter(q22z_others == 1, !is.na(q22za_others)) %>% 
    select_cv(q22z_others_fct, q22za_others)
)[[1]]



### Q23 - Handwashing facility is blank/not in the valueset

## Handwashing facility should not be blank or should be 1, 2, 3, 4, 5, or 9.
(
  cv_q23_whands_nitv <- section_q %>% 
    filter(!(q23_whands %in% c(1:5, 9))) %>% 
    select_cv(q23_whands, h = 'q23_whands')
)[[1]]


### Q23 - Answer is 9 but not specified 


#### Cases with inconsistency

## If responded 9 to Q23 (other handwashing facility), answer must be specified.
(
  cv_q23_other_missing <- section_q %>% 
    filter(q23_whands == 9, is.na(q23a_whands)) %>% 
    select_cv(q23_whands_fct, q23a_whands, h = 'q23a_whands')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q23_other <- section_q %>% 
    filter(q23_whands == 9, !is.na(q23a_whands)) %>% 
    select_cv(q23_whands_fct, q23a_whands)
)[[1]]



### Q24 - Presence of water in handwashing facility is blank/not in the valueset

## If Q23 (Handwashing facility) = 1, 2, 3, Presence of water in handwashing facility should not be blank or should be 1 or 2.
(
  cv_q24_preswater_nitv <- section_q %>% 
    filter(q23_whands %in% c(1:3), !(q24_preswater %in% c(1, 2))) %>% 
    select_cv(q24_preswater, h = 'q24_preswater')
)[[1]]


### Q24 - Q23 is 4,5,6 but with answer in Q24

## If Q23 (Handwashing facility) = 4, 5, 6, Presence of water in handwashing facility should be blank
(
  cv_q24_preswater_nitv <- section_q %>% 
    filter(q23_whands %in% c(4, 5, 9), !is.na(q24_preswater)) %>% 
    select_cv(q24_preswater, h = 'q24_preswater')
)[[1]]


### Q25 - Availability of soap/detergent is blank/not in the valueset

## If Q23 (Handwashing facility) = 1, 2, 3, Availability of soap/detergent should not be blank or should be 1 or 2.
(
  cv_q25_pressoap_nitv <- section_q %>% 
    filter(q23_whands %in% c(1:3), !(q25_pressoap %in% c(1, 2))) %>% 
    select_cv(q25_pressoap, h = 'q25_pressoap')
)[[1]]


### Q25 - Q23 is 4,5,9 but with answer in Q25

## If Q23 (Handwashing facility) = 4, 5, 9, Availability of soap/detergent should be blank
(
  cv_q25_pressoap_wval<- section_q %>% 
    filter(q23_whands %in% c(4, 5, 9), !is.na(q25_pressoap)) %>% 
    select_cv(q25_pressoap, h = 'q25_pressoap')
)[[1]]


### Q26 - Handwashing facility (NOT observed) is blank/not in the valueset

## If Q23 (Handwashing facility) = 5, Handwashing facility (NOT observed) should not be blank or should be 1, 2, 3, 4 or 9.
(
  cv_q26_werwhand_nitv <- section_q %>% 
    filter(q23_whands == 5, !(q26_werwhand %in% c(1:4, 9))) %>% 
    select_cv(q23_whands, q26_werwhand, h = 'q26_werwhand')
)[[1]]


### Q26 - Q23 is not 5 but with answer in Q26

## If Q23 (Handwashing facility) in not 5, Handwashing facility (NOT observed) should be blank
(
  cv_qq26_werwhand_wval <- section_q %>% 
    filter(q23_whands != 5, !is.na(q26_werwhand)) %>% 
    select_cv(q23_whands, q26_werwhand, h = 'q26_werwhand')
)[[1]]


### Q26 - Answer is 9 but not specified 


#### Cases with inconsistency

## If responded 9 to Q26 (other washing facility after using the toilet), answer must be specified.
(
  cv_q26_other_missing <- section_q %>% 
    filter(q26_werwhand == 9, is.na(q26a_werwhand)) %>% 
    select_cv(q26_werwhand_fct, q26a_werwhand, h = 'q26a_werwhand')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q26_other <- section_q %>% 
    filter(q26_werwhand == 9, !is.na(q26a_werwhand)) %>% 
    select_cv(q26_werwhand_fct, q26a_werwhand)
)[[1]]




### Q27 - Presence of water in handwashing facility (Not observed) is blank/not in the valueset

## If Q23 (Handwashing facility) = 4, 5, 9, Presence of water in handwashing facility (Not observed) should not be blank or should be 1 or 2
(
  cv_q27_availwhand_nitv <- section_q %>% 
    filter(q23_whands %in% c(4, 5, 9), !(q27_availwhand %in% c(1, 2))) %>% 
    select_cv(q23_whands, q27_availwhand, h = 'q27_availwhand')
)[[1]]


### Q27 - Q23 is not 4,5,9 but with answer in Q27

## If Q23 (Handwashing facility) is not 4, 9, Presence of water in handwashing facility (Not observed) should be blank
(
  cv_q27_availwhand_wval<- section_q %>% 
    filter(q23_whands %in% c(4, 9), !is.na(q26_werwhand)) %>% 
    select_cv(q23_whands, q27_availwhand, h = 'q27_availwhand')
)[[1]]


### Q28 - Availability of soap/detergent (Not observed) is blank/not in the valueset

## If Q25 (Availability of soap/detergent) = 2, Availability of soap/detergent (Not observed) should not be blank or should be 1 or 2.
(
  cv_q28_soap_nitv <- section_q %>% 
    filter(q25_pressoap == 2, !(q28_soap %in% c(1, 2))) %>% 
    select_cv(q25_pressoap, q28_soap, h = 'q28_soap')
)[[1]]


### Q28 - Q25 is 1 but with answer in Q26 to Q29.

## If Q25 (Availability of soap/detergent) = 1, Availability of soap/detergent (Not observed) should be blank.
(
  cv_q28_soap_wval <- section_q %>% 
    filter(q23_whands %in% c(1:3), q25_pressoap == 1) %>% 
    filter_at(vars(matches('^q2[6-8]_.*'), -matches('_fct$')), any_vars(!(is.na(.)))) %>% 
    select_cv(
      q25_pressoap, 
      matches('^q2[6-8]_.*'), 
      h = c(
        'q26_werwhand',
        'q27_availwhand',
        'q28_soap'
        )
      )
)[[1]]


### Q29 - Presence of Soap is blank/not in the valueset

## If Q23 (Handwashing facility) = 1, 2, 3, or Q25 (Availability of soap/detergent) = 2, Q28 (Availability of soap/detergent (Not observed)) = 1, Presence of Soap should not be blank or should be 1 or 2.
(
  cv_q29_show_nitv <- section_q %>% 
    filter(q23_whands %in% c(1:3) | q25_pressoap == 2, q28_soap == 1, !(q29_show %in% c(1, 2))) %>% 
    select_cv(q23_whands, q25_pressoap, q28_soap, q29_show, h = 'q29_show')
)[[1]]


### Q30 - Soap is blank/not in the valueset

## If Q25 (Availability of soap/detergent) = 1, or Q28 (Availability of soap/detergent (Not observed)) = 1, Q29 (Presence of Soap) = 1, Soap should not be blank or should be either from  A to C, or Z.
(
  cv_q30_sodert_nitv <- section_q %>% 
    filter(
      q25_pressoap == 1 | (q28_soap == 1 & q29_show == 1), 
      !(grepl('[A-CZ]+', str_trim(q30_sodert))) | is.na(q30_sodert)
    ) %>% 
    select_cv(q25_pressoap, q28_soap, q29_show, q30_sodert, h = 'q30_sodert')
)[[1]]


### Q30 - Q29 is 2 but with answer in Q30

## If Q29 (Presence of soap) = 2, Soap should be blank
(
  cv_q30_sodert1_wval <- section_q %>% 
    filter(q29_show == 2, str_trim(q30_sodert) != '' | !is.na(q30_sodert)) %>% 
    select_cv(q28_soap, q29_show, q30_sodert, h = 'q30_sodert')
)[[1]]


### Q30Z - Answer is 'Yes' but not specified 



#### Cases with inconsistency

## If responded 'Yes' to Q30Z (other soap/detergent), answer must be specified.
(
  cv_q30_other_missing <- section_q %>% 
    filter(grepl('Z', q30_sodert), is.na(q30a_sodert)) %>% 
    select_cv(q30_sodert, q30a_sodert, h = 'q30a_sodert')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_q30_other <- section_q %>% 
    filter(grepl('Z', q30_sodert), !is.na(q30a_sodert)) %>% 
    select_cv(q30_sodert, q30a_sodert, h = 'q30a_sodert')
)[[1]]