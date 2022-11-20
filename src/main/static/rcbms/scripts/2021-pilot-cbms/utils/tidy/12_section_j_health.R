from_live_birth <- hpq_data$SECTION_J2 %>% 
  full_join_ts(
    J02LNO, 
    age_group_5_over_fct,
    age_group_birth_fct,
    c02_hgc_fct,
    e01_employed_fct
  ) %>% 
  mutate(had_live_birth = 1)

# ====================================================================================
from_pregnant <- hpq_data$SECTION_J6 %>% 
  full_join_ts(J06_LNO, age_group_birth_fct) %>% 
  mutate(pregnant = 1)

# ====================================================================================
ref_pwd <- hpq_data$SECTION_J15 %>% 
  full_join_ts(J15) %>% 
  mutate(j17_disagnosed_fct = factor_ts(J17, c(1, 2), c('Diagnosed by a Doctor', 'Not Diagnosed by a Doctor')))

# ====================================================================================
ref_mortality <- hpq_data$SECTION_J10 %>% 
  filter_reg_ts() %>% 
  filter(rowSums(is.na(.)) < (ncol(.) - 6)) %>% 
  distinct(case_id, J11, J12, .keep_all = T) %>% 
  mutate(
    age = J12,
    sex = factor_ts(J11, c(1, 2), c('Male', 'Female')),
    j13_cause_death_fct = factor_ts(J13, code_ref = 'j13'),
    neonatal = if_else(age == 0, 1, 0),
    postneonatal = if_else(age > 0 & age < 12, 1, 0),
    infant = if_else(age < 12, 1, 0),
    child = if_else(age >= 12 & age < 60, 1, 0)
  )

get_mortality <- function(data, ..., label) {
  data %>% 
    group_by(...) %>% 
    summarise(
      'Neonatal Mortality' = sum(neonatal, na.rm = T),
      'Postneonatal Mortality' = sum(postneonatal, na.rm = T),
      'Infant Mortality' = sum(infant, na.rm = T),
      'Child Mortality' = sum(child, na.rm = T),
      'Under-5 Mortality' = n()
    ) %>% 
    rename((!!as.name(label)) := 1) %>% 
    adorn_totals()
}

# ====================================================================================
from_cancer_patient <- hpq_data$SECTION_J19 %>% full_join_ts(J19_LNO)

# ====================================================================================
from_cancer_survivor <- hpq_data$SECTION_J21 %>% full_join_ts(J21_LNO)

# ====================================================================================
from_rare_disease <- hpq_data$SECTION_J23 %>% full_join_ts(J23)

# ====================================================================================
ref_sickness <- hpq_data$SECTION_J33 %>% 
  full_join_ts(J33) %>% 
  mutate(
    recent_illness_fct = factor_ts(J37, code_ref = 'j37'),
    seek_medical = if_else(J38 == 1, 0L, J41),
    J39 = if_else(J38 == 2, '', str_trim(J39)),
    J40 = if_else(J38 == 2, '', str_trim(J40)),
    seek_medical_fct = factor_ts(seek_medical, code_ref = 'j41')
  ) %>% 
  mutate(
    effect = case_when(
      age >= 5 & J35 == 1 ~ 1,
      age >= 5 & J35 == 2 ~ 2,
      TRUE ~ 3
    ),
    effect_fct = factor_ts(effect, c(1:3), c('Affected', 'Not Affected', 'Not Applicable'))
  ) %>% 
  na_if('')
