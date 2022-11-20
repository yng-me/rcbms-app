
print('Processing Section P...')

section_p <- suppressWarnings(
  hpq_data$SECTION_P %>% 
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  collect() %>% 
  mutate_at(vars(matches('P([246]|1[258])[A-J]_[1-6]'), matches('P9_[1-6]')), as.integer) %>% 
  select(case_id, pilot_area, starts_with('P'), -contains('SPECIFY'), -PROVINCE) %>% 
  rename_at(vars(matches('^P[4]TLNO')), ~ str_replace(., '^P4', 'P3'))
)

p_list <- list()

# SOCIAL INSURANCE
for(i in 1:7) {

  p_list[[paste0('cv_p01_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(paste0('P1_', i))) %>% 
    filter(!(!!as.name(paste0('P1_', i)) %in% c(1, 2, NA)))
  
  p_list[[paste0('cv_p02_', letters[i], '_missing_but_p01_is_yes')]] <- section_p %>% 
    select(
      case_id, pilot_area, contains(c(paste0('P1_', i),
      paste0('P2TLNO_', i), paste0('P2', LETTERS[i])))
    ) %>% 
    filter(
      !!as.name(paste0('P1_', i)) == 1,
      str_trim(!!as.name(paste0('P2TLNO_', i))) == '',
      rowSums(select(., contains(paste0('P2', LETTERS[i]))), na.rm = T) == 0
    )
  
  p_list[[paste0('cv_p02_', letters[i], '_with_ans_but_p01_is_no')]] <- section_p %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('P1_', i), paste0('P2TLNO_', i), paste0('P2', LETTERS[i])))
    ) %>% 
    filter(
      !!as.name(paste0('P1_', i)) == 2, 
      str_trim(!!as.name(paste0('P2TLNO_', i))) != '',
      rowSums(select(., contains(paste0('P2', LETTERS[i]))), na.rm = T) > 0
    )
  
  p_list[[paste0('cv_p03_', letters[i], '_with_ans_but_p01_is_no')]] <- section_p %>% 
    select(case_id, pilot_area, matches(paste0('P[13]_', i))) %>% 
    filter(
      !!as.name(paste0('P1_', i)) == 2, 
      !is.na(!!as.name(paste0('P3_', i)))
    )
  
  p_list[[paste0('cv_p03_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, matches(paste0('P[13]_', i))) %>% 
    filter(
      !!as.name(paste0('P1_', i)) == 1, 
      !(!!as.name(paste0('P3_', i)) %in% c(1, 2, NA))
    )
  
  p_list[[paste0('cv_p04_', letters[i], '_missing_but_p03_is_yes')]] <- section_p %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('P1_', i), paste0('P3_', i), paste0('P3TLNO_', i), paste0('P4', LETTERS[i])))
    ) %>% 
    filter(
      !!as.name(paste0('P1_', i)) == 1, 
      !!as.name(paste0('P3_', i)) == 1, 
      str_trim(!!as.name(paste0('P3TLNO_', i))) == '',
      rowSums(select(., contains(paste0('P4', LETTERS[i]))), na.rm = T) == 0
    ) 
  
  p_list[[paste0('cv_p04_', letters[i], '_with_ans_but_p03_is_no')]] <- section_p %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('P1_', i), paste0('P3_', i), paste0('P3TLNO_', i), paste0('P4', LETTERS[i])))
    ) %>% 
    filter(
      !!as.name(paste0('P1_', i)) == 1, 
      !!as.name(paste0('P3_', i)) == 2, 
      str_trim(!!as.name(paste0('P3TLNO_', i))) != '',
      rowSums(select(., contains(paste0('P4', LETTERS[i]))), na.rm = T) > 0
    ) 
}

# SOCIAL ASSISTANCE
for (i in 1:10) {
  p_var <- paste0('P5_RECEIVE_BENEFITS_', sprintf('%02d', i))
  p_var_lno <- paste0('P6TLNO_', sprintf('%02d', i))

  p_list[[paste0('cv_p05_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(p_var)) %>% 
    filter(!(!!as.name(p_var) %in% c(1, 2, NA)))
  
  p_list[[paste0('cv_p06_', letters[i], '_missing_but_p05_is_yes')]] <- section_p %>% 
    select(case_id, pilot_area, contains(c(p_var, p_var_lno, paste0('P6', LETTERS[i])))) %>% 
    filter(
      !!as.name(p_var) == 1, 
      str_trim(!!as.name(p_var_lno)) == '',
      rowSums(select(., contains(paste0('P6', LETTERS[i]))), na.rm = T) == 0
    )
  
  p_list[[paste0('cv_p06_', letters[i], '_with_ans_but_p05_is_no')]] <- section_p %>% 
    select(case_id, pilot_area, contains(c(p_var, p_var_lno, paste0('P6', LETTERS[i])))) %>% 
    filter(
      !!as.name(p_var) == 2, 
      str_trim(!!as.name(p_var_lno)) != '',
      rowSums(select(., contains(paste0('P6', LETTERS[i]))), na.rm = T) > 0
    )
  
  p_list[[paste0('cv_p07_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(c(p_var, paste0('P7_', sprintf('%02d', i))))) %>% 
    filter(
      !!as.name(p_var) == 1, 
      !!as.name(paste0('P7_', sprintf('%02d', i))) < 1 | is.na(!!as.name(paste0('P7_', sprintf('%02d', i))))
    )
}


# GOVERNMENT FEEDING PROGRAM
cv_p08_not_in_vs_missing <- section_p %>% 
  select(case_id, pilot_area, P8) %>% 
  filter(!(P8 %in% c(1, 2, NA)))

cv_p09_missing_but_p08_is_yes <- section_p %>% 
  select(case_id, pilot_area, P8, matches('P9_[1-6]')) %>% 
  filter(P8 == 1, rowSums(select(., matches('P9_[1-6]'))) == 0)

cv_p09_with_ans_but_p08_is_no <- section_p %>% 
  select(case_id, pilot_area, P8, matches('P9_[1-6]')) %>% 
  filter(P8 == 2, rowSums(select(., matches('P9_[1-6]'))) > 0)


# LABOR MARKET INTERVENTION
for (i in 1:6) {

  p_list[[paste0('cv_p11_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(paste0('P11_', i))) %>% 
    filter(!(!!as.name(paste0('P11_', i)) %in% c(1, 2, NA)))
  
  p_list[[paste0('cv_p12_', letters[i], '_missing_but_p11_is_yes')]] <- section_p %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('P11_', i), paste0('P12TLNO_', i), paste0('P12', LETTERS[i])))
    ) %>% 
    filter(
      !!as.name(paste0('P11_', i)) == 1, 
      str_trim(!!as.name(paste0('P12TLNO_', i))) == '',
      rowSums(select(., contains(paste0('P12', LETTERS[i]))), na.rm = T) == 0
    )
  
  p_list[[paste0('cv_p12_', letters[i], '_with_ans_but_p11_is_no')]] <- section_p %>% 
    select(
      case_id, pilot_area, 
      contains(c(paste0('P11_', i), paste0('P12TLNO_', i), paste0('P12', LETTERS[i])))
    ) %>% 
    filter(
      !!as.name(paste0('P11_', i)) == 2, 
      str_trim(!!as.name(paste0('P12TLNO_', i))) != '',
      rowSums(select(., contains(paste0('P12', LETTERS[i]))), na.rm = T) > 0
    )
  
  p_list[[paste0('cv_p13_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(c(paste0('P11_', i), paste0('P13_', i)))) %>% 
    filter(
      !!as.name(paste0('P11_', i)) == 1, 
      !!as.name(paste0('P13_', i)) < 1 | is.na(!!as.name(paste0('P13_', i)))
    )
}

# AGRICULTURE AND FISHERIES
for (i in 1:10) {
  p_var <- paste0('P14_', sprintf('%02d', i))
  p_var_lno <- paste0('P15TLNO_', sprintf('%02d', i))
  
  p_list[[paste0('cv_p14_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(p_var)) %>% 
    filter(!(!!as.name(p_var) %in% c(1, 2, NA)))
  
  p_list[[paste0('cv_p15_', letters[i], '_missing_but_p14_is_yes')]] <- section_p %>% 
    select(case_id, pilot_area, contains(c(p_var, p_var_lno, paste0('P15', LETTERS[i])))) %>% 
    filter(
      !!as.name(p_var) == 1, 
      str_trim(!!as.name(p_var_lno)) == '',
      rowSums(select(., contains(paste0('P15', LETTERS[i]))), na.rm = T) == 0
    )
  
  p_list[[paste0('cv_p15_', letters[i], '_with_ans_but_p14_is_no')]] <- section_p %>% 
    select(case_id, pilot_area, contains(c(p_var, p_var_lno, paste0('P15', LETTERS[i])))) %>% 
    filter(
      !!as.name(p_var) == 2, 
      str_trim(!!as.name(p_var_lno)) != '',
      rowSums(select(., contains(paste0('P15', LETTERS[i]))), na.rm = T) > 0
    )
  
  p_list[[paste0('cv_p16_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(c(p_var, paste0('P16_', sprintf('%02d', i))))) %>% 
    filter(
      !!as.name(p_var) == 1, 
      !!as.name(paste0('P16_', sprintf('%02d', i))) < 1 | 
        is.na(!!as.name(paste0('P16_', sprintf('%02d', i))))
    )
}

for (i in 1:13) {
  p_var <- paste0('P17_', sprintf('%02d', i))
  p_var_lno <- paste0('P18TLNO_', sprintf('%02d', i))
  
  p_list[[paste0('cv_p17_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(p_var)) %>% 
    filter(!(!!as.name(p_var) %in% c(1, 2, NA)))
  
  p_list[[paste0('cv_p18_', letters[i], '_missing_but_p17_is_yes')]] <- section_p %>% 
    select(
      case_id, pilot_area, 
      contains(c(p_var, p_var_lno, paste0('P18', LETTERS[i])))
    ) %>% 
    mutate_at(vars(contains(paste0('P18', LETTERS[i]))), as.integer) %>% 
    filter(
      !!as.name(p_var) == 1,
      str_trim(!!as.name(p_var_lno)) == '',
      rowSums(select(., contains(paste0('P18', LETTERS[i]))), na.rm = T) == 0
    )
  
  p_list[[paste0('cv_p18_', letters[i], '_with_ans_but_p17_is_no')]] <- section_p %>% 
    select(
      case_id, pilot_area, 
      contains(c(p_var, p_var_lno, paste0('P18', LETTERS[i])))
    ) %>% 
    mutate_at(vars(contains(paste0('P15', LETTERS[i]))), as.integer) %>% 
    filter(
      !!as.name(p_var) == 2, 
      str_trim(!!as.name(p_var_lno)) != '',
      rowSums(select(., contains(paste0('P15', LETTERS[i]))), na.rm = T) > 0
    )
  
  p_list[[paste0('cv_p19_', letters[i], '_not_in_vs_and_missing')]] <- section_p %>% 
    select(case_id, pilot_area, contains(c(p_var, paste0('P19_', sprintf('%02d', i))))) %>% 
    filter(
      !!as.name(p_var) == 1, 
      !!as.name(paste0('P19_', sprintf('%02d', i))) < 1 | 
        is.na(!!as.name(paste0('P19_', sprintf('%02d', i))))
    )
}

list2env(p_list, section_p, envir = .GlobalEnv)
rm(p_list)

