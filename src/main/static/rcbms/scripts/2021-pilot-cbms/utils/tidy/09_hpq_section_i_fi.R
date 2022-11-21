ref_fi <- hpq_data$SECTION_I %>% 
  filter_reg_ts() %>% 
  select(-contains('SPECIFY')) %>% 
  mutate_at(vars(matches('^I1_[A-F]$')), ~ if_else(. == 2, 0L, 1L)) %>% 
  mutate(
    with_fa = if_else(rowSums(select(., matches('I1_[A-F]')), na.rm = T) > 0, 1L, 0L),
    fa_reason = if_else(with_fa == 1, '0', str_trim(I2)),
    with_sa = if_else(
      I4_01 == 2 & I4_02 == 2 & I4_03 == 2 & I4_04 == 2 & I4_05 == 2 & I4_06 == 2 & I4_07 == 2 |
        I5 == 2 | with_fa == 0, 1L, 2L)
  ) %>% 
  mutate(
    with_fa_fct = factor_ts(with_fa, c(1, 0), c('With financial acount', 'Without financial account')),
    with_sa_fct = factor_ts(with_sa, c(1, 2), c('With savings', 'Without savings'))
  )


