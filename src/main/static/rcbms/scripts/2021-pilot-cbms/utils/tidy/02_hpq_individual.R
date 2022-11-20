  mutate_line_number <- function(data) {
    
    ln <- data %>% group_by(case_id) %>%  count()
    max <- as.integer(max(ln$n))
    
    for(i in 1:max) {
      data <- data %>% 
        mutate(line_number = if_else(
          case_id == lag(case_id) & is.na(line_number), 
          as.integer(lag(line_number)) + 1L, line_number)
        )
    }
    return(data)
  }

hpq_individual <- hpq_data$SECTION_A_E %>% 
  filter(HSN < 7777) %>% 
  select(-contains('SPECIFY')) %>% 
  select(
    case_id,
    pilot_area,
    class,
    brgy_name,
    line_number = LINENO,
    a01_name = A01HHMEM,
    sex = A05SEX,
    age = age_computed,
    a02_rel_hh_head = A02RELHEAD,
    a03_nuclear_fam = A03NUCFAMILY,
    a04_rel_nuclear_fam = A04RELHNUCFAM,
    a06_dob = A06DATEBORN,
    a08_reg_lcr = A08REGLCR,
    a09_marital = A09MARITALSTATUS,
    a10_ethnicity = A10ETHNICCODE,
    a11_religion = A11CODE,
    a12_with_philsys_id = A121ISSUEDNID,
    a12_philsys_step_2 = A122REGNID,
    a14_solo_parent = A14SOLOPARENT,
    a15_solo_parent_id = A15SOLOPARENTID,
    a16_senior_citizen_id = A16SENIORID,
    a17_see = A17ASEEING,
    a17_hear = A17BHEARING,
    a17_walk = A17CWALKING,
    a17_remember = A17DREMEMBERING,
    a17_selfcare = A17ESELFCARING,
    a17_communicate = A17FCOMMUNICATING,
    b06_ofi = B06OFW,
    c01_literate = C01READ,
    c02_hgc_level = C02,
    c02_hgc = C02HGC,
    c03_attending_school = C03ATTEND,
    c04_school_type = C04SCHOOL,
    c05_current_grade = C05CURGRADE,
    c06_reason_not_in_school = C06NOTATTEND,
    c07_tvet_graduate = C07TEACH,
    c08_tvet_attending = C08TECHVOC,
    matches('^C\\d{2}[A-QZ]'),
    d01_reg_voter = D01REGVOTER,
    d02_voted = D02VOTE,
    d03_attend_assembly = D03ATTEND,
    d04_reason_not_in_assembly = D041NOTATTEND,
    d05_suggest_in_assemby = D05SUGGESTIONS,
    d06_volunteered = D06VOLUNTEER,
    d07_volunteer_compensated = D07RECEIVE,
    d08_volunteer_work = D08,
    e01_work = E01WORK,
    e02_work_arrangement = E02WORK,
    e03_business = E03NOTWORK,
    e04_use_online_for_work = E04ENGAGE,
    e05_work_prov = E05PROVINCE,
    e06_work_city = E06CITY,
    e08_psoc = E08PSOC,
    e10_psic = E10PSIC,
    e11_nature_of_employment = E11NATURE,
    e12_normal_work_hr = E12NORMALHR,
    e13_total_work_hr = E13TOTALHRS,
    e14_want_more_hr = E14WANT,
    e15_want_additional_work = E15ADDWORK,
    e16_class_of_worker = E16CLASSWORK,
    e17_payment_basis = E17BASIS,
    e18_basic_pay = E18BASIC,
    e20_total_all_work_hr = E20HRSPASTWEEK,
    e21_reason_work_hr = E21REASON,
    e22_not_look_for_work = E22LOOK,
    e23_not_look_for_work_reason = E23NOTLOOK,
    e24_work_opportunity = E24AVAILABLE,
    e25_work_anytime = E25ANYTIME,
    e28_psoc_prev_work = E28PSOC,
    e30_psic_prev_work = E30PSIC
  ) %>% 
  filter(case_id %in% ref_rov_occupied) %>% 
  filter(age >= 0, !is.na(sex)) %>% 
  collect() %>% 
  mutate(line_number = if_else(case_id != lag(case_id) & is.na(line_number), 1L, line_number)) %>% 
  mutate_line_number() %>% 
  left_join(ip_refs, by = 'a10_ethnicity') %>% 
  mutate(
    case_id_m = paste0(case_id, sprintf('%02d', line_number)),
    a09_marital = if_else(is.na(a09_marital) & age < 15, 1L, a09_marital),
    a09_marital = if_else(is.na(a09_marital), 8L, a09_marital),
    a10_ethnicity = if_else(is.na(a10_ethnicity), 998L, a10_ethnicity),
    a11_religion = if_else(is.na(a11_religion), 998L, a11_religion),
    philsys_id = case_when(
      a12_with_philsys_id == 1 ~ 1,
      a12_with_philsys_id %in% c(2, 8) & a12_philsys_step_2 == 1 ~ 2,
      a12_with_philsys_id %in% c(2, 8) & a12_philsys_step_2 == 2 ~ 3
    ),
    age_group = case_when(
      #age == 0  ~ 1,
      age < 5 ~ 2,
      age < 10 ~ 3,
      age < 15 ~ 4,
      age < 20 ~ 5,
      age < 25 ~ 6,
      age < 30 ~ 7,
      age < 35 ~ 8,
      age < 40 ~ 9,
      age < 45 ~ 10,
      age < 50 ~ 11,
      age < 55 ~ 12,
      age < 60 ~ 13,
      age < 65 ~ 14,
      age < 70 ~ 15,
      age < 75 ~ 16,
      age < 80 ~ 17,
      age < 85 ~ 18,
      age < 90 ~ 19,
      age < 95 ~ 20,
      age < 100 ~ 21,
      age >= 100 ~ 22
    ),
    age_group_hh = case_when(
      age < 15 ~ 1,
      age < 25 ~ 2,
      age < 35 ~ 3,
      age < 45 ~ 4,
      age < 55 ~ 5,
      age < 65 ~ 6,
      age >= 65 ~ 7
    ),
    age_group_birth = case_when(
      age < 15 ~ 1,
      age < 20 ~ 2,
      age < 25 ~ 3,
      age < 30 ~ 4,
      age < 35 ~ 5,
      age < 40 ~ 6,
      age < 45 ~ 7,
      age >= 45 ~ 8
    ),
    a08_reg_lcr = if_else(is.na(a08_reg_lcr), 8L, a08_reg_lcr),
    a15_solo_parent_id = if_else(is.na(a15_solo_parent_id), 8L, a15_solo_parent_id),
    a16_senior_citizen_id = if_else(is.na(a16_senior_citizen_id), 8L, a16_senior_citizen_id),
    a17_ssdi = if_else(a17_see > 2 | a17_hear > 2 | a17_walk > 2 | a17_remember > 2 | a17_selfcare > 2 | a17_communicate > 2, 1, 2),
    a17_sssco_see = if_else(a17_see == 1, 0, 6 ^ (a17_see - 2)),
    a17_sssco_hear = if_else(a17_hear == 1, 0, 6 ^ (a17_hear - 2)),
    a17_sssco_walk = if_else(a17_walk == 1, 0, 6 ^ (a17_walk - 2)),
    a17_sssco_remember = if_else(a17_remember == 1, 0, 6 ^ (a17_remember - 2)),
    a17_sssco_selfcare = if_else(a17_selfcare == 1, 0, 6 ^ (a17_selfcare - 2)),
    a17_sssco_communicate = if_else(a17_communicate == 1, 0, 6 ^ (a17_communicate - 2)),
    hgc_group = case_when(
      c02_hgc <= 2000 ~ 1, # no grade completed / early childhood education,
      c02_hgc <= 10017 ~ 2, # elementary level,
      c02_hgc == 10018 ~ 3, # elementary graduate,
      c02_hgc <= 24014 ~ 4, # junior high school level,
      c02_hgc <= 24024 ~ 5, # junior high school graduate,
      c02_hgc %in% c(34011, 34012, 34021, 34022, 34031, 34032, 35011, 35012) ~ 6,
      c02_hgc %in% c(34013:34018, 34023:34028, 34033, 35013:35018) ~ 7, # senior high school graduate,
      c02_hgc %in% c(40001:40003) ~ 8, # post-secondary non-tertiary level,
      c02_hgc %in% c(40011:49999) ~ 9, # post-secondary non-tertiary graduate,
      c02_hgc %in% c(50001:50003) ~ 10, # short-cycle tertiary level,
      c02_hgc %in% c(50011:59999) ~ 11, # short-cycle tertiary graduate,
      c02_hgc %in% c(60001:60006) ~ 12, # college level,
      c02_hgc %in% c(69998:69999) ~ 13, # college graduate,
      c02_hgc == 70010 ~ 14, # masteral level,
      c02_hgc %in% c(79998:79999) ~ 15, # masteral graduate,
      c02_hgc == 80010 ~ 16, # doctoral level,
      c02_hgc > 80010 ~17 # college graduate or higher
    ),
    age_group_school = case_when(
      age >= 3 & age < 5 ~ 1,
      age == 5 ~ 2,
      age < 12 ~ 3,
      age < 16 ~ 4,
      age < 18 ~ 5,
      age < 21 ~ 6,
      age >= 21 & age <= 24 ~ 7
    ),
    age_group_15_over = case_when(
      age >= 15 & age < 25 ~ 1,
      age < 35 ~ 2,
      age < 45 ~ 3,
      age < 55 ~ 4,
      age < 65 ~ 5,
      age >= 65 ~ 6
    ),
    d01_voter = case_when(
      d01_reg_voter == 1 & d02_voted == 1 ~ 1,
      d01_reg_voter == 1 & d02_voted != 1 ~ 2,
      d01_reg_voter == 2 ~ 3
    ),
    d04 = if_else(
      d04_reason_not_in_assembly == 9 | is.na(d04_reason_not_in_assembly), 
      d04_reason_not_in_assembly, 
      d04_reason_not_in_assembly + 1L
    ),
    d06_volunteer = case_when(
      d06_volunteered == 1 & d07_volunteer_compensated == 1 ~ 1,
      d06_volunteered == 1 & d07_volunteer_compensated != 1 ~ 2,
      d06_volunteered == 2 ~ 3
    ),
    d05 = if_else(d03_attend_assembly == 1 & d05_suggest_in_assemby == 1, 1L, 0L, 0L),
    e01_employed = if_else(e01_work == 1 | e03_business == 1, 1, 2),
    e08_occupation_group = sprintf('%04d', e08_psoc),
    e10_industry_group = case_when(
      e10_psic > 0 & e10_psic < 330  ~ 1,
      e10_psic < 3500 ~ 2,
      e10_psic < 9910 ~ 3,
      TRUE ~ 4
    )
  ) %>%
  mutate(
    a17_sssco = rowSums(select(., starts_with('a17_sssco_'))),
    a17_sssc = case_when(
      a17_sssco == 0 ~ 1,
      a17_sssco < 5 ~ 2,
      a17_sssco < 24 ~ 3,
      a17_sssco >= 24 ~ 4
    ),
    d03_not_attend_assembly = if_else(d05 %in% c(0, 1) & d03_attend_assembly == 1, d05, d04),
    e08_occupation_group = if_else(grepl('^0', e08_occupation_group), 10L, as.integer(str_sub(e08_occupation_group, 1, 1))),
    e10_industry_group = as.integer(str_sub(e10_industry_group, 1, 2))
  ) %>% 
  mutate(
    sex = factor_ts(sex, c(1, 2), c('Male', 'Female')),
    age_group_fct = factor_ts(age_group, code_ref = 'age_group_m'),
    age_group_5_over_fct = factor_ts(age_group, exclude = c(1, 2), code_ref = 'age_group_5_over'),
    age_group_school_fct = factor_ts(age_group_school, code_ref = 'age_group_school'),
    age_group_hh_fct = factor_ts(age_group_hh, code_ref = 'age_group_hh'),
    age_group_birth_fct = factor_ts(age_group_birth, code_ref = 'age_group_birth'),
    age_group_15_over_fct = factor_ts(age_group_15_over, code_ref = 'age_group_15_over'),
    a08_reg_lcr_fct = factor_ts(a08_reg_lcr, c(1, 2), c('Registered with LCR', 'Not Registered with LCR')),
    a09_marital_fct = factor_ts(a09_marital, code_ref = 'a09'),
    a10_ethnicity_fct = factor_ts(a10_ethnicity, code_ref = 'a10'),
    a10_ip_fct = factor_ts(ip_type, c(1:3), c('IP Groups', 'Non-IP Groups', 'Foreign Citizen')),
    a11_religion_fct = factor_ts(a11_religion, code_ref = 'a11'),
    a12_philsys_id_fct = factor_ts(philsys_id, code_ref = 'a12'),
    a15_solo_parent_id_fct = factor_ts(a15_solo_parent_id, c(1, 2), c('With Solo Parent ID', 'Without Solo Parent ID')),
    a16_senior_citizen_id_fct = factor_ts(a16_senior_citizen_id, c(1, 2), c('With Senior Citizen ID', 'Without Senior Citizen ID')),
    a17_ssdi_fct = factor_ts(a17_ssdi, c(1, 2), c('With Disability', 'Without Disability')),
    a17_sssc_fct = factor_ts(a17_sssc, c(1:4), c('None', 'Mild', 'Moderate', 'Severe')),
    c01_literate_fct = factor_ts(c01_literate, c(1, 2), c('Literate', 'Illiterate')),
    c02_hgc_fct = factor_ts(hgc_group, code_ref = 'c02'),
    c03_attending_school_fct = factor_ts(c03_attending_school, c(1, 2), c('Currently Attending School', 'Currently Not Attending School')),
    c04_school_type_fct = factor_ts(c04_school_type, code_ref = 'c04'),
    c05_current_grade_fct = factor_ts(c05_current_grade, code_ref = 'c03'),
    c06_reason_not_in_school_fct = factor_ts(c06_reason_not_in_school, code_ref = 'c06'),
    d01_voter_fct = factor_ts(d01_voter, code_ref = 'd01'),
    d06_volunteer_fct = factor_ts(d06_volunteer, code_ref = 'd06'),
    d03_not_attend_assembly_fct = factor_ts(d03_not_attend_assembly, code_ref = 'd04'),
    e01_employed_fct = factor_ts(e01_employed, c(1, 2), c('Employed', 'Unemployed')),
    #e01_labor_force_fct = factor_ts(e01_labor_force, c(1, 2), c('In the Labor Force', 'Not in the Labor Force')),
    e16_class_of_worker_fct = factor_ts(e16_class_of_worker, code_ref = 'e16'),
    e08_occupation_group_fct = factor_ts(e08_occupation_group, code_ref = 'e08'),
    e10_industry_group_fct = factor_ts(e10_industry_group, code_ref = 'e10')
  ) %>% 
  select(case_id, case_id_m, everything())

ref_rov_reg <- hpq_individual %>% distinct(case_id) %>% pull(case_id)

ref_rov <- ref_rov %>% 
  mutate(occupancy = if_else(case_id %in% ref_rov_reg, 1L, 0L))

ref_lfp <- hpq_individual %>% 
  filter(age >= 15, !(b06_ofi %in% c(1, 2, 3, 6))) %>% 
  mutate(
    nilf_1 = e01_work == 2 & e03_business %in% c(2, 3) & e22_not_look_for_work == 1 & e24_work_opportunity == 2,
    nilf_2 = e01_work == 2 & e03_business %in% c(2, 3) & e22_not_look_for_work == 2 & e23_not_look_for_work_reason %in% c(6:10),
    nilf_3 = e01_work == 2 & e03_business %in% c(2, 3) & e22_not_look_for_work == 2 & e23_not_look_for_work_reason %in% c(0:5) & e24_work_opportunity == 2
  ) %>% 
  mutate(lfp = if_else(nilf_1 | nilf_2 | nilf_3, 2, 1))