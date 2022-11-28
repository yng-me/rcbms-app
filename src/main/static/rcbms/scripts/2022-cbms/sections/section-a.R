# Section A {.unnumbered}

section_a <- hpq$section_a %>% 
  collect() %>% 
  mutate_at(vars(matches('^a01_.*')), ~ str_trim(toupper(.)))

section_a_pcn <- hpq$section_a %>% 
  collect() %>% 
  mutate(a13_pcn2 = str_trim(a13_pcn2)) %>% 
  na_if('') %>% 
  filter(!is.na(a13_pcn2), grepl('^\\{', a13_pcn2)) 

if(nrow(section_a_pcn) > 1) {
  section_a_pcn <- section_a_pcn %>% 
  mutate(a13_pcn2 = str_conv(a13_pcn2, "UTF-8"))  %>% 
  mutate(pcn = map(a13_pcn2, fromJSON)) %>% 
  unnest_wider(pcn)  %>% 
  unnest_longer(subject) %>% 
  distinct(line_number_id, subject_id, subject, .keep_all = T) %>% 
  pivot_wider(names_from = subject_id, values_from = subject) %>% 
  rename(
    pcn = PCN,
    pcn_last_name = lName,
    pcn_middle_name = mName,
    pcn_first_name = fName,
    pcn_suffix = Suffix,
    pcn_sex = sex,
    pcn_dob = DOB
  ) %>% 
  mutate(
    pcn_dob = mdy(pcn_dob),
    pcn_last_name = toupper(pcn_last_name),
    pcn_middle_name = toupper(pcn_middle_name),
    pcn_first_name = toupper(pcn_first_name),
    pcn_suffix = toupper(pcn_suffix)
  ) %>% 
  mutate(pcn_sex = if_else(
    pcn_sex == 'Male', paste0('1 - ', pcn_sex), paste0('2 - ', pcn_sex))
  ) %>% 
  mutate_at(vars(matches('^a01_.*')), ~ str_trim(toupper(.))) %>% 
  mutate_at(vars(matches('^pcn_.*name$')), ~ str_trim(toupper(.))) %>% 
  select(1:23, a06_birthday, matches(c('^pcn', 'sex|age.*_fct$'))) %>% 
  na_if('')
}

ref_hh_count <- section_a %>% count(case_id)

### A01 - First name of household member is missing or invalid

## First name should not be blank or should only contain valid characters/letters.

(
  cv_a01_first_name <- section_a %>% 
    filter(
      a01_firstname == '' |
      !grepl('[a-z\u00d1 -.]', a01_firstname, ignore.case = T) |
      grepl(ref_invalid_keyword, a01_firstname, ignore.case = T)) %>% 
    select_cv(a01_firstname, h = 'a01_firstname')
)[[1]]

### A01 - Last name of household member is missing or invalid

## Last name should not be blank or should only contain valid characters/letters; if no last name, entry must be '-'.

(
  cv_a01_last_name <- section_a %>% 
    filter(
      a01_lstname == '' | 
      !grepl('[a-z\u00d1 -.]', a01_lstname, ignore.case = T) | grepl(ref_invalid_name, a01_lstname, ignore.case = T) 
    ) %>% 
    select_cv(a01_lstname, h = 'a01_lstname')
)[[1]]


### A01 - Middle name of household member is missing or invalid

## Middle name should not be blank or should only contain valid characters/letters; if no middle name, entry must be '-'.

(
  cv_a01_middle_name <- section_a %>% 
    filter(
      a01_midname != '', 
      !grepl('[a-z\u00d1 -.]', a01_midname, ignore.case = T) | grepl(ref_invalid_name, a01_midname, ignore.case = T)
    ) %>% 
    select_cv(a01_midname, h = 'a01_midname')
)[[1]]

### A02 - Relationship to the household head missing or not in the valueset

#### Cases with inconsistency

## Answer for A02 (relationship to the household head) must not be blank or should be between 1 to 26.

(
  cv_a02_rel_to_hh <- section_a %>% 
  filter(!(a02_reltohhh %in% c(1:26))) %>% 
  select_cv(a02_reltohhh, h = 'a02_reltohhh')
)[[1]]

#### Marginal table

## Distribution of household members by relationship to the household head, by barangay

section_a %>% 
  tabyl(brgy, a02_reltohhh_fct) %>% 
  adorn_totals(c('row', 'col')) %>% 
  reactable_cv()

#### Consistency table

## Relationship to the household head (A02) vs sex (A05)

section_a %>% 
  tabyl(a02_reltohhh_fct, a05_sex_fct) %>% 
  adorn_totals(c('row', 'col')) %>% 
  reactable_cv()

### A02 - Household head below 15 years old

#### Cases with inconsistency

## Age of household head should be 15 years old and over, unless justified.
(
  cv_a02_rel_to_hh_below_15 <- section_a %>% 
    filter(a02_reltohhh == 1, age < 15) %>% 
    select_cv(a02_reltohhh, h = 'a02_reltohhh')
)[[1]]

#### Consistency table

## Age (A07) vs relationship to the household head

section_a %>% 
  tabyl(a05_sex_fct, a02_reltohhh_fct) %>% 
  adorn_totals(c('row', 'col')) %>% 
  reactable_cv()

### A02 - Household Head but the Line Number is not 01

## The line number of household head should be '01', unless justified.
(
  cv_a02_rel_to_hh_line_number <- section_a %>% 
    filter(a02_reltohhh == 1, lno != 1) %>% 
    select_cv(a02_reltohhh, h = c('lno', 'a02_reltohhh'))
)[[1]]


### A02 - Head of household with two or more members but the nuclear family number (A03) or relationship to nuclear family (A04) is not 1

## The head of a household with two or more members must also be the head of the first nuclear family (A03 == 1 and A04 == 01).
(
  cv_a02_rel_to_hh_nuclear <- section_a %>% 
    filter(a02_reltohhh == 1, a03_nuclear != 1 | a04_reltonucfh > 1) %>% 
    select_cv(a02_reltohhh, a03_nuclear, a04_reltonucfh, h = c('a02_reltohhh', 'a03_nuclear', 'a04_reltonucfh'))
)[[1]]


### A03 - Missing or invalid nuclear family number

## A03 (nuclear family number) must not be blank and answer should be between 1 and must not exceed the total number of household members.
(
  cv_03_nuc_missing <- section_a %>% 
    left_join(ref_hh_count, by = 'case_id') %>% 
    filter(is.na(a03_nuclear) | as.integer(a03_nuclear) > n) %>%
    rename('Number of Household Members' = n) %>% 
    select_cv(`Number of Household Members`, a03_nuclear, h = 'a03_nuclear')
)[[1]]


### A03 - The number of nuclear families is greater than the total number of household members

## The number of nuclear family should not exceed the total number of household members.
(
  cv_a03_nuc <- section_a %>% 
    group_by(case_id, region, province, city_mun, brgy) %>% 
    summarise(
      n = n(),
      f = max(a03_nuclear), 
      .groups = 'drop'
    ) %>% 
    filter(f > n) %>% 
    rename(
      'Number of Household Members' = n,
      'Number of Nuclear Family' = f
    ) %>% 
    select_cv(`Number of Household Members`, `Number of Nuclear Family`, 
              h = c('Number of Household Members', 'Number of Nuclear Family')
            )
)[[1]]


### A04 - Missing or invalid

#### Cases with inconsistency

## Relationship to the head of nuclear family must not be blank or should be between 0 to 10.
(
  cv_a04_rel_nuc <- section_a %>% 
    filter(!(a04_reltonucfh %in% c(0:10))) %>% 
    select_cv(a04_reltonucfh, h = 'a04_reltonucfh')
)[[1]]

#### Marginal table

## Distribution of household member by relationship to the family head, by barangay

section_a %>% 
  tabyl(brgy, a04_reltonucfh_fct) %>% 
  adorn_totals(c('row', 'col')) %>% 
  reactable_cv()

#### Consistency table

## Relationship to the family head (A02) vs sex (A05)
section_a %>% 
  tabyl(a04_reltonucfh_fct, a05_sex_fct) %>% 
  adorn_totals(c('row', 'col')) %>% 
  reactable_cv()

### A04 - One-member household but relationship to the head of nuclear family (A04) is not 0

## The relationship to the head of nuclear family (A04) for one-member household should be 0.
(
  cv_a03_nuc_one_hh <- section_a %>% 
    group_by(case_id, region, province, city_mun, brgy) %>% 
    summarise(
      n = n(),
      f = max(a04_reltonucfh), 
      .groups = 'drop'
    ) %>% 
    filter(n == 1, f > 0) %>% 
    rename('Relationship to Head of Nuclear Family' = f) %>% 
    select_cv(`Relationship to Head of Nuclear Family`, h = 'Relationship to Head of Nuclear Family')
)[[1]]


### A04 - Female member but relationship to the head of nuclear family (A04) is 4, 6, or 8

## If answer for A04 (relationship to the head of nuclear family) is 4, 6, or 8, sex of household member should be 1 (male).
(
  cv_a04_female_only <- section_a %>% 
    filter(a05_sex == 2, a04_reltonucfh %in% c(4, 6, 8)) %>% 
    select_cv(a05_sex, a04_reltonucfh, h = c('a05_sex', 'a04_reltonucfh'))
)[[1]]


### A04 - Male member but relationship to the head of nuclear family (A04) is 5, 7, or 9

## If answer for A04 (relationship to the head of nuclear family) is 5, 7, or 9, sex of household member should be 2 (female).
(
  cv_a04_male_only <- section_a %>% 
    filter(a05_sex == 1, a04_reltonucfh %in% c(5, 7, 9)) %>% 
    select_cv(a05_sex, a04_reltonucfh, h = c('a05_sex', 'a04_reltonucfh'))
)[[1]]


### A05 - Missing/invalid answer for sex (A05)

## Sex of household member must not be blank or should be 1 (male) or 2 (female).
(
  cv_a05_sex <- section_a %>% 
    filter(!(a05_sex %in% c(1, 2))) %>%
    select_cv(a05_sex, h = 'a05_sex')
)[[1]]


### A05 - Female member but relationship to the head is 3, 5, 7, 9, 11, 13, 15, 17, 19, or 21

## If A02 (relationship to the head) is 3, 5, 7, 9, 11, 13, 15, 17, 19, or 21, sex of household member should be 1 (male).
(
  cv_a05_female <- section_a %>% 
    filter(a02_reltohhh %in% seq(3, 21, 2), a05_sex == 2) %>% 
    select_cv(a02_reltohhh, h = 'a02_reltohhh')
)[[1]]


### A05 - Male member but relationship to the head is 4, 6, 8, 10, 12, 14, 16, 18, 20, or 22

## If A02 (relationship to the head) is 4, 6, 8, 10, 12, 14, 16, 18, 20, or 22, sex of household member should be 2 (female).
(
  cv_a05_male <- section_a %>% 
    filter(a02_reltohhh %in% seq(4, 22, 2), a05_sex == 1) %>% 
    select_cv(a02_reltohhh, a05_sex, h = c('a02_reltohhh', 'a05_sex'))
)[[1]]


### A06 - Missing/invalid age or birthday

## Date of birth and age must be blank. Date of birth should be between 01 July 1887 and 30 June 2022 or age should be between 0 to 135.
(
  cv_a06_age <- section_a %>% 
    mutate(a06_birthday = mdy(a06_birthday)) %>% 
    filter(
      a06_birthday > as.Date('2022-06-30') |
      a06_birthday < as.Date('1887-07-01')
    ) %>% 
    select_cv(a06_birthday, h = c('age', 'a06_birthday'))
)[[1]]


### A08 - Missing/invalid birth registration status with LCR

## Answer for A08 (birth registration status in LCR) must not be blank and should be 1, 2, or 8 only.
(
  cv_a08_lcr <- section_a %>% 
    filter(!(a08_birthreg %in% c(1, 2, 8))) %>% 
    select_cv(a08_birthreg, h = 'a08_birthreg')
)[[1]]


### A09 - Missing/invalid marital status


#### Cases with inconsistency

## Marital status must not be blank/invalid
(
  cv_a09_marital_status <- section_a %>% 
    filter(!(a09_mstat %in% c(1:8))) %>% 
    select_cv(a09_mstat)
)[[1]]


#### Marginal table

## Distribution of household members by marital status (A09), by barangay

section_a %>% 
  tabyl(brgy, a09_mstat_fct) %>% 
  adorn_totals(c('row', 'col')) %>%
  reactable_cv()


#### Consistency table

## Marital status (A09) vs age (A05)

section_a %>% 
  tabyl(a09_mstat_fct, a05_sex_fct) %>% 
  adorn_totals(c('row', 'col')) %>% 
  reactable_cv()

### A09 - Below 10 years old but not single


#### Cases with inconsistency

## If age is below 10 years old, A09 (marital status) should be 01 (single), unless justified.
(
  cv_a09_not_single <- section_a %>% 
    filter(a09_mstat %in% c(2:7), age < 10) %>% 
    select_cv(a09_mstat, h = c('age', 'a09_mstat'))
)[[1]]


#### Consistency table

## Age (A05) vs marital status (A09)

section_a %>% 
  tabyl(age, a09_mstat_fct) %>% 
  reactable_cv()

### A09 - Consistency between A02 vs A09

## If the A02 (relationship to the household head) is 2 (spouse), marital status should 2 (married) or 3 (common law/live-in).
(
  cv_a09_spouse <- section_a %>% 
    filter(a02_reltohhh == 2 | a04_reltonucfh == 2, a09_mstat %in% c(1, 4:7)) %>% 
    select_cv(a02_reltohhh, a04_reltonucfh, a09_mstat, h = c('a02_reltohhh', 'a09_mstat'))
)[[1]]


### A09 - Spouse below 10 years old

## If A02 (relationship to the household head) is 2 (spouse), acceptable age should be 10 years old and over, unless justified.
(
  cv_a09_spouse_below_10 <- section_a %>% 
    filter((a02_reltohhh == 2 & a04_reltonucfh == 2), age < 10) %>% 
    select_cv(a02_reltohhh, a04_reltonucfh, a09_mstat, h = c('age', 'a02_reltohhh'))
)[[1]]


### A10 - Missing/invalid answer for ethnicity

#### Cases with inconsistency

## Answer for A10 (ethnicity) must not be blank and should be in the valueset.
(
  cv_a10_ethnicity <- section_a %>% 
    filter(!(a10_ethnic %in% c(1:291, 998, 999))) %>% 
    select_cv(a10_ethnic, h = 'a10_ethnic')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_a10_others <- section_a %>% 
    filter(a10_ethnic == 999) %>% 
    select_cv(a10_ethnic, a10a_ethnic, h = 'a10a_ethnic')
)[[1]]


### A11 - Missing/invalid answer for religious affiliation

#### Cases with inconsistency

## Answer for A11 (religious affiliation) must not be blank and should be in the valueset.
(
  cv_a11_religion <- section_a %>% 
    filter(!(a11_religion %in% c(0:127, 998))) %>% 
    select_cv(a11_religion, h = 'a11_religion')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_a11_other <- section_a %>% 
    filter(a11_religion == 127) %>% 
    select_cv(a11_religion, a11_religion_oth)
)[[1]]


### A12 - Missing/invalid answer for ownership of PhilSys ID

## Answer for A12 (issuance of PhilSys ID) must not be blank and should be 1, 2, or 8 only.
(
  cv_a12_national_id <- section_a %>% 
    filter(!(a12_philid %in% c(1, 2, 8))) %>% 
    select_cv(a12_philid, h = 'a12_philid')
)[[1]]


### A13 - Missing entry for PCN (scanned QR code)

## If PCN was collected by scanning the QR code of the PhilSys ID, A13 (a13_pcn2) must not be blank or should contain demographic information obtained from PhilSys ID (JSON format).
(
  cv_a13_pcn_01 <- section_a %>% 
    filter(a12_philid == 1, a13_pcn == 1, is.na(a13_pcn2)) %>% 
    select_cv(a12_philid, a13_pcn, a13_pcn2, h = 'a13_pcn2')
)[[1]]


### A13 - Invalid length of PCN

## PCN should contain 16 digits if manually typed.
(
  cv_a13_pcn_02 <- section_a %>% 
    filter(a12_philid == 1, a13_pcn1 == 1, nchar(a13_pcn) != 16 | is.na(a13_pcn)) %>% 
    select_cv(a12_philid, a13_pcn, h = 'a13_pcn')
)[[1]]


### A13 - PCN validation (last name matching)

## First name (a01_lstname) should match with the information obtained from PhilSys ID.
if(nrow(section_a_pcn ) > 1) {
    cv_a13_pcn_last_name <- section_a_pcn %>%
      filter(a01_lstname != '') %>% 
      filter(pcn_last_name != a01_lstname) %>% 
      select_cv(pcn_last_name, a01_lstname)
} else {
  cv_a13_pcn_last_name <- section_a_pcn %>%
      select_cv(a13_pcn2)
}

cv_a13_pcn_last_name[[1]]


### A13 - PCN validation (first name matching)

## Last name (a01_lstname) should match with the information obtained from PhilSys ID.
if(nrow(section_a_pcn ) > 1) {
  cv_a13_pcn_first_name <- section_a_pcn %>%
    filter(a01_firstname != '') %>% 
    filter(pcn_first_name != a01_firstname) %>% 
    select_cv(pcn_first_name, a01_firstname)
} else {
  cv_a13_pcn_first_name <- section_a_pcn %>%
      select_cv(a13_pcn2)
}
cv_a13_pcn_first_name[[1]]


### A13 - PCN validation (middle name matching)

## Middle name (a01_midname) should match with the information obtained from PhilSys ID.
if(nrow(section_a_pcn ) > 1) {
  cv_a13_pcn_middle_name <- section_a_pcn %>%
    filter(a01_midname != '') %>% 
    filter(pcn_middle_name != a01_midname) %>% 
    select_cv(pcn_middle_name, a01_midname)
} else {
  cv_a13_pcn_middle_name <- section_a_pcn %>%
    select_cv(a13_pcn2)
}
cv_a13_pcn_middle_name[[1]]


### A13 - PCN validation (name suffix matching)

## Name suffix (a01_suff) should match with the information obtained from PhilSys ID.
if(nrow(section_a_pcn ) > 1) {
  cv_a13_pcn_suffix_name <- section_a_pcn %>%
    filter(a01_suff != '') %>% 
    mutate(
      a01_suff = str_trim(str_remove(a01_suff, '\\.')),
      pcn_suffix = str_trim(str_remove(pcn_suffix, '\\.'))
    ) %>% 
    filter(pcn_suffix != a01_suff) %>% 
    select_cv(pcn_suffix, a01_suff)
} else {
  cv_a13_pcn_suffix_name <- section_a_pcn %>%
    select_cv(a13_pcn2)
}

cv_a13_pcn_suffix_name[[1]]


### A13 - PCN validation (birthday matching)

## Date of birth (a06_birthday) should match with the date of birth obtained from PhilSys ID.
if(nrow(section_a_pcn ) > 1) {
  cv_a13_pcn_validation_dob <- section_a_pcn %>% 
    mutate(bday = mdy(a06_birthday)) %>% 
    filter(pcn_dob != bday) %>% 
    select_cv(pcn_dob, bday)
} else {
  cv_a13_pcn_validation_dob <- section_a_pcn %>%
    select_cv(a13_pcn2) 
}
cv_a13_pcn_validation_dob[[1]]


### A14 - Missing/invalid answer for step 2 registration for national ID

## If answer for A12 (issuance of PhilSys ID) is either 2 or 8, A14 (PhilSys step 2 registration) must not be blank and answer should be 1, 2, or 8 only.
(
  cv_a14_step_2_national_id <- section_a %>% 
    filter(a12_philid %in% c(2, 8), !(a14_step2 %in% c(1, 2, 8))) %>% 
    select_cv(a12_philid, a14_step2, h = c('a12_philid', 'a14_step2'))
)[[1]]


### A14 - Answer for A12 is 'YES' but with answer in A14 (step 2 registration)

## If answer for A12 (issuance of PhilSys ID) is 1, A14 (PhilSys step 2 registration) should be blank.
(
  cv_a14_step_2_national_id_na <- section_a %>% 
    filter(a12_philid == 1, !is.na(a14_step2)) %>% 
    select_cv(a12_philid, a14_step2, h = c('a12_philid', 'a14_step2'))
)[[1]]


### A15 - Missing/invalid answer for onwership of LGU ID

## A15 (issuance of city/municipal ID) must not be blank and answer should be 1, 2, or 8 only.
(
  cv_a15_lgu_id <- section_a %>% 
    filter(!(a15_lguid %in% c(1, 2, 8))) %>% 
    select_cv(a15_lguid, h = 'a15_lguid')
)[[1]]


### A16 - Missing/invalid answer for LGU ID

## if answer for A15 (issuance of city/municipal ID) is 1, A16 (LGU ID number) should have an entry.
(
  cv_a16_lgu_id_number <- section_a %>% 
    filter(a15_lguid == 1, !is.na(a16_lguidno)) %>% 
    select_cv(a15_lguid, a16_lguidno, h = c('a15_lguid', 'a16_lguidno'))
)[[1]]


### A17 - Missing/invalid answer for A17 (solo parent)

## If the household member is 10 years old and over, A17 (solo parent) must not be blank and answer should be 1 or 2 only.
(
  cv_a17_solo_parent <- section_a %>% 
    filter(age >= 10, !(a17_solopar %in% c(1, 2))) %>% 
    select_cv(a17_solopar, h = c('age', 'a17_solopar'))
)[[1]]


### A17 - Solo parent but age is less than 10

## If the household member is below 10 years old, answer for A17 (solo parent) must be blank.
(
  cv_a17_solo_less_10 <- section_a %>% 
    filter(age < 10, a17_solopar == 1) %>% 
    select_cv(a17_solopar, h = c('age', 'a17_solopar'))
)[[1]]


### A18 - Missing/invalid answer for A18 (ownership of solo parent ID)

## If the household member is a solo parent, A18 (solo parent ID) must not be blank and answer should be 1, 2, or 8 only.
(
  cv_a18_solo_parent_id <- section_a %>% 
    filter(a17_solopar == 1, !(a18_soloid %in% c(1, 2, 8))) %>% 
    select_cv(a17_solopar, a18_soloid, h = 'a18_soloid')
)[[1]]


### A18 - Answer for A17 is 'No' but with answer in A18 (solo parent ID)

## If the household member is a not a solo parent, answer for A18 (solo parent ID) must be blank.
(
  cv_a18_solo_parent_id_na <- section_a %>% 
    filter(a17_solopar == 2, !is.na(a18_soloid)) %>% 
    select_cv(a17_solopar, a18_soloid, h = 'a18_soloid')
)[[1]]


### A19 - Senior citizen's ownership of ID is missing/invalid

## If the household member is 60 years old and over, A19 (Senior Citizen ID) must not be blank and answer should be 1, 2 or 8 only.
(
  cv_a19_senior_citizen <- section_a %>% 
    filter(age >= 60, !(a19_sctznidq %in% c(1, 2, 8))) %>% 
    select_cv(a19_sctznidq, h = 'a19_sctznidq')
)[[1]]


### A19 - Senior citizen is not applicable

## If the household member is not a senior citizen, or below 60 years old, A19 (Senior Citizen ID) must be blank.
(
  cv_a19_senior_citizen_id <- section_a %>% 
    filter(age < 60, !is.na(a19_sctznidq)) %>% 
    select_cv(a19_sctznidq, h = 'a19_sctznidq')
)[[1]]


### A20 - Missing/invalid answer for functional difficulties

## If the household member is 5 years old and over, functional difficulties (A20 A to F) must not be blank and answers should be 1, 2, 3, or 4 only.
(
  cv_a20_wgss_missing <- section_a %>% 
    filter(age >= 5) %>% 
    filter_at(vars(matches('^a20_.*'), -matches('_fct$')), any_vars(!(. %in% c(1:4)))) %>% 
    select_cv(matches('^a20_.*'))
)[[1]]


### A20 - Functional difficulties not applicable

## If the household member is below 5 years, functional difficulties (A20 A to F) must be blank.
(
  cv_a20_wgss_na <- section_a %>% 
    filter(age < 5) %>% 
    filter_at(vars(matches('^a20_.*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(matches('^a20_.*'))
)[[1]]

