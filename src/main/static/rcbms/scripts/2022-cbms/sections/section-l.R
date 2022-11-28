
# Section L {.unnumbered}

ref_age_sex <- hpq$section_a %>% 
  select(line_number_id, a05_sex, age) %>% 
  collect()

ref_hh_count <- hpq$section_a %>% 
  collect() %>% 
  count(case_id)

section_l <- hpq$section_l %>% 
  collect() %>% 
  filter_at(vars(matches('^l.*')), any_vars(!is.na(.)))

section_l1 <- hpq$section_l1 %>% 
  collect() %>% 
  filter_at(vars(matches('^l.*')), any_vars(!is.na(.)))

with_female_10_yr <- hpq$section_a %>% 
  filter(age >= 10, a05_sex == 2) %>% 
  collect() %>% 
  distinct(case_id) %>% 
  mutate(with_female = 1L)

# L01-L05 (Female 10 years old and over)
section_l01 <- section_l %>% 
  select(1:5, ean, l01_preg, l06_cpreg, l06_cpreg_fct, l08_lactmom, l08_lactmom_fct) %>% 
  left_join(with_female_10_yr, by = 'case_id') %>% 
  mutate(with_female = if_else(is.na(with_female), 0L, with_female)) 

section_l01_05 <- section_l1 %>%
  select(case_id, matches('^l0[2-5].*')) %>% 
  left_join(section_l01, by = 'case_id') %>% 
  filter(with_female == 1) %>% 
  left_join(ref_hh_count, by = 'case_id')

# L06-L07 (Pregnant)
section_l06_07 <- section_l1 %>%
  select(case_id, l07_lno) %>%   left_join(dplyr::select(section_l, 1:5, ean, l06_cpreg, l06_cpreg_fct), by = 'case_id') %>% 
  mutate(line_number_id = if_else(is.na(l07_lno), '', paste0(case_id, sprintf('%02d', as.integer(l07_lno))))) %>% 
  na_if('') %>% 
  left_join(ref_age_sex, by = 'line_number_id') %>% 
  left_join(ref_hh_count, by = 'case_id')

# L08-L09 (Lactating)
section_l08_09 <- section_l1 %>% 
  select(case_id, l09_lno) %>% 
  left_join(dplyr::select(section_l, 1:5, ean, l08_lactmom, l08_lactmom_fct), by = 'case_id') %>% 
  mutate(line_number_id = if_else(is.na(l09_lno), '', paste0(case_id, sprintf('%02d', as.integer(l09_lno))))) %>% 
  na_if('') %>% 
  left_join(ref_age_sex, by = 'line_number_id') %>% 
  left_join(ref_hh_count, by = 'case_id')

# L10-14 (Child mortality)
section_l10_14 <- section_l1 %>% 
  select(case_id, matches('l1[1-4].*')) %>% 
  left_join(dplyr::select(section_l, 1:5, ean, l10_tyzfdied, l10_tyzfdied_fct, l10a_nochlddied), by = 'case_id')

# L15-18 (PWD)
section_l15_18 <- section_l1 %>%
  select(case_id, matches('^l1[5-8].*')) %>% 
  left_join(dplyr::select(section_l, 1:5, ean, l15_dis, l15_dis_fct), by = 'case_id') %>% 
  left_join(ref_hh_count, by = 'case_id')

# L19-20 (Cancer patient)
section_l19_20 <- section_l1 %>% 
  select(case_id, l20_lno) %>% 
  left_join(dplyr::select(section_l, 1:5, ean, l19_cancerpw, l19_cancerpw_fct), by = 'case_id') %>% 
  left_join(ref_hh_count, by = 'case_id')

# L21-22 (Cancer survivor)
section_l21_22 <- section_l1 %>% 
  select(case_id, l22_lno) %>% 
  left_join(dplyr::select(section_l, 1:5, ean, l21_cancersur, l21_cancersur_fct), by = 'case_id') %>% 
  left_join(ref_hh_count, by = 'case_id')

# L23-L28 (Rare disease)
section_l23_28 <- section_l1 %>%
  select(case_id, matches('^l2[4-8].*')) %>%
  left_join(dplyr::select(section_l, 1:5, ean, l23_raredis, l23_raredis_fct), by = 'case_id') %>%
  left_join(ref_hh_count, by = 'case_id')

# L29-L32 (Rare disease)
section_l29_32 <- section_l1 %>%
  select(case_id, matches('^l3[0-2].*')) %>%
  left_join(dplyr::select(section_l, 1:5, ean, l15_dis, l15_dis_fct, l29_pwdid, l29_pwdid_fct), by = 'case_id') %>%
  left_join(ref_hh_count, by = 'case_id')

# L33-L41 (Ill/sick/injured)
section_l33_41 <- section_l1 %>%
  select(case_id, matches('^l(3[4-9]|4[0-1]).*')) %>%
  left_join(dplyr::select(section_l, 1:5, ean, l33_tmsick, l33_tmsick_fct), by = 'case_id') %>%
  left_join(ref_hh_count, by = 'case_id') %>%
  mutate(line_number_id = if_else(is.na(l34_lno), '', paste0(case_id, sprintf('%02d', as.integer(l34_lno))))) %>%
  na_if('') %>%
  left_join(ref_age_sex, by = 'line_number_id')
  

gather_by_disability <- function(data) {
  d <- c(
    'A. Visual disability',
    'B. Deaf or hearing disability',
    'C. Intellectual disability',
    'D. Learning disability',
    'E. Mental disability',
    'F. Physical disability (orthopedic)',
    'G. Psychological disability',
    'H. Speech and language impairment',
    'Z. Other'
  )
  l <- c(letters[1:8], 'z')
  letter <- paste0('^l1[78]', l, '_(typedis|disdiagnosed)$')
  df <- list()
  for(i in 1:length(l)) {
    df[[i]] <- data %>%
      select(1:7, matches(letter[i]), -matches('_fct$')) %>%
      mutate(Type = d[i]) %>%
      rename(
        Disability = 8,
        Diagnosed = 9
      )
  }
  return(do.call('rbind', df) %>% tibble())
}


### L01 - With female members 10 years old and over but missing/invalid response

## L01 must be not be blank/invalid if there is at least one female member 10 years old and over.
(
  cv_l01_with_female <- section_l01 %>% 
    filter(with_female == 1, !(l01_preg %in% c(1, 2))) %>% 
    select_cv(l01_preg, h = 'l01_preg')
)[[1]]


### L01 - No female members 10 years old and over but with answer in L01

## L01 must be skipped if there is no qualified female members (10 years old and over).
(
  cv_l01_with_female_na <- section_l01 %>% 
    filter(with_female == 0, !is.na(l01_preg)) %>% 
    select_cv(l01_preg, h = 'l01_preg')
)[[1]]


### L02 - Missing/invalid line number of respondent

## Answered 'Yes' in L01 but line number of household member is missing/invalid.
(
  cv_l02_lno <- section_l01_05 %>% 
    filter(l01_preg == 1, as.integer(l02_lno) < 1 | as.integer(l02_lno) > n) %>% 
    select_cv(l01_preg, l02_lno, n, h = 'l02_lno')
)[[1]]


### L02 - Male who had live births

## Selected household member (line number) is male. Only qualified household member must be selected in L02 (female 10 years old and over).
pregnant_male_n <- section_l01_05 %>% 
  filter(l01_preg == 1) %>% 
  nrow

if(pregnant_male_n > 0) {
  (
    cv_l02_male <- section_l01_05 %>% 
      filter(l01_preg == 1) %>% 
      mutate(line_number_id = if_else(is.na(l02_lno), '', paste0(case_id, sprintf('%02d', as.integer(l02_lno))))) %>% 
      na_if('') %>% 
      left_join(ref_age_sex, by = 'line_number_id') %>% 
      filter(a05_sex == 1) %>% 
      select_cv(l02_lno, a05_sex, h = 'a05_sex')
  )[[1]]
} else {
  (
    cv_l02_male <- section_l01_05 %>% 
      filter(case_id == 0) %>% 
      select_cv()
  )[[1]]
}


### L02 - Less 10 years old who had live births

## Selected household member (line number) must be female 10 years old and over.
if(pregnant_male_n > 0) {
  (
    cv_l02_age <- section_l01_05 %>% 
      filter(l01_preg == 1) %>% 
      mutate(line_number_id = if_else(is.na(l02_lno), '', paste0(case_id, sprintf('%02d', as.integer(l02_lno))))) %>% 
      na_if('') %>% 
      left_join(ref_age_sex, by = 'line_number_id') %>% 
      filter(age < 10) %>% 
      select_cv(l02_lno, age, h = 'age')
  )[[1]]
} else {
  ( cv_l02_age <- section_l01_05 %>% 
      filter(l01_preg == 1) %>% 
      select_cv()
  )[[1]]
}


### L03 - Missing/invalid 

## If answered 'Yes' in L01, L03 (number of pregnancies) must be between 1 to 10.
(
  cv_l03_birth_count <- section_l01_05 %>% 
    filter(l01_preg == 1, !(l03_lbirths %in% c(1:10))) %>% 
    select_cv(l01_preg, l02_lno, l03_lbirths, h = 'l03_lbirths')
)[[1]]


### L04 - Missing/invalid 

## If answered 'Yes' in L01, L04 (number of live births) must be between 0 to 10.
(
  cv_l04_live_births <- section_l01_05 %>% 
    filter(l01_preg == 1, !(l04_nlbirths %in% c(0:10))) %>% 
    select_cv(l01_preg, l02_lno, l04_nlbirths, h = 'l04_nlbirths')
)[[1]]


### L05 - Missing/invalid (month)

## If answered 'Yes' in L01, L05 (month of first pregnancy) must not be blank.
(
  cv_l05_month <- section_l01_05 %>% 
    filter(l01_preg == 1, !(l05_moftpreg %in% c(1:12, 98))) %>% 
    select_cv(l01_preg, l02_lno, l05_moftpreg, h = 'l05_moftpreg')
)[[1]]


### L05 - Missing/invalid (year)

## If answered 'Yes' in L01, L05 (year of first pregnancy) must not be blank.
(
  cv_l05_year <- section_l01_05 %>% 
    filter(l01_preg == 1, !(l05_yrftpreg %in% c(1900:2022, 9998))) %>% 
    select_cv(l01_preg, l02_lno, l05_yrftpreg, h = 'l05_yrftpreg')
)[[1]]


### L06 - With female members 10 years old and over but missing/invalid response

## L06 (currently pregnant) must be not be black/invalid if there is at least one female member 10 years old and over.
(
  cv_l06_with_female <- section_l01 %>%
    filter(with_female == 1, l01_preg == 1, !(l06_cpreg %in% c(1, 2))) %>% 
    select_cv(l06_cpreg_fct, h = 'l06_cpreg_fct')
)[[1]]


### L07 - Missing/invalid line number

## Answered 'Yes' in L06 but line number of household member is missing/invalid.
(
  cv_l07_lno <- section_l06_07 %>% 
    filter(l06_cpreg == 1, as.integer(l07_lno) < 1 | as.integer(l07_lno) > n) %>% 
    select_cv(l06_cpreg_fct, l07_lno, h = 'l07_lno', -age)
)[[1]]


### L07 - Pregnant male

## Selected household member (line number) is male. Only qualified household member must be selected in L02 (female 10 years old and over).
(
  cv_l07_male <- section_l06_07 %>% 
    filter(l06_cpreg == 1, a05_sex == 1) %>% 
    select_cv(l06_cpreg_fct, l07_lno, a05_sex, -age, h = 'a05_sex')
)[[1]]


### L07 - Pregnant below 10 years old

## Selected household member (line number) must be female 10 years old and over.
(
  cv_l07_age1 <- section_l06_07 %>% 
    filter(l06_cpreg == 1, age < 10) %>% 
    select_cv(l06_cpreg_fct, l07_lno, h = 'age')
)[[1]]


### L07 - Not applicable since L06 is 'No'

## Answered 'No' in L06 (currently pregnant) but with response in L07 (line number)
(
  cv_l07_age2 <- section_l06_07 %>% 
    filter(l06_cpreg == 2, !is.na(l07_lno)) %>% 
    select_cv(l06_cpreg_fct, l07_lno, h = 'l07_lno')
)[[1]]


### L08 - With female members 10 years old and over but missing/invalid response

## L08 (currently lactacting) must be not be blank/invalid if there is at least one female member 10 years old and over.
(
  cv_l08_with_female <- section_l01 %>%
    filter(with_female == 1, !(l08_lactmom %in% c(1, 2))) %>% 
    select_cv(l08_lactmom_fct, h = 'l08_lactmom_fct')
)[[1]]


### L09 - Missing/invalid line number

## Answered 'Yes' in L08 but line number of household member is missing/invalid.
(
  cv_l09_lno <- section_l08_09 %>% 
    filter(l08_lactmom == 1, as.integer(l09_lno) < 1 | as.integer(l09_lno) > n) %>% 
    select_cv(l08_lactmom_fct, l09_lno, h = 'l09_lno', -age)
)[[1]]


### L09 - Pregnant male

## Selected household member (line number) must be female 10 years old and over.
(
  cv_l09_male <- section_l08_09 %>% 
    filter(l08_lactmom == 1, a05_sex == 1) %>% 
    select_cv(l08_lactmom_fct, l09_lno, a05_sex, h = 'a05_sex')
)[[1]]


### L09 - Pregnant below 10 years old

## If household member is below 10 years old, L09 must be skipped.
(
  cv_l09_age1 <- section_l08_09 %>% 
    filter(l08_lactmom == 1, age < 10) %>% 
    select_cv(l08_lactmom_fct, l09_lno, h = 'age')
)[[1]]


### L09 - Not applicable since L08 is 'No'

## Answered 'No' in L08 (currently lactating) but with response in L09 (line number)
(
  cv_l09_age2 <- section_l08_09 %>% 
    filter(l08_lactmom == 2, !is.na(l09_lno)) %>% 
    select_cv(l08_lactmom_fct, l09_lno, h = 'l09_lno')
)[[1]]

### L10 - Missing/invalid

## L10 (with child/baby who died) must not be blank/invalid.
(
  cv_l10_missing <- section_l %>% 
    filter(!(l10_tyzfdied %in% c(1, 2))) %>% 
    select_cv(l10_tyzfdied_fct, h = 'l10_tyzfdied_fct')
)[[1]]


### L11 - Missing/invalid name of child/baby

## L11 (name of child/baby) must not be blank/invalid if answered 'Yes' in L10.
(
  cv_l11_lno <- section_l10_14 %>% 
    filter(l10_tyzfdied == 1, grepl(ref_invalid_name, l11_tyzfname) | is.na(l11_tyzfname)) %>% 
    select_cv(l10_tyzfdied_fct, l11_tyzfname, h = 'l10_tyzfdied_fct')
)[[1]]


### L12 - Missing/invalid sex of child/baby

## L12 (sex of child/baby) must not be blank/invalid if answered 'Yes' in L10.
(
  cv_l12_sex <- section_l10_14 %>% 
    filter(l10_tyzfdied == 1, !(l12_tyzfsex %in% c(1, 2))) %>% 
    select_cv(l10_tyzfdied_fct, l12_tyzfsex_fct, h = 'l12_tyzfsex_fct')
)[[1]]


### L13 - Missing/invalid age of child/baby

## L13 (age of child/baby) must not be blank or must be between 0 to 60 months old.
(
  cv_l13_age <- section_l10_14 %>% 
    filter(l10_tyzfdied == 1, l13_tyzfage < 0 | l13_tyzfage > 60) %>% 
    select_cv(l10_tyzfdied_fct, l13_tyzfage, h = 'l13_tyzfage')
)[[1]]


### L14 - Missing/invalid cause of death

## If responded 'Yes' to L10, L14 (cause of death) must not be blank or must be 1 to 10 or 99
(
  cv_l14_death <- section_l10_14 %>% 
    filter(l10_tyzfdied == 1, !(l14_tyzfcause %in% c(1:10, 99))) %>% 
    select_cv(l10_tyzfdied_fct, l14_tyzfcause_fct, h = 'l14_tyzfcause_fct')
)[[1]]


### L14 - Answer is 99 but not specified 


#### Cases with inconsistency

## If responded 99 (other) to L14 (cause of death), answer must be specified.
(
  cv_l14_death_other <- section_l10_14 %>% 
    filter(l10_tyzfdied == 1, l14_tyzfcause == 99, is.na(l14a_tyzfcause)) %>% 
    select_cv(l10_tyzfdied_fct, l14_tyzfcause_fct, l14a_tyzfcause, h = 'l14a_tyzfcause')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
( 
  cv_l14_other <- section_l10_14 %>% 
    filter(l10_tyzfdied == 1, l14_tyzfcause == 99, !is.na(l14a_tyzfcause)) %>% 
    select_cv(l14_tyzfcause_fct, l14a_tyzfcause)
)[[1]]


### L15 - Missing/invalid

## L15 (with disability) must not be blank/invalid
(
  cv_l15_missing <- section_l %>% 
    filter(!(l15_dis %in% c(1, 2))) %>% 
    select_cv(l15_dis, h = 'l15_dis')
)[[1]]


### L16 - Missing/invalid line number

## Responded 'Yes' in L15 (with disability) but line number of household member is missing/invalid.
(
  cv_l16_lno <- section_l15_18 %>% 
    filter(l15_dis == 1, as.integer(l16_lno) < 1 | as.integer(l16_lno) > n) %>% 
    select_cv(l15_dis, l16_lno, h = 'l16_lno')
)[[1]]


### L17 - Missing/invalid

## L17 (type of disability) must not be blank/invalid if answered 'Yes' in L15 (with disability).
(
  cv_l17_disabilities <- section_l15_18 %>% 
    filter(l15_dis == 1) %>% 
    filter_at(vars(matches('^l17[a-hz].*'), -matches('_fct$')), all_vars(. == 2 | is.na(.))) %>% 
    select_cv(l15_dis, l16_lno, matches('^l17[a-hz].*_fct$'))
)[[1]]


### L17 - Answer is 'Yes' but not specified 


#### Cases with inconsistency

## If responded 'Yes' to L17 (other type of disability), answer must be specified.
(
  cv_l17_death_other_missing <- section_l15_18 %>% 
    filter(l17z_typedis == 1, is.na(l17za_typedis)) %>% 
    select_cv(l17z_typedis_fct, l17za_typedis, h = 'l17za_typedis')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_l17_death_other <- section_l15_18 %>% 
    filter(l17z_typedis == 1, !is.na(l17za_typedis)) %>% 
    select_cv(l17z_typedis_fct, l17za_typedis)
)[[1]]



### L18 - Missing/invalid

## L18 (disability diagnosed by a doctor) must not be blank/invalid if answered 'Yes' in a specific type of disability.
(
  cv_l17_disabilities <- section_l15_18 %>%
    select(case_id, region, province, city_mun, brgy, ean, l15_dis, everything()) %>% 
    filter(l15_dis == 1) %>% 
    gather_by_disability() %>% 
    filter(Disability == 1, !(Diagnosed %in% c(1, 2))) %>% 
    select_cv(l15_dis, Type, Disability, Diagnosed)
)[[1]]


### L18 - Not applicable since L18 is 'No'

## L18 must be blank if answer for specific type of disability is 'No'.
(
  cv_l17_disabilities <- section_l15_18 %>%
    select(case_id, region, province, city_mun, brgy, ean, l15_dis, everything()) %>% 
    filter(l15_dis == 1) %>% 
    gather_by_disability() %>% 
    filter(Disability == 2, !is.na(Diagnosed)) %>% 
    select_cv(l15_dis, Type, Disability, Diagnosed)
)[[1]]


### L19 - Missing/invalid

## L19 (cancer patient) must not be blank/invalid
(
  cv_l19_missing <- section_l %>% 
    filter(!(l19_cancerpw %in% c(1, 2))) %>% 
    select_cv(l19_cancerpw, h = 'l19_cancerpw')
)[[1]]


### L20 - Missing/invalid line number

## Responded 'Yes' in L19 (with cancer patient) but line number of household member is missing/invalid.
(
  cv_l20_lno <- section_l19_20 %>% 
    filter(l19_cancerpw == 1, as.integer(l20_lno) < 1 | as.integer(l20_lno) > n) %>% 
    select_cv(l19_cancerpw_fct, l20_lno)
)[[1]]


### L20 - Not applicable since L19 is 'No'

## Answered 'No' in L19 (with cancer patient) but with response in L20 (line number)
(
  cv_l20_lno_na <- section_l19_20 %>% 
    filter(l19_cancerpw == 2, !is.na(l20_lno)) %>% 
    select_cv(l19_cancerpw_fct, l20_lno)
)[[1]]



### L21 - Missing/invalid

## L21 (cancer survivor) must not be blank/invalid
(
  cv_l21_missing <- section_l %>% 
    filter(!(l21_cancersur %in% c(1, 2))) %>% 
    select_cv(l21_cancersur, h = 'l21_cancersur')
)[[1]]


### L22 - Missing/invalid line number

## Responded 'Yes' in L21 (with cancer survivor) but line number of household member is missing/invalid.
(
  cv_l20_lno <- section_l21_22 %>% 
    filter(l21_cancersur == 1, as.integer(l22_lno) < 1 | as.integer(l22_lno) > n) %>% 
    select_cv(l21_cancersur_fct, l22_lno, h = 'l22_lno')
)[[1]]


### L22 - Not applicable since L21 is 'No'

## Answered 'No' in L21 (with cancer survivor) but with response in L22 (line number)
(
  cv_l20_lno_na <- section_l21_22 %>% 
    filter(l21_cancersur == 2, !is.na(l22_lno)) %>% 
    select_cv(l21_cancersur_fct, l22_lno, h = 'l22_lno')
)[[1]]


### L23 - Missing/invalid

## L23 (with rare disease) must not be blank/invalid.
(
  cv_l23_missing <- section_l %>% 
    filter(!(l23_raredis %in% c(1, 2))) %>% 
    select_cv(l23_raredis_fct, h = 'l23_raredis_fct')
)[[1]]


### L24 - Missing/invalid line number

## If answered 'Yes' to L23 (with rare disease), line number of household number must not be blank/invalid.
(
  cv_l24_lno <- section_l23_28 %>% 
    filter(l23_raredis == 1, as.integer(l24_lno) < 1 | as.integer(l24_lno) > n) %>% 
    select_cv(l23_raredis_fct, l24_lno, h = 'l24_lno')
)[[1]]


### L24 - Not applicable since L23 is 'No'

## If answered 'No' to L23 (with rare disease), all succeeding items (L24 to L28) should be blank.
(
  cv_l24_lno_na <- section_l23_28 %>% 
    filter(l23_raredis == 2) %>% 
    filter_at(vars(matches('l2[4-8].*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(l23_raredis_fct, l24_lno, matches('l2[4-8].*_fct$'))
)[[1]]


### L25 - Missing/invalid

## l25 (diagnosed with a doctor) must not be blank/invalid if answered 'Yes' to L23 (with rare disease).
(
  cv_l25_diagnosed <- section_l23_28 %>% 
    filter(l23_raredis == 1, !(l25_raredisdiag %in% c(1, 2))) %>% 
    select_cv(l23_raredis_fct, l25_raredisdiag_fct, h = 'l25_raredisdiag_fct')
)[[1]]


### L26 - Missing/invalid type of rare disease

## If answered 'Yes' to L25 (diagnosed with a doctor), L26 (type of rare disease) must not be blank or must be between 1 to 66 or 99.
(
  cv_l26_rare_disease <- section_l23_28 %>% 
    filter(l23_raredis == 1, l25_raredisdiag == 1, !(l26_raredisy %in% c(1:66, 99))) %>% 
    select_cv(l23_raredis_fct, l25_raredisdiag_fct, l26_raredisy_fct, h = 'l26_raredisy_fct')
)[[1]]


### L26 - Answer is 99 (other) but not specified 


#### Cases with inconsistency

## If responded 99 (other) to L26 (type of rare disease), answer must be specified.
(
  cv_l26_rare_disease <- section_l23_28 %>% 
    filter(l23_raredis == 1, l25_raredisdiag == 1, l26_raredisy == 99, is.na(l26a_raredisy)) %>% 
    select_cv(l23_raredis_fct, l25_raredisdiag_fct, l26_raredisy_fct, l26a_raredisy, h = 'l26a_raredisy')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_l26_rare_disease_o <- section_l23_28 %>% 
    filter(l23_raredis == 1, l25_raredisdiag == 1, l26_raredisy == 99, !is.na(l26a_raredisy)) %>% 
    select_cv(l26_raredisy_fct, l26a_raredisy)
)[[1]]


### L27 - Answered 'No' in L25 (diagnosed by a doctor) but missing

## If answered 'No' to L25 (diagnosed with a doctor), L27 (description of rare disease) must not be blank.
(
  cv_l27_rare_disease_specify <- section_l23_28 %>% 
    filter(l23_raredis == 1, l25_raredisdiag == 2, is.na(l27_raredisn)) %>% 
    select_cv(l23_raredis_fct, l25_raredisdiag_fct, l27_raredisn, h = 'l27_raredisn')
)[[1]]


### L28 - Missing/invalid (reason)

## If answered 'No' to L25 (diagnosed with a doctor), L28 (reason not diagnosed) must not be blank or must be 1 to 5 or 99.
(
  cv_l28_reason_not_diagnosed <- section_l23_28 %>% 
    filter(l23_raredis == 1, l25_raredisdiag == 2, !(l28_resraredis %in% c(1:5, 9))) %>% 
    select_cv(l23_raredis_fct, l25_raredisdiag_fct, l28_resraredis_fct, h = 'l28_resraredis_fct')
)[[1]]


### L28 - Answer is 9 (other) but not specified 


#### Cases with inconsistency

## If responded 9 (other) to L28 (reason not diagnosed by a doctor), answer must be specified.
(
  cv_l28_reason_not_diagnosed <- section_l23_28 %>% 
    filter(l23_raredis == 1, l25_raredisdiag == 2, l28_resraredis == 9, is.na(l28a_resraredis)) %>% 
    select_cv(l23_raredis_fct, l25_raredisdiag_fct, l28_resraredis_fct, l28a_resraredis, h = 'l28a_resraredis')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
( 
  cv_l28_other <- section_l23_28 %>% 
    filter(l23_raredis == 1, l25_raredisdiag == 2, l28_resraredis == 9, !is.na(l28a_resraredis)) %>% 
    select_cv(l28_resraredis, l28a_resraredis)
)[[1]]


### L27-28 - Not applicable since L25 is 'Yes'

## If answered 'Yes' to L25 (diagnosed with a doctor), L27 and L28 must be blank.
(
  cv_l27_28_na <- section_l23_28 %>% 
    filter(l23_raredis == 1, l25_raredisdiag == 1, !is.na(l27_raredisn) | !is.na(l28_resraredis)) %>% 
    select_cv(
      l23_raredis_fct, 
      l25_raredisdiag_fct, 
      l27_raredisn, 
      l28_resraredis_fct,
      h = c('l27_raredisn', 'l28_resraredis_fct')
    )
)[[1]]



### L29 - Missing/invalid (PWD ID)

## L29 (with PWD ID) must not be blank/invalid.
(
  cv_l29_missing <- section_l %>% 
    filter(l15_dis == 1, !(l29_pwdid %in% c(1, 2))) %>% 
    select_cv(l15_dis, l29_pwdid_fct, h = 'l29_pwdid_fct')
)[[1]]


### L29 vs L15 - With PWD ID but not PWD

## Check the consistency of household members with ownership of PWD ID but not a PWD
(
  cv_l29_v_l15 <- section_l %>% 
    filter(l15_dis == 2, l29_pwdid == 1) %>% 
    select_cv(l15_dis_fct, l29_pwdid_fct, h = c('l15_dis', 'l29_pwdid'))
)[[1]]


### L29 - Not applicable since L29 is 'No'

## If answered 'No' to L29 (with PWD ID), L30 to L32 must be blank.
(
  cv_l29_na <- section_l29_32 %>% 
    filter(l15_dis == 2) %>% 
    filter_at(vars(matches('^l3[0-2].*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(l15_dis, matches('^l3[0-2].*_fct$'))
)[[1]]


### L30 - Missing/invalid line number

## If answered 'Yes' to L30 (with PWD ID), line number of household number must not be blank/invalid.
(
  cv_l30_lno <- section_l29_32 %>% 
    filter(l15_dis == 1, l29_pwdid == 1, as.integer(l30_lno) < 1 | as.integer(l30_lno) > n) %>% 
    select_cv(l15_dis_fct, l29_pwdid_fct, l30_lno, h = 'l30_lno')
)[[1]]


### L31 - Missing/invalid (PWD ID shown)

## If answered 'Yes' to L29 (with PWD ID), L31 (shown PWD ID) must not be blank/invalid.
(
  cv_l31_shown_id <- section_l29_32 %>% 
    filter(l15_dis == 1, l29_pwdid == 1, !(l31_idshown %in% c(1, 2))) %>% 
    select_cv(l15_dis_fct, l29_pwdid_fct, l31_idshown_fct, h = 'l31_idshown_fct')
)[[1]]


### L32 - Missing/invalid (type of disability)

## If answered 'Yes' to L29 (with PWD ID) and L31 (shown PWD ID), L32 (type of disability) must not be blank or must be 1 to 10.
(
  cv_l32_disability <- section_l29_32 %>% 
    filter(l15_dis == 1, l29_pwdid == 1, l31_idshown == 1, !(l32_distype %in% c(1:10))) %>% 
    select_cv(l15_dis_fct, l29_pwdid_fct, l31_idshown_fct, l32_distype_fct, h = 'l32_distype_fct')
)[[1]]


### L32 - Not applicable since L31 is 'No'

## If answered 'No' to L31 (shown PWD ID), L32 (type of disability) must be blank.
(
  cv_l32_disability_na <- section_l29_32 %>% 
    filter(l15_dis == 1, l29_pwdid == 1, l31_idshown == 2, !is.na(l32_distype)) %>% 
    select_cv(l15_dis_fct, l29_pwdid_fct, l31_idshown_fct, l32_distype_fct, h = 'l32_distype_fct')
)[[1]]


### L33 - Missing/invalid (ill/sick/injured)

## L33 (got ill/sick/injured) must not be blank/invalid.
(
  cv_l33_missing <- section_l %>% 
    filter(!(l33_tmsick %in% c(1, 2))) %>% 
    select_cv(l33_tmsick_fct, h = 'l33_tmsick_fct')
)[[1]]


### L34 - Missing/invalid line number

## If answered 'Yes' to L33 (got ill/sick/injured), line number of household number must not be blank/invalid.
(
  cv_l34_lno <- section_l33_41 %>% 
    filter(l33_tmsick == 1, as.integer(l34_lno) < 0 | as.integer(l34_lno) > n) %>% 
    select_cv(l33_tmsick_fct, l34_lno, -age, h = 'l34_lno')
)[[1]]


### L34-41 - Not applicable since L33 is 'No'

## If answered 'No' to L32 (got ill/sick/injured), L34 to L4 must be blank.
(
  cv_l34_lno_na <- section_l33_41 %>% 
    filter(l33_tmsick == 2) %>% 
    filter_at(vars(matches('^l(3[4-9]|4[0-1]).*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(l33_tmsick_fct, l34_lno, -age, matches('^l(3[4-9]|4[0-1]).*'))
)[[1]]


### L35 - Missing/invalid (daily activities affected)

## If responded 'Yes' to L32 (got ill/sick/injured) and age of member is 5 years old and over, L35 (daily activities affected) must not be blank or invalid.
(
  cv_l35_disrupted <- section_l33_41 %>% 
    filter(l33_tmsick == 1, age >= 5, !(l35_pmreasonnp %in% c(1, 2))) %>% 
    select_cv(l33_tmsick_fct, l34_lno, l35_pmreasonnp_fct, h = 'l35_pmreasonnp_fct')
)[[1]]


### L36 - Missing/invalid (number of days affected)

## If responded 'Yes' to L32 (got ill/sick/injured) and age of member is 5 years old and over, L36 (number of days affected) must not be blank or must be between 1 to 31 days.
(
  cv_l36_days_disrupted <- section_l33_41 %>% 
    filter(l33_tmsick == 1, age >= 5, l35_pmreasonnp == 1, !(l36_pmdaysnp %in% c(1:31))) %>% 
    select_cv(l33_tmsick_fct, l34_lno, l35_pmreasonnp, l36_pmdaysnp, h = 'l36_pmdaysnp')
)[[1]]


### L35-36 - Not applicable for age < 5

## If household member is below 5 years old, L35 (daily activities affected) and L36 (number of days affected) must be blank.
(
  cv_l35_36_na <- section_l33_41 %>% 
    filter(l33_tmsick == 1, age < 5, !is.na(l35_pmreasonnp) | !is.na(l36_pmdaysnp)) %>% 
    select_cv(l33_tmsick_fct, l34_lno, l35_pmreasonnp_fct, l36_pmdaysnp, h = c('l35_pmreasonnp_fct', 'l36_pmdaysnp'))
)[[1]]


### L37 - Missing/invalid (recent illness/sickness/injury)

## If responded 'Yes' to L32 (got ill/sick/injured), L37 (recent illness/sickness/injury) must not be blank or must be between 1 to 13 or 99.
(
  cv_l37_illness <- section_l33_41 %>% 
    filter(l33_tmsick == 1, !(l37_recsick %in% c(1:13, 99))) %>% 
    select_cv(l33_tmsick_fct, l34_lno, l37_recsick_fct, h = 'l37_recsick_fct')
)[[1]]


### L37 - Answer is 99 (other) but not specified 

#### Cases with inconsistency

## If responded 99 (other) to L37 (recent illness/sickness/injury), answer must be specified.
(
  cv_l37_illness_other <- section_l33_41 %>% 
    filter(l33_tmsick == 1, l37_recsick == 99, is.na(l37a_recsick)) %>% 
    select_cv(l33_tmsick_fct, l34_lno, l37_recsick_fct, l37a_recsick, h = 'l37a_recsick')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
( 
  cv_l37_other <- section_l33_41 %>% 
    filter(l33_tmsick == 1, l37_recsick == 99, !is.na(l37a_recsick)) %>% 
    select_cv(l37_recsick, l37a_recsick)
)[[1]]


### L38 - Missing/invalid (availed medical treatment)

## If responded 'Yes' to L32 (got ill/sick/injured), L38 (availed medical treatment) must not be blank or invalid.
(
  cv_l38_treatment <- section_l33_41 %>% 
    filter(l33_tmsick == 1, !(l38_hhmavailed %in% c(1, 2))) %>% 
    select_cv(l33_tmsick_fct, l34_lno, l38_hhmavailed_fct, h = 'l38_hhmavailed_fct')
)[[1]]


### L39 - Missing/invalid (medical treatment facility)

## If responded 'Yes' to L32 (got ill/sick/injured) and L38 (availed medical treatment), L39 (medical treatment facility) must not be blank/invalid.
(
  cv_l39_treatment_fac <- section_l33_41 %>% 
    filter(l33_tmsick == 1, l38_hhmavailed == 1, !grepl('[A-TZ]+', l39_availmt)) %>% 
    select_cv(l33_tmsick_fct, l34_lno, l38_hhmavailed_fct, l39_availmt, h = 'l39_availmt')
)[[1]]


### L40 - Missing/invalid (source of payment medical treatment)

## If responded 'Yes' to L32 (got ill/sick/injured) and L38 (availed medical treatment), L39 (source of payment medical treatment) must not be blank/invalid.
(
  cv_l40_treatment_fac <- section_l33_41 %>% 
    filter(l33_tmsick == 1, l38_hhmavailed == 1, grepl('[A-HZ]+', l40_paysource)) %>% 
    select_cv(l33_tmsick_fct, l34_lno, l38_hhmavailed_fct, l40_paysource, h = 'l40_paysource')
)[[1]]


### L39-40 - Not applicable since L38 is 'No'

## If answered 'No' to L38 (availed medical treatment), L39 to L40 must be blank.
(
  cv_l39_40_na <- section_l33_41 %>% 
    filter(l33_tmsick == 1, l38_hhmavailed == 2) %>% 
    filter_at(vars(matches('^l(39|40).*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(l33_tmsick_fct, l38_hhmavailed_fct, matches('^l(39|4[0-1]).*_fct$'))
)[[1]]


### L41 - Missing/invalid (reason for not availing medical treatment)

## If answered 'No' to L38 (availed medical treatment), L41 (reason for not availing medical treatment) must not be blank or must be 1 to 6 or 9.
(
  cv_l41_reason <- section_l33_41 %>% 
    filter(l33_tmsick == 1, l38_hhmavailed == 2, !(l41_mreasondn %in% c(1:6, 9))) %>% 
    select_cv(l33_tmsick_fct, l38_hhmavailed_fct, l41_mreasondn_fct, h = 'l41_mreasondn_fct')
)[[1]]


### L41 - Answer is 9 (other) but not specified 


#### Cases with inconsistency

## If responded 9 (other) to L41 (reason for not availing medical treatment), answer must be specified.
(
  cv_l41_other_reason <- section_l33_41 %>% 
    filter(l33_tmsick == 1, l38_hhmavailed == 2, l41_mreasondn == 9, is.na(l41a_mreasondn)) %>% 
    select_cv(l33_tmsick_fct, l38_hhmavailed_fct, l41_mreasondn_fct, l41a_mreasondn, h = 'l41a_mreasondn')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
( 
  cv_l41_other <- section_l33_41 %>% 
    filter(l33_tmsick == 1, l38_hhmavailed == 2, l41_mreasondn == 9, !is.na(l41a_mreasondn)) %>% 
    select_cv(l41_mreasondn, l41a_mreasondn)
)[[1]]

# No. of PWDs (all types including those with cancer, cancer survivor and rare diseases) is less than those PWDs with IDs.



