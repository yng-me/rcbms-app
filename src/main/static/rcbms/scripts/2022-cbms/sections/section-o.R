
# Section O {.unnumbered}

section_o1 <- hpq$section_o1 %>% 
  collect() %>% 
  filter_at(vars(matches('^o0[6-8].*'), -matches('_fct$')), any_vars(!is.na(.))) 

section_o <- hpq$section_o %>% 
  collect() %>% 
  filter_at(vars(matches('^o0[1-3].*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
  distinct(case_id, .keep_all = T) 

gather_by_crime <- function(data, pattern) {
  l <- paste0(str_sub(pattern, 1, 1), '_lno')
  pz <- paste0(str_sub(pattern, 1, 1), 'z?', str_sub(pattern, 2, -1))
  p <- paste0('^o0[5-8](', pz, '|', l, ')$')
  p_fct <- paste0('^o0[5-8](', pz, '|', l, ').*_fct$')
  o <- section_o %>% select(case_id, matches(paste0('^o03', pattern, '$'))) %>% 
    filter(!!as.name(paste0('o03', pattern)) == 1)
  data %>% 
    select(1:9, matches(p), matches(p_fct)) %>% 
    filter_at(vars(matches(p)), any_vars(!is.na(.))) %>% 
    left_join(o, by = 'case_id')
}



### O01 - Feel safe walking alone in the area is blank/is not in the valueset

## Feel safe walking alone in the area should have an answer or answer should be in the given categories.
(
  cv_o01_safewalk <- section_o %>% 
    filter(!(o01_safewalk %in% c(1:5, 8))) %>% 
    select_cv(o01_safewalk, h = 'o01_safewalk')
)[[1]]


### O02 - Victims of crime is blank/is not in the valueset

## Victims of crime should have an answer or answer should be in the given categories.
(
  cv_o02_victim_na <- section_o %>% 
  filter(!(o02_victim %in% c(1, 2))) %>% 
  select_cv(o02_victim, h = 'o02_victim')
)[[1]]


### O03 - Types of crime must be blank 

## Household is not victimized by crime, types of crime should be blank.
(
  cv_o02_victim_no <- section_o %>%
      filter(o02_victim == 2) %>% 
      filter_at(vars(matches('^o03.*'), -matches("fct$")), any_vars(!is.na(.))) %>% 
      select_cv(
        o02_victim, 
        matches('^o03.*'), 
        h = c(
          'o03a_theft',
          'o03b_robbery',
          'o03c_asthreat',
          'o03d_violence',
          'o03e_sxoff',
          'o03f_fraud',
          'o03g_corrupt',
          'o03i_vehtheft',
          'o03j_housbreak',
          'o03k_vandalism',
          'o03z_oth',
          'o03za_oth'
          )
        )
)[[1]]


### O03 - Types of crime is blank/is not in the valueset

## Household is victimized by crime, should have at least 1 yes in the types of crime.
(
  cv_o03az_theft_nitv <- section_o %>% 
    filter(o02_victim == 1) %>% 
    filter_at(vars(matches('^o03[a-kz]_.*'), -matches("fct$")), any_vars(!(. %in% c(1,2, 9)))) %>% 
    select_cv(
      matches('^o03[a-kz]_.*'), 
      h = c(
        'o03a_theft',
        'o03b_robbery',
        'o03c_asthreat',
        'o03d_violence',
        'o03e_sxoff',
        'o03f_fraud',
        'o03g_corrupt',
        'o03i_vehtheft',
        'o03j_housbreak',
        'o03k_vandalism',
        'o03z_oth'
          )      
      ,)
)[[1]]


### O04A - No/Invalid household member selected in the roster

## Household member/s was/were victimized by theft, but  no/invalid household member selected in the roster.
(
  cv_o04_a_theft <- section_o1 %>% 
    gather_by_crime('a_theft') %>% 
    filter(!is.na(o03a_theft), !(o05a_lno %in% c(1:35))) %>% 
    select_cv(o03a_theft, o05a_lno, h = 'o05a_lno')
)[[1]]


### O05A - Number of times became a victim/experienced crime is blank or not in the valueset

## Household member/s was/were victimized by theft, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_a_theft <- section_o1 %>% 
    gather_by_crime('a_theft') %>% 
    filter(!is.na(o03a_theft), !(o05a_theft %in% c(1:12))) %>% 
    select_cv(o03a_theft, o05a_theft, h = 'o05a_theft')
)[[1]]


### O06A - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by theft, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_a_theft <- section_o1 %>% 
   gather_by_crime('a_theft') %>% 
   filter(!is.na(o03a_theft), !(o06a_theft %in% c(1:4))) %>% 
   select_cv(o03a_theft, o06a_theft, h = 'o06a_theft')
)[[1]]


### O07A - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by theft, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_a_theft <- section_o1 %>% 
   gather_by_crime('a_theft') %>% 
   filter(!is.na(o03a_theft), !(o07a_theft %in% c(1, 2))) %>% 
   select_cv(o03a_theft, o07a_theft, h = 'o07a_theft')
)[[1]]


### O08A - Main reason for crime not being reported is blank or not in the valueset

## Crime - Theft was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_a_theft <- section_o1 %>% 
   gather_by_crime('a_theft') %>% 
   filter(!is.na(o03a_theft), o07a_theft == 2, !(o08a_theft %in% c(1:5, 9))) %>% 
   select_cv(o03a_theft, o07a_theft, o08a_theft, h = 'o08a_theft')
)[[1]]


### O08A - Main reason for crime not being reported should be blank

## Crime - Theft was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o06_a_theft_na <- section_o1 %>% 
   gather_by_crime('a_theft') %>% 
   filter(!is.na(o03a_theft), o07a_theft == 1, !is.na(o08a_theft)) %>% 
   select_cv(o03a_theft, o07a_theft, o08a_theft, h = 'o08a_theft')
)[[1]]


### O08A - Answer is 9 (other) but not specified 


#### Cases with inconsistency

## If responded 9 to O08A (other reason crime not reported), answer must be specified.
(
  cv_o08a_other_missing <- section_o1 %>%
    gather_by_crime('a_theft') %>% 
    filter(o07a_theft == 2, o08a_theft == 9, is.na(o08az_theft)) %>% 
    select_cv(o07a_theft_fct, o08a_theft_fct, o08az_theft, h = 'o08az_theft')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08a_other <- section_o1 %>%
    gather_by_crime('a_theft') %>% 
    filter(o07a_theft == 2, o08a_theft == 9, !is.na(o08az_theft)) %>% 
    select_cv(o08a_theft_fct, o08az_theft)
)[[1]]


### O04B - No/Invalid household member selected in the roster

## Household member/s was/were victimized by robbery, but  no/invalid household member selected in the roster.
(
  cv_o04_b_robbery <- section_o1 %>% 
    gather_by_crime('b_robbery') %>% 
    filter(!is.na(o03b_robbery), !(o05b_lno %in% c(1:35))) %>% 
    select_cv(o03b_robbery, o05b_lno, h = 'o05b_lno')
)[[1]]


### O05B - Number of times became a victim/experienced crime is blank or not in the valueset

## Household member/s was/were victimized by robbery, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_b_robbery <- section_o1 %>% 
    gather_by_crime('b_robbery') %>% 
    filter(!is.na(o03b_robbery), !(o05b_robbery %in% c(1:12))) %>% 
    select_cv(o03b_robbery, o05b_robbery, h = 'o05b_robbery')
)[[1]]


### O06B - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by robbery, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_b_robbery <- section_o1 %>% 
  gather_by_crime('b_robbery') %>% 
   filter(!is.na(o03b_robbery), !(o06b_robbery %in% c(1:4))) %>% 
   select_cv(o03b_robbery, o06b_robbery, h = 'o06b_robbery')
)[[1]]


### O07B - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by robbery, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_b_robbery <- section_o1 %>% 
   gather_by_crime('b_robbery') %>% 
   filter(!is.na(o03b_robbery), !(o07b_robbery %in% c(1, 2))) %>% 
   select_cv(o03b_robbery, o07b_robbery, h = 'o07b_robbery')
)[[1]]


### O08B - Main reason for crime not being reported is blank or not in the valueset

## Crime - Robbery was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_b_robbery <- section_o1 %>% 
   gather_by_crime('b_robbery') %>% 
   filter(!is.na(o03b_robbery), o07b_robbery == 2, !(o08b_robbery %in% c(1:5, 9))) %>% 
   select_cv(o03b_robbery, o07b_robbery, o08b_robbery, h = 'o08b_robbery')
)[[1]]


### O08B - Main reason for crime not being reported should be blank

## Crime - Robbery was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_b_robbery_na <- section_o1 %>%
   gather_by_crime('b_robbery') %>% 
   filter(!is.na(o03b_robbery), o07b_robbery == 1, !is.na(o08b_robbery)) %>% 
   select_cv(o03b_robbery, o07b_robbery, o08b_robbery, h = 'o08b_robbery')
)[[1]]


### O08B - Answer is 9 (other) but not specified 


#### Cases with inconsistency

## If responded 9 to O08B (other reason crime not reported), answer must be specified.
(
  cv_o08b_other_missing <- section_o1 %>%
    gather_by_crime('b_robbery') %>% 
    filter(o07b_robbery == 2, o08b_robbery == 9, is.na(o08bz_robbery)) %>% 
    select_cv(o07b_robbery_fct, o08b_robbery_fct, o08bz_robbery, h = 'o08bz_robbery')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08b_other <- section_o1 %>%
    gather_by_crime('b_robbery') %>% 
    filter(o07b_robbery == 2, o08b_robbery == 9, !is.na(o08bz_robbery)) %>% 
    select_cv(o08b_robbery_fct, o08bz_robbery)
)[[1]]



### O04C - No/Invalid household member selected in the roster

## Household member/s was/were victimized by assault/threat, but  no/invalid household member selected in the roster.
(
  cv_o04_c_asthreat <- section_o1 %>% 
    gather_by_crime('c_asthreat') %>% 
    filter(!is.na(o03c_asthreat), !(o05c_lno %in% c(1:35))) %>% 
    select_cv(o03c_asthreat, o05c_lno, h = 'o05c_lno')
)[[1]]


### O05C - Number of times became a victim/experienced crime is blank or not in the valueset

## Household member/s was/were victimized by assault/threat, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_c_asthreat <- section_o1 %>% 
    gather_by_crime('c_asthreat') %>% 
    filter(!is.na(o03c_asthreat), !(o05c_asthreat %in% c(1:12))) %>% 
    select_cv(o03c_asthreat, o05c_asthreat, h = 'o05c_asthreat')
)[[1]]


### O06C - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by assault/threat, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_c_asthreat <- section_o1 %>% 
  gather_by_crime('c_asthreat') %>% 
   filter(!is.na(o03c_asthreat), !(o06c_asthreat %in% c(1:4))) %>% 
   select_cv(o03c_asthreat, o06c_asthreat, h = 'o06c_asthreat')
)[[1]]


### O07C - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by assualt, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_c_asthreat <- section_o1 %>% 
   gather_by_crime('c_asthreat') %>% 
   filter(!is.na(o03c_asthreat), !(o07c_asthreat %in% c(1, 2))) %>% 
   select_cv(o03c_asthreat, o07c_asthreat, h = 'o07c_asthreat')
)[[1]]


### O08C - Main reason for crime not being reported is blank or not in the valueset

## Crime - Assault/Threat was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_c_asthreat <- section_o1 %>% 
   gather_by_crime('c_asthreat') %>% 
   filter(!is.na(o03c_asthreat), o07c_asthreat == 2, !(o08c_asthreat %in% c(1:5, 9))) %>% 
   select_cv(o03c_asthreat, o07c_asthreat, o08c_asthreat, h = 'o08c_asthreat')
)[[1]]


### O08C - Main reason for crime not being reported should be blank

## Crime - Assault/Threat was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_c_asthreat_na <- section_o1 %>%
   gather_by_crime('c_asthreat') %>% 
   filter(!is.na(o03c_asthreat), o07c_asthreat == 1, !is.na(o08c_asthreat)) %>% 
   select_cv(o03c_asthreat, o07c_asthreat, o08c_asthreat, h = 'o08c_asthreat')
)[[1]]


### O08C - Answer is 9 (other) but not specified 


#### Cases with inconsistency

## If responded 9 to O08C (other reason crime not reported), answer must be specified.
(
  cv_o08c_other_missing <- section_o1 %>%
    gather_by_crime('c_asthreat') %>% 
    filter(o07c_asthreat == 2, o08c_asthreat == 9, is.na(o08cz_asthreat)) %>% 
    select_cv(o07c_asthreat_fct, o08c_asthreat_fct, o08cz_asthreat, h = 'o08cz_asthreat')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08c_other <- section_o1 %>%
    gather_by_crime('c_asthreat') %>% 
    filter(o07c_asthreat == 2, o08c_asthreat == 9, !is.na(o08cz_asthreat)) %>% 
    select_cv(o08c_asthreat_fct, o08cz_asthreat)
)[[1]]



### O04D - No/Invalid household member selected in the roster

## Household member/s was/were victimized by psychological violence, but  no/invalid household member selected in the roster.
(
  cv_o04_d_violence <- section_o1 %>% 
    gather_by_crime('d_violence') %>% 
    filter(!is.na(o03d_violence), !(o05d_lno %in% c(1:35))) %>% 
    select_cv(o03d_violence, o05d_lno, h = 'o05d_lno')
)[[1]]


### O05D - Number of times became a victim/experienced crime is blank or not in the valueset

## Household member/s was/were victimized by psychological violence, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_d_violence <- section_o1 %>% 
    gather_by_crime('d_violence') %>% 
    filter(!is.na(o03d_violence), !(o05d_violence %in% c(1:12))) %>% 
    select_cv(o03d_violence, o05d_violence, h = 'o05d_violence')
)[[1]]


### O06D - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by psychological violence, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_d_violence <- section_o1 %>% 
  gather_by_crime('d_violence') %>% 
   filter(!is.na(o03d_violence), !(o06d_violence %in% c(1:4))) %>% 
   select_cv(o03d_violence, o06d_violence, h = 'o06d_violence')
)[[1]]


### O07D - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by psychological violence, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_d_violence <- section_o1 %>% 
   gather_by_crime('d_violence') %>% 
   filter(!is.na(o03d_violence), !(o07d_violence %in% c(1, 2))) %>% 
   select_cv(o03d_violence, o07d_violence, h = 'o07d_violence')
)[[1]]


### O08D - Main reason for crime not being reported is blank or not in the valueset

## Crime - Psychological violence was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_d_violence <- section_o1 %>% 
   gather_by_crime('d_violence') %>% 
   filter(!is.na(o03d_violence), o07d_violence == 2, !(o08d_violence %in% c(1:5, 9))) %>% 
   select_cv(o03d_violence, o07d_violence, o08d_violence, h = 'o08d_violence')
)[[1]]


### O08D - Main reason for crime not being reported should be blank

## Crime - Psychological violence was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_d_violence_na <- section_o1 %>%
   gather_by_crime('d_violence') %>% 
   filter(!is.na(o03d_violence), o07d_violence == 1, !is.na(o08d_violence)) %>% 
   select_cv(o03d_violence, o07d_violence, o08d_violence, h = 'o08d_violence')
)[[1]]


### O08D - Answer is 9 (other) but not specified 


#### Cases with inconsistency

## If responded 9 to O08D (other reason crime not reported), answer must be specified.
(
  cv_o08d_other_missing <- section_o1 %>%
    gather_by_crime('d_violence') %>% 
    filter(o07d_violence == 2, o08d_violence == 9, is.na(o08dz_violence)) %>% 
    select_cv(o07d_violence_fct, o08d_violence_fct, o08dz_violence, h = 'o08dz_violence')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08d_other <- section_o1 %>%
    gather_by_crime('d_violence') %>% 
    filter(o07d_violence == 2, o08d_violence == 9, !is.na(o08dz_violence)) %>% 
    select_cv(o08d_violence_fct, o08dz_violence)
)[[1]]


### O04E - No/Invalid household member selected in the roster

## Household member/s was/were victimized by sexual offense but  no/invalid household member selected in the roster.
(
  cv_o04_e_sxoff <- section_o1 %>% 
    gather_by_crime('e_sxoff') %>% 
    filter(!is.na(o03e_sxoff), !(o05e_lno %in% c(1:35))) %>% 
    select_cv(o03e_sxoff, o05e_lno, h = 'o05e_lno')
)[[1]]


### O05E - Number of times became a victim/experienced crime is blank or not in the valueset

## Household member/s was/were victimized by sexual offense, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_e_sxoff <- section_o1 %>% 
    gather_by_crime('e_sxoff') %>% 
    filter(!is.na(o03e_sxoff), !(o05e_sxoff %in% c(1:12))) %>% 
    select_cv(o03e_sxoff, o05e_sxoff, h = 'o05e_sxoff')
)[[1]]


### O06E - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by sexual offense, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_e_sxoff <- section_o1 %>% 
  gather_by_crime('e_sxoff') %>% 
   filter(!is.na(o03e_sxoff), !(o06e_sxoff %in% c(1:4))) %>% 
   select_cv(o03e_sxoff, o06e_sxoff, h = 'o06e_sxoff')
)[[1]]


### O07E - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by sexual offense, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_e_sxoff <- section_o1 %>% 
   gather_by_crime('e_sxoff') %>% 
   filter(!is.na(o03e_sxoff), !(o07e_sxoff %in% c(1, 2))) %>% 
   select_cv(o03e_sxoff, o07e_sxoff, h = 'o07e_sxoff')
)[[1]]


### O08E - Main reason for crime not being reported is blank or not in the valueset

## Crime - Sexual offense was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_e_sxoff <- section_o1 %>% 
   gather_by_crime('e_sxoff') %>% 
   filter(!is.na(o03e_sxoff), o07e_sxoff == 2, !(o08e_sxoff %in% c(1:5, 9))) %>% 
   select_cv(o03e_sxoff, o07e_sxoff, o08e_sxoff, h = 'o08e_sxoff')
)[[1]]


### O08E - Main reason for crime not being reported should be blank

## Crime - Sexual offense was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_e_sxoff_na <- section_o1 %>%
   gather_by_crime('e_sxoff') %>% 
   filter(!is.na(o03e_sxoff), o07e_sxoff == 1, !is.na(o08e_sxoff)) %>% 
   select_cv(o03e_sxoff, o07e_sxoff, o08e_sxoff, h = 'o08e_sxoff')
)[[1]]


### O08E - Answer is 9 (other) but not specified 



#### Cases with inconsistency

## If responded 9 to O08E (other reason crime not reported), answer must be specified.
(
  cv_o08e_other_missing <- section_o1 %>%
    gather_by_crime('e_sxoff') %>% 
    filter(o07e_sxoff == 2, o08e_sxoff == 9, is.na(o08ez_sxoff)) %>% 
    select_cv(o07e_sxoff_fct, o08e_sxoff_fct, o08ez_sxoff, h = 'o08ez_sxoff')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08e_other <- section_o1 %>%
    gather_by_crime('e_sxoff') %>% 
    filter(o07e_sxoff == 2, o08e_sxoff == 9, !is.na(o08ez_sxoff)) %>% 
    select_cv(o08e_sxoff_fct, o08ez_sxoff)
)[[1]]



### O04F - No/Invalid household member selected in the roster

## Household member/s was/were victimized by fraud, but  no/invalid household member selected in the roster.
(
  cv_o04_f_fraud <- section_o1 %>% 
    gather_by_crime('f_fraud') %>% 
    filter(!is.na(o03f_fraud), !(o05f_lno %in% c(1:35))) %>% 
    select_cv(o03f_fraud, o05f_lno, h = 'o05f_lno')
)[[1]]


### O05F - Number of times became a victim/experienced crime is blank or not in the valueset

## Household member/s was/were victimized by fraud, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_f_fraud <- section_o1 %>% 
    gather_by_crime('f_fraud') %>% 
    filter(!is.na(o03f_fraud), !(o05f_fraud %in% c(1:12))) %>% 
    select_cv(o03f_fraud, o05f_fraud, h = 'o05f_fraud')
)[[1]]


### O06F - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by fraud, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_f_fraud <- section_o1 %>% 
  gather_by_crime('f_fraud') %>% 
   filter(!is.na(o03f_fraud), !(o06f_fraud %in% c(1:4))) %>% 
   select_cv(o03f_fraud, o06f_fraud, h = 'o06f_fraud')
)[[1]]



### O07F - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by fraud, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_f_fraud <- section_o1 %>% 
   gather_by_crime('f_fraud') %>% 
   filter(!is.na(o03f_fraud), !(o07f_fraud %in% c(1, 2))) %>% 
   select_cv(o03f_fraud, o07f_fraud, h = 'o07f_fraud')
)[[1]]


### O08F - Main reason for crime not being reported is blank or not in the valueset

## Crime - Fraud was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_f_fraud <- section_o1 %>% 
   gather_by_crime('f_fraud') %>% 
   filter(!is.na(o03f_fraud), o07f_fraud == 2, !(o08f_fraud %in% c(1:5, 9))) %>% 
   select_cv(o03f_fraud, o07f_fraud, o08f_fraud, h = 'o08f_fraud')
)[[1]]


### O08F - Main reason for crime not being reported should be blank

## Crime - Fraud was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_f_fraud_na <- section_o1 %>%
   gather_by_crime('f_fraud') %>% 
   filter(!is.na(o03f_fraud), o07f_fraud == 1, !is.na(o08f_fraud)) %>% 
   select_cv(o03f_fraud, o07f_fraud, o08f_fraud, h = 'o08f_fraud')
)[[1]]


### O08F - Answer is 9 (other) but not specified 



#### Cases with inconsistency

## If responded 9 to O08F (other reason crime not reported), answer must be specified.
(
  cv_o08f_other_missing <- section_o1 %>%
    gather_by_crime('f_fraud') %>% 
    filter(o07f_fraud == 2, o08f_fraud == 9, is.na(o08fz_fraud)) %>% 
    select_cv(o07f_fraud_fct, o08f_fraud_fct, o08fz_fraud, h = 'o08fz_fraud')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08f_other <- section_o1 %>%
    gather_by_crime('f_fraud') %>% 
    filter(o07f_fraud == 2, o08f_fraud == 9, !is.na(o08fz_fraud)) %>% 
    select_cv(o08f_fraud_fct, o08fz_fraud)
)[[1]]



### O04G - No/Invalid household member selected in the roster

## Household member/s was/were victimized by corruption, but  no/invalid household member selected in the roster.
(
  cv_o04_g_corrupt <- section_o1 %>% 
    gather_by_crime('g_corrupt') %>% 
    filter(!is.na(o03g_corrupt), !(o05g_lno %in% c(1:35))) %>% 
    select_cv(o03g_corrupt, o05g_lno, h = 'o05g_lno')
)[[1]]


### O05G - Number of times became a victim/experienced crime is blank or not in the valueset

## Household member/s was/were victimized by corruption, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_g_corrupt <- section_o1 %>% 
    gather_by_crime('g_corrupt') %>% 
    filter(!is.na(o03g_corrupt), !(o05g_corrupt %in% c(1:12))) %>% 
    select_cv(o03g_corrupt, o05g_corrupt, h = 'o05g_corrupt')
)[[1]]


### O06G - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by corruption, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_g_corrupt <- section_o1 %>% 
  gather_by_crime('g_corrupt') %>% 
   filter(!is.na(o03g_corrupt), !(o06g_corrupt %in% c(1:4))) %>% 
   select_cv(o03g_corrupt, o06g_corrupt, h = 'o06g_corrupt')
)[[1]]


### O07G - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by corruption, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_g_corrupt <- section_o1 %>% 
   gather_by_crime('g_corrupt') %>% 
   filter(!is.na(o03g_corrupt), !(o07g_corrupt %in% c(1, 2))) %>% 
   select_cv(o03g_corrupt, o07g_corrupt, h = 'o07g_corrupt')
)[[1]]


### O08G - Main reason for crime not being reported is blank or not in the valueset

## Crime - Corruption was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_g_corrupt <- section_o1 %>% 
   gather_by_crime('g_corrupt') %>% 
   filter(!is.na(o03g_corrupt), o07g_corrupt == 2, !(o08g_corrupt %in% c(1:5, 9))) %>% 
   select_cv(o03g_corrupt, o07g_corrupt, o08g_corrupt, h = 'o08g_corrupt')
)[[1]]


### O08G - Main reason for crime not being reported should be blank

## Crime - Corruption was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_g_corrupt_na <- section_o1 %>%
   gather_by_crime('g_corrupt') %>% 
   filter(!is.na(o03g_corrupt), o07g_corrupt == 1, !is.na(o08g_corrupt)) %>% 
   select_cv(o03g_corrupt, o07g_corrupt, o08g_corrupt, h = 'o08g_corrupt')
)[[1]]


### O08G - Answer is 9 (other) but not specified 



#### Cases with inconsistency

## If responded 9 to O08G (other reason crime not reported), answer must be specified.
(
  cv_o08g_other_missing <- section_o1 %>%
    gather_by_crime('g_corrupt') %>% 
    filter(o07g_corrupt == 2, o08g_corrupt == 9, is.na(o08gz_corrupt)) %>% 
    select_cv(o07g_corrupt_fct, o08g_corrupt_fct, o08gz_corrupt, h = 'o08gz_corrupt')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08g_other <- section_o1 %>%
    gather_by_crime('g_corrupt') %>% 
    filter(o07g_corrupt == 2, o08g_corrupt == 9, !is.na(o08gz_corrupt)) %>% 
    select_cv(o08g_corrupt_fct, o08gz_corrupt)
)[[1]]



### O05I - Number of times became a victim/experienced crime is blank or not in the valueset

## Household was victimized by vehicle theft, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_i_vehtheft <- section_o1 %>% 
    gather_by_crime('i_vehtheft') %>% 
    filter(!is.na(o03i_vehtheft), !(o05i_vehtheft %in% c(1:12))) %>% 
    select_cv(o03i_vehtheft, o05i_vehtheft, h = 'o05i_vehtheft')
)[[1]]


### O06I - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by vehiclectheft, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_i_vehtheft <- section_o1 %>% 
  gather_by_crime('i_vehtheft') %>% 
   filter(!is.na(o03i_vehtheft), !(o06i_vehtheft %in% c(1:4))) %>% 
   select_cv(o03i_vehtheft, o06i_vehtheft, h = 'o06i_vehtheft')
)[[1]]


### O07I - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by vehicle theft, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_i_vehtheft <- section_o1 %>% 
   gather_by_crime('i_vehtheft') %>% 
   filter(!is.na(o03i_vehtheft), !(o07i_vehtheft %in% c(1, 2))) %>% 
   select_cv(o03i_vehtheft, o07i_vehtheft, h = 'o07i_vehtheft')
)[[1]]


### O08I - Main reason for crime not being reported is blank or not in the valueset

## Crime - Vehicle theft was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_i_vehtheft <- section_o1 %>% 
   gather_by_crime('i_vehtheft') %>% 
   filter(!is.na(o03i_vehtheft), o07i_vehtheft == 2, !(o08i_vehtheft %in% c(1:5, 9))) %>% 
   select_cv(o03i_vehtheft, o07i_vehtheft, o08i_vehtheft, h = 'o08i_vehtheft')
)[[1]]


### O08I - Main reason for crime not being reported should be blank

## Crime - Vehicle theft was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_i_vehtheft_na <- section_o1 %>%
   gather_by_crime('i_vehtheft') %>% 
   filter(!is.na(o03i_vehtheft), o07i_vehtheft == 1, !is.na(o08i_vehtheft)) %>% 
   select_cv(o03i_vehtheft, o07i_vehtheft, o08i_vehtheft, h = 'o08i_vehtheft')
)[[1]]


### O08I - Answer is 9 (other) but not specified 



#### Cases with inconsistency

## If responded 9 to O08I (other reason crime not reported), answer must be specified.
(
  cv_o08i_other_missing <- section_o1 %>%
    gather_by_crime('i_vehtheft') %>% 
    filter(o07i_vehtheft == 2, o08i_vehtheft == 9, is.na(o08iz_vehtheft)) %>% 
    select_cv(o07i_vehtheft_fct, o08i_vehtheft_fct, o08iz_vehtheft, h = 'o08iz_vehtheft')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08i_other <- section_o1 %>%
    gather_by_crime('i_vehtheft') %>% 
    filter(o07i_vehtheft == 2, o08i_vehtheft == 9, !is.na(o08iz_vehtheft)) %>% 
    select_cv(o08i_vehtheft_fct, o08iz_vehtheft)
)[[1]]





### O05J - Number of times became a victim/experienced crime is blank or not in the valueset

## Household was victimized by house breaking, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_j_housbreak <- section_o1 %>% 
    gather_by_crime('j_housbreak') %>% 
    filter(!is.na(o03j_housbreak), !(o05j_housbreak %in% c(1:12))) %>% 
    select_cv(o03j_housbreak, o05j_housbreak, h = 'o05j_housbreak')
)[[1]]


### O06J - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by house breaking, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_j_housbreak <- section_o1 %>% 
  gather_by_crime('j_housbreak') %>% 
   filter(!is.na(o03j_housbreak), !(o06j_housbreak %in% c(1:4))) %>% 
   select_cv(o03j_housbreak, o06j_housbreak, h = 'o06j_housbreak')
)[[1]]


### O07J - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by house breaking, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_j_housbreak <- section_o1 %>% 
   gather_by_crime('j_housbreak') %>% 
   filter(!is.na(o03j_housbreak), !(o07j_housbreak %in% c(1, 2))) %>% 
   select_cv(o03j_housbreak, o07j_housbreak, h = 'o07j_housbreak')
)[[1]]


### O08J - Main reason for crime not being reported is blank or not in the valueset

## Crime - House breaking was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_j_housbreak <- section_o1 %>% 
   gather_by_crime('j_housbreak') %>% 
   filter(!is.na(o03j_housbreak), o07j_housbreak == 2, !(o08j_housbreak %in% c(1:5, 9))) %>% 
   select_cv(o03j_housbreak, o07j_housbreak, o08j_housbreak, h = 'o08j_housbreak')
)[[1]]


### O08J - Main reason for crime not being reported should be blank

## Crime - Housebreaking was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_j_housbreak_na <- section_o1 %>%
   gather_by_crime('j_housbreak') %>% 
   filter(!is.na(o03j_housbreak), o07j_housbreak == 1, !is.na(o08j_housbreak)) %>% 
   select_cv(o03j_housbreak, o07j_housbreak, o08j_housbreak, h = 'o08j_housbreak')
)[[1]]


### O08J - Answer is 9 (other) but not specified 



#### Cases with inconsistency

## If responded 9 to O08J (other reason crime not reported), answer must be specified.
(
  cv_o08j_other_missing <- section_o1 %>%
    gather_by_crime('j_housbreak') %>% 
    filter(o07j_housbreak == 2, o08j_housbreak == 9, is.na(o08jz_housbreak)) %>% 
    select_cv(o07j_housbreak_fct, o08j_housbreak_fct, o08jz_housbreak, h = 'o08jz_housbreak')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08j_other <- section_o1 %>%
    gather_by_crime('j_housbreak') %>% 
    filter(o07j_housbreak == 2, o08j_housbreak == 9, !is.na(o08jz_housbreak)) %>% 
    select_cv(o08j_housbreak_fct, o08jz_housbreak)
)[[1]]



### O05K - Number of times became a victim/experienced crime is blank or not in the valueset.

## Household member/s was/were victimized by vandalism, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_k_vandalism <- section_o1 %>% 
    gather_by_crime('k_vandalism') %>% 
    filter(!is.na(o03k_vandalism), !(o05k_vandalism %in% c(1:12))) %>% 
    select_cv(o03k_vandalism, o05k_vandalism, h = 'o05k_vandalism')
)[[1]]


### O06K - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by vandalism, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_k_vandalism <- section_o1 %>% 
  gather_by_crime('k_vandalism') %>% 
   filter(!is.na(o03k_vandalism), !(o06k_vandalism %in% c(1:4))) %>% 
   select_cv(o03k_vandalism, o06k_vandalism, h = 'o06k_vandalism')
)[[1]]


### O07K - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by vandalism, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_k_vandalism <- section_o1 %>% 
   gather_by_crime('k_vandalism') %>% 
   filter(!is.na(o03k_vandalism), !(o07k_vandalism %in% c(1, 2))) %>% 
   select_cv(o03k_vandalism, o07k_vandalism, h = 'o07k_vandalism')
)[[1]]


### O08K - Main reason for crime not being reported is blank or not in the valueset

## Crime - Vandalism was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_k_vandalism <- section_o1 %>% 
   gather_by_crime('k_vandalism') %>% 
   filter(!is.na(o03k_vandalism), o07k_vandalism == 2, !(o08k_vandalism %in% c(1:5, 9))) %>% 
   select_cv(o03k_vandalism, o07k_vandalism, o08k_vandalism, h = 'o08k_vandalism')
)[[1]]


### O08K - Main reason for crime not being reported should be blank

## Crime - Valdalism was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_k_vandalism_na <- section_o1 %>%
   gather_by_crime('k_vandalism') %>% 
   filter(!is.na(o03k_vandalism), o07k_vandalism == 1, !is.na(o08k_vandalism)) %>% 
   select_cv(o03k_vandalism, o07k_vandalism, o08k_vandalism, h = 'o08k_vandalism')
)[[1]]


### O08K - Answer is 9 (other) but not specified 



#### Cases with inconsistency

## If responded 9 to O08K (other reason crime not reported), answer must be specified.
(
  cv_o08k_other_missing <- section_o1 %>%
    gather_by_crime('k_vandalism') %>% 
    filter(o07k_vandalism == 2, o08k_vandalism == 9, is.na(o08kz_vandalism)) %>% 
    select_cv(o07k_vandalism_fct, o08k_vandalism_fct, o08kz_vandalism, h = 'o08kz_vandalism')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08k_other <- section_o1 %>%
    gather_by_crime('k_vandalism') %>% 
    filter(o07k_vandalism == 2, o08k_vandalism == 9, !is.na(o08kz_vandalism)) %>% 
    select_cv(o08k_vandalism_fct, o08kz_vandalism)
)[[1]]




### O04Z - No/Invalid household member selected in the roster

## Household member/s was/were victimized by other type of crime, but  no/invalid household member selected in the roster.
(
  cv_o04_z_oth <- section_o1 %>% 
    gather_by_crime('z_oth') %>% 
    filter(!is.na(o03z_oth), !(o05z_lno %in% c(1:35))) %>% 
    select_cv(o03z_oth, o05z_lno, h = 'o05z_lno')
)[[1]]


### O05Z - Number of times became a victim/experienced crime is blank or not in the valueset

## Household member/s was/were victimized by other type of crime, but the number of times victimized by crime should have an answer or should be from 1 to 12.
(
  cv_o05_z_oth <- section_o1 %>% 
    gather_by_crime('z_oth') %>% 
    filter(!is.na(o03z_oth), !(o05z_oth %in% c(1:12))) %>% 
    select_cv(o03z_oth, o05z_oth, h = 'o05z_oth')
)[[1]]


### O06Z - Location of most recent crime is blank or not in the valueset

## Household member/s was/were victimized by other crimes, but the location of most recent crime should have an answer or should be from 1 to 4.
(
 cv_o06_z_oth <- section_o1 %>% 
  gather_by_crime('z_oth') %>% 
   filter(!is.na(o03z_oth), !(o06z_oth %in% c(1:4))) %>% 
   select_cv(o03z_oth, o06z_oth, h = 'o06z_oth')
)[[1]]


### O07Z - Crime reported to the police/barangay is blank or not in the valueset

## Household member/s was/were victimized by other crime, but the question if the crime was reported to the police/barangay should have an answer or should be from 1 or 2.
(
 cv_o07_z_oth <- section_o1 %>% 
   gather_by_crime('z_oth') %>% 
   filter(!is.na(o03z_oth), !(o07z_oth %in% c(1, 2))) %>% 
   select_cv(o03z_oth, o07z_oth, h = 'o07z_oth')
)[[1]]


### O08Z - Main reason for crime not being reported is blank or not in the valueset

## Other type of crime was not reported to the police/barangay, main reason for crime not being reported should have an answer or should be in the give categories.
(
 cv_o08_z_oth <- section_o1 %>% 
   gather_by_crime('z_oth') %>% 
   filter(!is.na(o03z_oth), o07z_oth == 2, !(o08z_oth %in% c(1:5, 9))) %>% 
   select_cv(o03z_oth, o07z_oth, o08z_oth, h = 'o08z_oth')
)[[1]]


### O08Z - Main reason for crime not being reported should be blank

## Other type of crime was reported to the police/barangay, main reason for crime not being reported should be blank.
(
 cv_o08_z_oth_na <- section_o1 %>%
   gather_by_crime('z_oth') %>% 
   filter(!is.na(o03z_oth), o07z_oth == 1, !is.na(o08z_oth)) %>% 
   select_cv(o03z_oth, o07z_oth, o08z_oth, h = 'o08z_oth')
)[[1]]


### O08Z - Answer is 9 (other) but not specified 



#### Cases with inconsistency

## If responded 9 to O08Z (other reason crime not reported), answer must be specified.
(
  cv_o08z_other_missing <- section_o1 %>%
    gather_by_crime('z_oth') %>% 
    filter(o07z_oth == 2, o08z_oth == 9, is.na(o08zz_oth)) %>% 
    select_cv(o08z_oth_fct, o08zz_oth, h = 'o08zz_oth')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_o08z_other <- section_o1 %>%
    gather_by_crime('z_oth') %>% 
    filter(o07z_oth == 2, o08z_oth == 9, !is.na(o08zz_oth)) %>% 
    select_cv(o08z_oth_fct, o08zz_oth)
)[[1]]