ref_crime <- hpq_data$SECTION_O %>% 
  filter_reg_ts() %>% 
  mutate(O1 = ifelse(O1 == 6, NA, O1)) %>% 
  mutate_at(vars(matches('^O3_\\d{2}')), ~ if_else(. == 2, 0L, 1L))

recode_crime <- function(crime) {
  name <- ref_codes %>% 
    filter(list_name == 'o03') %>% 
    select(label, value) %>% 
    filter(value == crime)
  
  O4 <- paste0('O4_', crime)
  O5 <- paste0('O5_', crime)
  O6 <- paste0('O6_', crime)
  O7 <- paste0('O7_', crime)
  O8 <- paste0('O8_', crime)
  
  hpq_data[[paste0('SECTION_O', crime)]] %>% 
    full_join_ts(eval(parse(text = O4))) %>% 
    filter(rowSums(is.na(.)) < 4) %>%
    mutate(
      reported = !!as.name(O7),
      reason = !!as.name(O8),
      reason_reported = if_else(reported == 1, 0L, reason),
      crime = crime,
      occ = !!as.name(O5),
      loc_fct = factor_ts(!!as.name(O6), code_ref = 'o06'),
      reason_reported_fct = factor_ts(reason_reported, code_ref = 'o08')
    ) %>% 
    select(-matches('^O\\d_[A-KZ]'), -c(reported, reason, reason_reported))
}

ref_crimes_list <- lapply(c(LETTERS[1:11], 'Z'), recode_crime)
ref_crimes_df <- do.call('rbind', ref_crimes_list) %>% 
  mutate(crime_fct = factor_ts(crime, code_ref = 'o03', is_char = T)) %>% 
  tibble()
