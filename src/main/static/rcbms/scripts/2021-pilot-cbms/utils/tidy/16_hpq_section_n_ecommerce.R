ref_ecom <- hpq_data$SECTION_N %>% 
  filter_reg_ts() %>% 
  select(-contains('SPECIFY')) %>% 
  collect() %>% 
  mutate(
    n01_internet_access = case_when(
      N1 == 1 & N3 == 1 ~ 1L,
      N1 == 1 & N3 == 2 ~ 2L,
      N1 == 2 ~ 3L
    )
  ) %>% 
  mutate(
    n01_internet_access_fct = factor_ts(n01_internet_access, code_ref = 'n01'),
    n05_pay_internet_fct = factor_ts(N5, c(1, 2), c('Paying for Internet', 'Not Paying for Internet')),
    n08_purchase_online_fct = factor_ts(N8, code_ref = 'n08'),
    n09_work_online_fct = factor_ts(N9, c(1, 2), c('Engaged in Online Work', 'Not Engaged in Online Work'))
  )

ref_with_net <- ref_ecom %>% filter(N1 == 1)
