
# Section H {.unnumbered}

section_a <- hpq$section_a %>% collect()
section_b <- hpq$section_b %>% collect()
section_e <- hpq$section_e %>% collect()
ref_hh_count <- section_a %>% count(case_id)

section_h <- hpq$section_h %>% 
  collect() %>%
  filter_at(vars(matches('^h\\d.*')), any_vars(!is.na(.))) %>% 
  distinct(case_id, .keep_all = T) 


section_h1 <- hpq$section_h1 %>% 
  collect() %>%
  filter_at(vars(matches('^h\\d.*')), any_vars(!is.na(.))) %>%
  filter(!is.na(h01_lno)) %>% 
  mutate(line_number_id = if_else(!is.na(h01_lno), paste0(case_id, sprintf('%02d', as.integer(h01_lno))), '')) %>% 
  na_if('') %>% 
  left_join(dplyr::select(section_b, line_number_id, b06_ofi), by = 'line_number_id') %>% 
  left_join(dplyr::select(section_a, matches('^a01'), age, line_number_id, a02_reltohhh), by = 'line_number_id') %>% 
  left_join(dplyr::select(section_e, line_number_id, e01_work, e03_jobbus, e18_class, e18_class_fct), by = 'line_number_id') %>% 
  left_join(dplyr::select(section_h, case_id, matches('^h0[2-3]en_.*')), by = 'case_id') %>% 
  left_join(ref_hh_count, by = 'case_id')

section_h_emp <- section_h1 %>%
  filter(
    age >= 5,
    b06_ofi %in% c(4, 5, 7), 
    a02_reltohhh %in% c(1:23)
  )

gather_other_income <- function(data) {
  df <- list()
  for(i in 1:2) {
    df[[i]] <- data %>%
      select(1:6, matches(paste0('h3z_otherspecify', i)), matches(paste0('h3za_otherspecify', i))) %>%
      rename(other = 7, amount = 8)
  }
  return(do.call('rbind', df) %>% tibble())
}

from_section_f <- hpq$section_f %>%
  collect() %>%
  mutate(
    with_entrep = if_else(rowSums(select(., matches('^f03_'), -matches('_fct$')), na.rm = T) < 44, 1L, 0L),
    with_sa = if_else(f01_foodconsum == 1 & rowSums(select(., matches('^f02_'), -matches('_fct$')), na.rm = T) < 10, 1L, 0L)
  ) %>% 
  select(case_id, with_entrep, f01_foodconsum, f01_foodconsum_fct, with_sa)

from_section_p <- hpq$section_p %>% 
  select(case_id, p05a_reg4ps, p05b_mod4ps, p05a_reg4ps_fct, p05b_mod4ps_fct, p07a_reg4ps, p07b_mod4ps, p15a_sap, p15a_sap_fct) %>% 
  collect() 

with_senior <- hpq$section_a %>% 
  collect() %>%
  mutate(with_senior = if_else(age >= 60, 1L, 0L)) %>%
  group_by(case_id) %>% 
  summarise(with_senior = max(with_senior, na.rm = T), .groups = 'drop')


### H01 - Family members who are regularly/seasonally employed is blank/not in the valueset

## Select family members who are regularly/seasonally employed from the roster.
(
  cv_h_ffmem_nitv <- section_h1 %>% 
    filter(as.integer(h01_lno) < 0 | as.integer(h01_lno) > n) %>% 
    select_cv(h01_lno, h = 'h01_lno')
)[[1]]


### H01 - Selected household member is an OFW

## Income of OFW should be reported in H03K (Other cash receipts, support, assistance, and relief from domestic sources).
(
  cv_h01_hhmember_ofi <- section_h1 %>% 
    filter(b06_ofi %in% c(1:3, 6)) %>% 
    filter_at(vars(matches('^h(01|2[a-c])_.*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(h01_lno, b06_ofi, matches('^h(01|2[a-c])_.*'))
)[[1]]


### H01 - Selected household member is a DOMESTIC HELPER or NONRELATIVE

## Income of domestic helper and non relative should be excluded.
(
  cv_h01_not_fam_member <- section_h1 %>% 
    filter(a02_reltohhh %in% c(24:26)) %>% 
    filter_at(vars(matches('^h(01|2[a-c])_.*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(h01_lno, matches('^h(01|2[a-c])_.*'))
)[[1]]


### H01 - Selected household member is employed/has a job/business but H01a is blank

## Household member is employed/have a job/business, there must be answer in H01a.
(
  cv_h01_employed <- section_h1 %>% 
    filter(e01_work == 1 | e03_jobbus == 1, e18_class %in% c(0:2)) %>% 
    filter_at(vars(matches('^h02en_*'), -matches('_fct$')), any_vars(. == 1)) %>% 
    filter_at(vars(matches('^h(01|2[a-c])_.*'), -matches('_fct$')), all_vars(is.na(.))) %>% 
    select_cv(h01_lno, e01_work, e03_jobbus, e18_class_fct, matches('^h(01|2[a-c])_.*'))
)[[1]]


### H02 - No regularly/seasonally employed in the household but salaries and wages, commissions, other forms of compensation is not blank

## There's no regularly/seasonally employed household member. Salaries and wages, commissions, other forms of compensation must be blank.
(
  cv_h2a_salaries_blank <- section_h1 %>%
    filter(is.na(h01_lno) | as.integer(h01_lno) < 0 | as.integer(h01_lno) > n) %>% 
    filter_at(vars(matches('^h2[a-c]_.*'), -matches("fct$")), any_vars(is.na(.))) %>% 
    select_cv(h01_lno, matches('^h2[a-c]_.*'))
)[[1]]


### H02A - Salaries and wages from regular and seasonal employment is blank/invalid

## Salaries and wages from regular and seasonal employment should not be blank and should be in the value set.
(
  cv_h02_a_salary <- section_h_emp %>% 
    filter(h02en_salaries == 1, !(h2a_salaries %in% c(0:10000000))) %>% 
    select_cv(h01_lno, h02en_salaries_fct, h2a_salaries, h = 'h2a_salaries')
)[[1]]


### H02B - Commissions, tips, bonuses, and allowances is blank/invalid

## Commissions, tips, bonuses, family and clothing allowance, transportation and representation allowance, and honoraria should not be blank and should be in the value set.
(
  cv_h02_b_commission <- section_h_emp %>% 
    filter(h02en_commissions == 1, !(h2b_commissions %in% c(0:10000000))) %>% 
    select_cv(h01_lno, h02en_commissions_fct, h2b_commissions, h = 'h2b_commissions')
)[[1]]


### H02C - Other forms of compensation is blank/invalid

## Other forms of compensation should not be blank and should be in the value set.
(
  cv_h02_c_other_commission <- section_h1 %>% 
    filter(b06_ofi %in% c(4, 5, 7), a02_reltohhh %in% c(1:23), h02en_other == 1, !(h2c_other %in% c(0:10000000))) %>% 
    select_cv(h01_lno, h02en_other_fct, h2c_other, h = 'h2c_other')
)[[1]]


### H02A - Reflected total is not equal to the sum of household members' salaries and wages from regular and seasonal employment

## Reflected total should be equal to the sum of the household members' salaries and wages from regular and seasonal employment.
(
  cv_h2a_total <- section_h1 %>% 
    filter(!(b06_ofi %in% c(1, 3, 6))) %>%
    group_by(case_id) %>%
    summarize(h2a_salaries = sum(h2a_salaries)) %>% 
    left_join(section_h, by = 'case_id') %>% 
    filter(h2a_total != h2a_salaries) %>% 
    select_cv(h2a_total, h2a_salaries, h = c('h2a_total', 'h2a_salaries'))
)[[1]]


### H02B - Reflected total is not equal to the sum of household members' commissions, tips, bonuses and allowances

## Reflected total should be equal to the sum of the household members' commissions, tips, bonuses and allowances.
(
  cv_h2b_total <- section_h1 %>% 
    filter(!(b06_ofi %in% c(1, 3, 6))) %>%
    group_by(case_id) %>%
    summarize(h2b_commissions = sum(h2b_commissions)) %>% 
    left_join(section_h, by = 'case_id') %>% 
    filter(h2b_total != h2b_commissions) %>% 
    select_cv(h2b_total, h2b_commissions, h = c('h2b_total', 'h2b_commissions'))
)[[1]]


### H02C - Reflected total is not equal to the sum of household members' other forms of compensation

## Reflected total is not equal to the sum of household members' other forms of compensation.
(
  cv_h2c_total <- section_h1 %>% 
    filter(!(b06_ofi %in% c(1, 3, 6))) %>%
    group_by(case_id) %>%
    summarize(h2c_other = sum(h2c_other)) %>% 
    left_join(section_h, by = 'case_id') %>% 
    filter(h2c_total != h2c_other) %>% 
    select_cv(h2c_total, h2c_other, h = c('h2c_total', 'h2c_other'))
)[[1]]


### H03D - Net receipts derived from the operation of family-operated enterprises/activities is blank/invalid 

## If the household agreed to answer, net receipts derived from the operation of family-operated enterprises/activities should not be blank and should be in the valueset.
(
  cv_h3d_blank <- section_h %>% 
    filter(h03en_netentrep == 1, !(h3d_netentrep %in% c(0:10000000))) %>% 
    select_cv(h03en_netentrep, h3d_netentrep, h = c('h03en_netentrep', 'h3d_netentrep'))
)[[1]]



### H03D-E - No receipts from entrepreneurial activity but with at least 1 'Yes' in F03

## If the household is engaged in at least one entrepreneurial activity, H03D or H03E must be greater than zero.
(
  cv_h03d_v_f03 <- section_h %>% 
    left_join(from_section_f, by = 'case_id') %>% 
    filter(with_entrep == 1, h03en_netentrep == 1, is.na(h3d_netentrep) & is.na(h3e_netprof)) %>% 
    select_cv(with_entrep, h03en_netentrep, h3d_netentrep, h3e_netprof)
)[[1]]



### H03D-E - With entry but the household is not engaged in any entrepreneurial activity 

## H03D and H03E must be zero if the household is not engaged in any entrepreneurial activity.
(
  cv_h03d_v_f03_na <- section_h %>% 
    left_join(from_section_f, by = 'case_id') %>% 
    filter(with_entrep == 0, h3d_netentrep > 0 | h3e_netprof > 0) %>% 
    select_cv(with_entrep, h03en_netentrep, h3d_netentrep, h3e_netprof)
)[[1]]



### H03D - Net receipts derived from the operation of family-operated enterprises/activities is not blank

## If the household did not agree to answer, net receipts derived from the operation of family-operated enterprises/activities should be blank.
(
  cv_h3d_notblank <- section_h %>% 
    filter(h03en_netentrep == 2, !is.na(h3d_netentrep)) %>% 
    select_cv(h03en_netentrep, h3d_netentrep, h = c('h03en_netentrep', 'h3d_netentrep'))
)[[1]]


### H03E - Net receipts derived from the operation of practice of a profession or trade is blank/invalid

## If the household agreed to answer, net receipts derived from the operation of practice of a profession or trade should not be blank and should be in the valueset.
(
  cv_h3e_netprof_blank <- section_h %>% 
    filter(h03en_netprof == 1, !(h3e_netprof %in% c(0:10000000))) %>% 
    select_cv(h03en_netprof, h3e_netprof, h = c('h03en_netprof', 'h3e_netprof'))
)[[1]]


### H03E - Net receipts derived from the operation of practice of a profession or trade is not blank

## If the household did not agree to answer, net receipts derived from the operation of practice of a profession or trade should be blank.
(
  cv_h3e_netprof_notblank <- section_h %>% 
    filter(h03en_netprof == 2, !is.na(h3e_netprof)) %>%
    select_cv(h03en_netprof, h3e_netprof, h = c('h03en_netprof', 'h3e_netprof'))
)[[1]]


### H03F - Net share of crops and other products from other households is blank/invalid

## If the household agreed to answer, net share of crops and other products from other households should not be blank and should be in the valueset.
(
  cv_h3f_netshare_blank <- section_h %>% 
    filter(h03en_netshare == 1, !(h3f_netshare %in% c(0:10000000))) %>% 
    select_cv(h03en_netshare, h3f_netshare, h = c('h03en_netshare', 'h3f_netshare'))
)[[1]]


### H03F - Net share of crops and other products from other households is not blank

## If the household did not agree to answer, net share of crops and other products from other households should be blank.
(
  cv_h3f_netshare_notblank <- section_h %>% 
    filter(h03en_netshare == 2, !is.na(h3f_netshare)) %>%
    select_cv(h03en_netshare, h3f_netshare, h = c('h03en_netshare', 'h3f_netshare'))
)[[1]]


### H03G - Cash receipts, gifts, support, relief, and other forms of assistance from abroad is blank/invalid

## If the household agreed to answer, cash receipts, gifts, support, relief, and other forms of assistance from abroad should not be blank and should be in the valueset.
(
  cv_h3g_cashreceipts_blank <- section_h %>% 
    filter(h03en_cashreceiptsn == 1, !(h3g_cashreceipts %in% c(0:10000000))) %>% 
    select_cv(h03en_cashreceiptsn, h3g_cashreceipts, h = c('h03en_cashreceiptsn', 'h3g_cashreceipts'))
)[[1]]


### H03G - Cash receipts, gifts, support, relief, and other forms of assistance from abroad is not blank

## If the household did not agree to answer, cash receipts, gifts, support, relief, and other forms of assistance from abroad should be blank.
(
  cv_h3g_cashreceiptsn_notblank <- section_h %>% 
    filter(h03en_cashreceiptsn == 2, !is.na(h3g_cashreceipts)) %>%
  select_cv(h03en_cashreceiptsn, h3g_cashreceipts, h = c('h03en_cashreceiptsn', 'h3g_cashreceipts'))
)[[1]]


### H03H - Pantawid Pamilyang Pilipino Program (4Ps) is blank/invalid

## If the household agreed to answer, Pantawid Pamilyang Pilipino Program (4Ps) should not be blank and should be in the valueset.
(
  cv_h3h_pantawid_blank <- section_h %>% 
    filter(h03en_pantawid == 1, !(h3h_pantawid %in% c(0:10000000))) %>% 
    select_cv(h03en_pantawid, h3h_pantawid, h = c('h03en_pantawid', 'h3h_pantawid'))
)[[1]]


### H03H - Pantawid Pamilyang Pilipino Program (4Ps) is not blank

## If the household did not agree to answer, Pantawid Pamilyang Pilipino Program (4Ps) should be blank.
(
  cv_h3h_pantawid_notblank <- section_h %>% 
    filter(h03en_pantawid == 2, !is.na(h3h_pantawid)) %>%
  select_cv(h03en_pantawid, h3h_pantawid, h = c('h03en_pantawid', 'h3h_pantawid'))
)[[1]]


### H03H v P05 - With receipts from 4Ps but no 4Ps member

## If no household members a beneficiary of 4Ps (P05A and P05B), H03H must be zero.
(
  cv_h3h_v_p05 <- section_h %>% 
    select(1:13, h3h_pantawid) %>% 
    left_join(from_section_p, by = 'case_id') %>% 
    filter(p05a_reg4ps == 2, p05b_mod4ps == 2,  h3h_pantawid > 0) %>%
  select_cv(p05a_reg4ps_fct, p05b_mod4ps_fct, h3h_pantawid, h = 'h3h_pantawid')
)[[1]]


### H03H v P07 -  With receipts from 4Ps in P07A or P07B but entry is zero

## If at least 1 household member received benefits from 4Ps (either P07A or P07B), H03H must be greater than zero.
(
  cv_h3h_v_p07 <- section_h %>% 
    select(1:13, h03en_pantawid, h3h_pantawid) %>% 
    left_join(from_section_p, by = 'case_id') %>% 
    filter(p05b_mod4ps == 1, p05b_mod4ps == 1, p07a_reg4ps > 0 | p07b_mod4ps > 0, h03en_pantawid == 1, h3h_pantawid == 0) %>%
  select_cv(p07a_reg4ps, p07b_mod4ps, h3h_pantawid, h = 'h3h_pantawid')
)[[1]]



### H03I - Social Pension for Indigent Senior Citizen is blank/invalid

## If the household agreed to answer, Social Pension for Indigent Senior Citizen should not be blank and should be in the valueset.
(
  cv_h3i_social_blank <- section_h %>% 
    filter(h03en_social == 1, !(h3i_social %in% c(0:10000000))) %>% 
    select_cv(h03en_social, h3i_social, h = c('h03en_social', 'h3i_social')) 
)[[1]]


### H03I - Social Pension for Indigent Senior Citizen is not blank

## If the household did not agree to answer, Social Pension for Indigent Senior Citizen should be blank.
(
  cv_h3i_social_notblank <- section_h %>% 
    filter(h03en_social == 2, !is.na(h3i_social)) %>%
  select_cv(h03en_social, h3i_social, h = c('h03en_social', 'h3i_social'))
)[[1]]


### H03I - No senior citizen member but with entry greater than zero

## If there no senior citizen member of the household, H03I must be zero.
(
  cv_h03i_v_a19_senior <- section_h %>% 
    left_join(with_senior, by = 'case_id') %>% 
    filter(with_senior == 0, h03en_social == 1, h3i_social > 0) %>% 
    select_cv(with_senior, h3i_social, h = 'h3i_social')
)[[1]]


### H03J - Social Amelioration Program (SAP) to Individuals in Crisis Situation is blank/invalid

## If the household agreed to answer, Social Amelioration Program (SAP) to Individuals in Crisis Situation should not be blank and should be in the valueset.
(
  cv_h3j_social_blank <- section_h %>% 
    filter(h03en_sap == 1, !(h3j_sap %in% c(0:10000000))) %>% 
    select_cv(h03en_sap, h3j_sap, h = c('h03en_sap', 'h3j_sap'))
)[[1]]


### H03J - Social Amelioration Program (SAP) to Individuals in Crisis Situation is not blank

## If the household did not agree to answer, Social Amelioration Program (SAP) to Individuals in Crisis Situation should be blank.
(
  cv_h3j_sap_notblank <- section_h %>% 
    filter(h03en_sap == 2, !is.na(h3j_sap)) %>%
  select_cv(h03en_sap, h3j_sap, h = c('h03en_sap', 'h3j_sap'))
)[[1]]


### H03J - Answered 'Yes' in P15A but entry is zero

## If answered 'Yes' in P15A (received benefits from SAP in the past year), entry for H03J must be greater than zero.
(
  cv_h03j_v_p15 <- section_h %>% 
    select(1:13, h3j_sap, h03en_sap, h03en_sap_fct) %>% 
    left_join(from_section_p, by = 'case_id') %>% 
    filter(p15a_sap == 1, h03en_sap == 1, h3j_sap == 0) %>% 
    select_cv(p15a_sap_fct, h03en_sap_fct, h3j_sap)
)[[1]]


### H03K - Other cash receipts, support, assistance, and relief from domestic sources is blank/invalid

## If the household agreed to answer, other cash receipts, support, assistance, and relief from domestic sources should not be blank and should be in the valueset.
(
  cv_h3k_other_blank <- section_h %>% 
    filter(h03en_other == 1, !(h3k_other %in% c(0:10000000))) %>% 
    select_cv(h03en_other, h3k_other, h = c('h03en_other', 'h3k_other'))
)[[1]]


### H03K - Other cash receipts, support, assistance, and relief from domestic sources is not blank

## If the household did not agree to answer, other cash receipts, support, assistance, and relief from domestic sources should be blank.
(
  cv_h3k_other_notblank <- section_h %>% 
    filter(h03en_other == 2, !is.na(h3k_other)) %>%
  select_cv(h03en_other, h3k_other, h = c('h03en_other', 'h3k_other'))
)[[1]]


### H03L - Dividend from investments is blank/invalid

## If the household agreed to answer, other cash receipts, support, assistance, and relief from domestic sources should not be blank and should be in the valueset.
(
  cv_h3l_dividend_blank <- section_h %>% 
    filter(h03en_dividend == 1, !(h3l_dividend %in% c(0:10000000))) %>% 
    select_cv(h03en_dividend, h3l_dividend, h = c('h03en_dividend', 'h3l_dividend'))
)[[1]]


### H03L - Dividend from investments must be blank

## If the household did not agree to answer, other cash receipts, support, assistance, and relief from domestic sources should be blank.
(
  cv_h3l_other_notblank <- section_h %>% 
    filter(h03en_dividend == 2, !is.na(h3l_dividend)) %>%
  select_cv(h03en_dividend, h3l_dividend, h = c('h03en_dividend', 'h3l_dividend'))
)[[1]]


### H03M - Rentals received from non-agricultural lands, buildings, spaces, and other properties is blank/invalid

## If the household agreed to answer, rentals received from non-agricultural lands, buildings, spaces, and other properties should not be blank and should be in the valueset.
(
  cv_h3m_rentals_blank <- section_h %>% 
    filter(h03en_rentals == 1, !(h3m_rentals %in% c(0:10000000))) %>% 
    select_cv(h03en_rentals, h3m_rentals, h = c('h03en_rentals', 'h3m_rentals'))
)[[1]]


### H03M - Rentals received from non-agricultural lands, buildings, spaces, and other properties is not blank

## If the household did not agree to answer, rentals received from non-agricultural lands, buildings, spaces, and other properties should be blank.
(
  cv_h3m_rentals_notblank <- section_h %>% 
    filter(h03en_rentals == 2, !is.na(h3m_rentals)) %>%
  select_cv(h03en_rentals, h3m_rentals, h = c('h03en_rentals', 'h3m_rentals'))
)[[1]]


### H03N - Interests (Interest from bank deposits, interest from loans extended to other families) is blank/invalid

## If the household agreed to answer, interests (interest from bank deposits, interest from loans extended to other families) should not be blank and should be in the valueset.
(
  cv_h03n_interests_blank <- section_h %>% 
    filter(h03en_interests == 1, !(h3n_interests %in% c(0:10000000))) %>% 
    select_cv(h03en_interests, h3n_interests, h = c('h03en_interests', 'h3n_interests'))
)[[1]]


### H03N - Interests (Interest from bank deposits, interest from loans extended to other families) 

## If the household did not agree to answer, interests (interest from bank deposits, interest from loans extended to other families) should be blank.
(
  cv_h03n_interests_notblank <- section_h %>% 
    filter(h03en_interests == 2, !is.na(h3n_interests)) %>%
  select_cv(h03en_interests, h3n_interests, h = c('h03en_interests', 'h3n_interests'))
)[[1]]



### H03O - Gifts received by the family (in kind) is blank/invalid

## If the household agreed to answer, gifts received by the family (in kind) should not be blank and should be in the valueset.
(
  cv_h3o_gifts_blank <- section_h %>% 
    filter(h03en_gifts == 1, !(h3o_gifts %in% c(0:10000000))) %>% 
    select_cv(h03en_gifts, h3o_gifts, h = c('h03en_gifts', 'h3o_gifts'))
)[[1]]


### H03O - Gifts received by the family (in kind) is not blank

## If the household did not agree to answer, gifts received by the family (in kind) should be blank.
(
  cv_h3o_gifts_notblank <- section_h %>% 
    filter(h03en_gifts == 2, !is.na(h3o_gifts)) %>%
  select_cv(h03en_gifts, h3o_gifts, h = c('h03en_gifts', 'h3o_gifts'))
)[[1]]


### H03P - Family sustenance activities is blank/invalid

## If the household agreed to answer, family sustenance activities should not be blank and should be in the valueset.
(
  cv_h03p_fsa_blank <- section_h %>% 
    filter(h03en_fsa == 1, !(h3p_fsa %in% c(0:10000000))) %>% 
    select_cv(h03en_fsa, h3p_fsa, h = c('h03en_fsa', 'h3p_fsa'))
)[[1]]


### H03P - Family sustenance activities is not blank

## If the household did not agree to answer, family sustenance activities should be blank.
(
  cv_h03p_fsa_notblank <- section_h %>% 
    filter(h03en_fsa == 2, !is.na(h3p_fsa)) %>%
  select_cv(h03en_fsa, h3p_fsa, h = c('h03en_fsa', 'h3p_fsa'))
)[[1]]


### H03P - No sustenance activity (F01) but with answer is greater than zero

## If the household is not engaged in any sustenance activity, answer for H03P must be zero.
(
  cv_h03p_v_f01 <- section_h %>% 
    left_join(from_section_f, by = 'case_id') %>% 
    filter(with_sa == 0, h03en_fsa == 1, h3p_fsa > 0) %>% 
    select_cv(f01_foodconsum_fct, h03en_fsa_fct, h3p_fsa)
)[[1]]


### H03Z - Amount for other sources of income is blank

## Income amount must be greater than 0 if 'Other' income is specified.
(
  cv_h03z_others1_blank <- section_h %>% 
    select(1:5, ean, everything()) %>% 
    gather_other_income() %>% 
    mutate(other = ifelse(other == 'NA' | other == 'N/A', NA, other)) %>% 
    filter(!is.na(other), is.na(amount)) %>% 
    rename(
      'Other income' = 7,
      'Income from other source' = 8
    ) %>% 
    select_cv(`Other income`, `Income from other source`, h = c('Other income', 'Income from other source'))
)[[1]]


### H03Z - Amount for other sources of income is blank

## Other source of income must be specified if amount declared for other source is greater than 0.
(
  cv_h03z_others1_blank <- section_h %>% 
    select(1:5, ean, everything()) %>% 
    gather_other_income() %>% 
    mutate(other = ifelse(other == 'NA' | other == 'N/A', NA, other)) %>% 
    filter(is.na(other), amount > 0) %>% 
    rename(
      'Other income' = 7,
      'Income from other source' = 8
    ) %>% 
    select_cv(`Other income`, `Income from other source`, h = c('Other income', 'Income from other source'))
)[[1]]



### H04 - Total Annual Income (Current Family Members) is blank

## Since H04 is autocomputed, this field must not be blank.
(
  cv_h04_totannualinc <- section_h %>% 
    filter(is.na(h4a_cfincome)) %>% 
    select_cv(h4a_cfincome)
)[[1]]


### H05 - Income of former family members is blank/invalid

## If the household agreed to answer, income of former family members should not be blank and should be in the valueset.
(
  cv_h05en_sourcesofincomea_blank <- section_h %>% 
    filter(h05_sourcesofincome == 1, !(h05en_sourcesofincome %in% c(0:10000000))) %>% 
    select_cv(h05_sourcesofincome, h05_sourcesofincome, h = c('h05_sourcesofincome', 'h05_sourcesofincome'))
)[[1]]


### H05 - Income of former family members is not blank

## If the household did not agree to answer, income of former family members should be blank.
(
  cv_h05_sourcesofincome_notblank <- section_h %>% 
    filter(h05en_sourcesofincome == 2, !is.na(h05_sourcesofincome)) %>%
  select_cv(h05_sourcesofincome, h05en_sourcesofincome, h = c('h05_sourcesofincome', 'h05_sourcesofincome'))
)[[1]]


### H06 - Total Annual Income (Current Family Members and Former Family Members) is blank

## Total Annual Income (Current Family Members and Former Family Members) should have an answer
(
  cv_h6_cfincome <- section_h %>% 
    filter(is.na(h6_cfincome)) %>% 
    select_cv(h6_cfincome, h = 'h6_cfincome')
)[[1]]


### H06 - Sum of all income by item is not equal to the automated total

## Sum of all individual items of income sources must be consistent with automated total income in H06.
(
  cv_h_totals <- section_h %>% 
    mutate(individual_total = rowSums(select(., matches('(h[2-3][a-p]_|h05_sourcesofincome|h3za_).*'), -matches('_fct$')), na.rm = T)) %>% 
    filter(individual_total != h6_cfincome) %>% 
    select_cv(individual_total, h6_cfincome, h = c('individual_total', 'h6_cfincome'))
)[[1]]