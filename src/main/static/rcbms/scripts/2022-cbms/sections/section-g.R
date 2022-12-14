
# Section G {.unnumbered}

ref_hh_count <- hpq$section_a %>% 
  collect() %>% 
  count(case_id)

ref_hhmem_age <-  hpq$section_a %>% 
  select(case_id, line_number_id, a01_hhname, age) %>% 
  collect() %>% 
  left_join(ref_hh_count, by = 'case_id') %>% 
  select(-case_id)

section_g_new <- hpq$section_g_new %>% collect()

section_f <- hpq$section_f %>% 
  collect() %>% 
  filter_at(vars(matches('^f0[1-3]_.*')), any_vars(!is.na(.))) %>%
  select(
    case_id, 
    f01_foodconsum,
    f02_afishing, 
    f02_dfarming, 
    f02_eraising, 
    f03_crop, 
    f03_livestock, 
    f03_fish,
    f01_foodconsum_fct,
    f02_afishing_fct, 
    f02_dfarming_fct, 
    f02_eraising_fct, 
    f03_crop_fct, 
    f03_livestock_fct, 
    f03_fish_fct
  )

section_g <- section_g_new %>% 
  collect() %>% 
  left_join(section_f, by = 'case_id')

section_g01_10 <- hpq$section_g1_new %>% 
  select(1:13, matches('^g(4a|[5-9]_|0[1-4])')) %>% 
  collect() %>% 
  filter_at(vars(matches('^g(4a|[5-9]a_|0[1-4])')), any_vars(!is.na(.))) %>% 
  left_join(dplyr::select(section_g_new, case_id, g01_agriact, g01_agriact_fct, g02_numprcl), by = 'case_id') %>% 
   mutate(
      g8_prclarea = as.double(g8_prclarea),
      g8_prclarea2 = as.double(g8_prclarea2)
    )

section_g11_19 <- hpq$section_g1_new %>% 
  select(case_id, matches('^g1[1-9].*')) %>% 
  collect() %>% 
  filter_at(vars(matches('^g1[1-9].*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
  left_join(dplyr::select(section_g, 1:13, matches(c('^f', '^g[0-1]\\d'))), by = 'case_id') %>% 
  mutate(
    line_number_id = if_else(
      is.na(g11_lno), '', 
      paste0(case_id, paste0(sprintf('%02d', as.integer(g11_lno))))
    )
  ) %>% 
  na_if('') %>% 
  left_join(ref_hhmem_age, by = 'line_number_id') %>% 
  select(case_id, region, province, city_mun, brgy, ean, a01_hhname, age, g11_lno, everything())

gather_g18_org <- function(data) {
  df <- list()
  for(i in 1:10) {
    df[[i]] <- data %>%
      select(1:12, matches(paste0('^g18_agriorg', i, '$')), matches(paste0('^g18b_agriorgoth', i, '$'))) %>%
      rename(org = 13, org_name = 14) %>%
      mutate(n = i)
  }
  return(do.call('rbind', df) %>% tibble())
}


### G01 - Answer in G01 is blank/not in valueset

## Operator in Agricultural Activity should not be blank.
(
  cv_g01_agriact_blank <- section_g %>% 
    filter_at(vars(matches('^f0[2-3]'), -contains('fish'), -matches('_fct$')), any_vars(. == 1)) %>% 
    filter(f01_foodconsum == 1, !(g01_agriact %in% c(1:3))) %>% 
    select_cv(f01_foodconsum_fct, f02_dfarming_fct, f02_eraising_fct, f03_crop_fct, f03_livestock_fct, g01_agriact_fct, h = 'g01_agriact_fct')
)[[1]]


### G01 - Must be blank since answered 'No' in F02A, F02B, F03D, and F03E

## If the HH is not engaged in any HH sustenance activity in farming, gardening (F02D = 2), raising livestock and poultry (F02E = 2) and any in HH entrepreneurial activity in crop farming and gardening (F03A = 2), livestock and poultry raising (F03B = 2) then G01 should have no answer
(
  cv_g01_agriact_wskipping <- section_g %>% 
    filter_at(vars(matches('^f0[2-3]'), -contains('fish'), -matches('_fct$')), all_vars(. == 2)) %>% 
    filter(f01_foodconsum == 2, !is.na(g01_agriact)) %>% 
    select_cv(f01_foodconsum_fct, f02_dfarming_fct, f02_eraising_fct, f03_crop_fct, f03_livestock_fct, g01_agriact_fct, h = 'g01_agriact_fct')
)[[1]]


### G02 - Answer in G02 is not blank but G01 is 2 or 3.

## If G01 = 2 or G01 = 3 then G02 should not have an answer.
(
  cv_g02_numprcl_wval <- section_g %>% 
    filter(g01_agriact %in% c(2, 3) , !is.na(g02_numprcl)) %>% 
    select_cv(g01_agriact_fct, g02_numprcl, h = 'g02_numprcl')
)[[1]]


### G02 - Answer in G02 is blank/not in valueset

## If the answer in G01 = 1 then G02 should not be blank/invalid.
(
  cv_g02_numprcl_blank <- section_g %>% 
    filter(g01_agriact == 1, !(g02_numprcl %in% c(1:99))) %>% 
    select_cv(g01_agriact_fct, g02_numprcl, h = 'g02_numprcl')
)[[1]]


### G02 - Number of parcel vs listed parcel

## Number of parcel declared should be consistent with the total parcel listed.
(
  cv_g02_parcel_n <- section_g01_10 %>% 
    count(case_id, name = 'Listed') %>% 
    left_join(dplyr::select(section_g_new, 1:13, g02_numprcl), by = 'case_id') %>% 
    filter(Listed != g02_numprcl) %>% 
    select_cv(g02_numprcl, Listed, h = c('g02_numprcl', 'Listed'))
)[[1]]


### G03 - Missing/invalid parcel location

## If the answer in G01 = 1 then G02 and G03 should not be blank.
(
  cv_g03_prclloc_blank <- section_g01_10 %>% 
    filter(g01_agriact == 1, g02_numprcl > 0, !(g03_prclloc %in% c(1:3))) %>% 
    distinct() %>%
    select_cv(g01_agriact_fct, g02_numprcl, g03_prclloc_fct, h = 'g03_prclloc_fct')
)[[1]]


### G03 - Missing/invalid activity done in the parcel

## If the answer in G01 = 1, G02 is in the valueset (G02 = 1:99), and G03 = 1:3, then G03.1 should not be blank.
(
  cv_g03_1_prclactivity_blank <- section_g01_10 %>% 
    filter(g01_agriact == 1, g02_numprcl %in% c(1:99), !(g03_1_prclactivity %in% c(1:3))) %>% 
    distinct() %>%
    select_cv(g01_agriact_fct, g02_numprcl, g03_1_prclactivity_fct)
)[[1]]


### G04 - Missing/inavlid status of parcel

## If G01 = 1 and G02 is in the valueset (1:99) then G04 should not be blank.
(
  cv_g04_prcltenure_blank <- section_g01_10 %>% 
    filter(g01_agriact == 1, g02_numprcl %in% c(1:99), !(g04_prcltenure %in% c(1:8, 98, 99))) %>% 
    select_cv(g01_agriact_fct, g02_numprcl, g04_prcltenure_fct)
)[[1]]


### G04 - Blank specify field of other type of tenure status if selected answer in G04 = 99.

## If G04 = 99 (Others), Others Specify field must not be blank. Others specify field must have an entry if G04 = 99.
(
  cv_g04_prcltenure_oblank <- section_g01_10 %>% 
    filter(g01_agriact == 1, g02_numprcl %in% c(1:99), g04_prcltenure == 99, is.na(g4a_prcltenureoth)) %>% 
    distinct() %>%
    select_cv(g01_agriact_fct, g02_numprcl, g04_prcltenure_fct, g4a_prcltenureoth, h = 'g4a_prcltenureoth')
)[[1]]


### G05 - Not applicable since G3.1 is 'No'

## If the answer in G3.1 is 2 (livestock and poultry) then G05 to G07 should be blank.
(
  cv_g5_irri_wskipping <- section_g01_10 %>% 
    filter(g01_agriact == 1, g02_numprcl %in% c(1:99), g03_1_prclactivity == 2) %>%
    filter_at(vars(matches('^g[5-7]_')), any_vars(!is.na(.))) %>% 
    select_cv(g03_1_prclactivity_fct, matches('^g[5-7]_.*fct$'))
)[[1]]


### G05 - Missing/invalid for irrigation

## If the answer in G03.1 = 1 (crop farming) or G03.1 = 3 (both crop farming and livestock and poultry) then G05 should no be blank.
(
  cv_g5_irri_blank <- section_g01_10 %>% 
    filter(g03_1_prclactivity %in% c(1,3), !(g5_irri %in% c(1, 2, 8))) %>% 
    select_cv(g03_1_prclactivity_fct, g5_irri_fct, h = 'g5_irri_fct')
)[[1]]


### G06 - Not applicable since G05 is 2 or 8

## If the answer in G05 = 2 (No) or G05 = 8 (don't know) then G06 should be blank.
(
  cv_g6_irristat_wskipping <- section_g01_10 %>% 
    filter(g01_agriact == 1, g03_1_prclactivity %in% c(1, 3), g5_irri %in% c(2, 8), !is.na(g6_irristat)
    ) %>% 
    select_cv(g03_1_prclactivity_fct, g5_irri_fct, g6_irristat_fct, h = 'g6_irristat_fct')
)[[1]]


### G06 - Missing/invalid irrigation status

## If the answer in G3.1 = 1 (crop farming) or G03.1 = 3 (Both crop farming and livestock and poultry) then G06 should not be blank. 
(
  cv_g6_irristat_blank <- section_g01_10 %>% 
   filter(g01_agriact == 1, g03_1_prclactivity %in% c(1, 3), g5_irri == 1, !(g6_irristat %in% c(1, 2))) %>% 
   select_cv(g01_agriact_fct, g03_1_prclactivity_fct, g5_irri_fct, g6_irristat_fct, h = 'g6_irristat_fct')
)[[1]]


### G07 - Not applicable since G05 is 1 or 8 

## If the answer in G05 = 1 (Yes) or G05 = 8 (Don't know) then G07 should be blank.
(
  cv_g7_rainfed_wskipping <- section_g01_10 %>% 
   filter(g01_agriact == 1, g03_1_prclactivity %in% c(1, 3), g5_irri %in% c(1, 8), !is.na(g7_rainfed)) %>% 
   select_cv(g01_agriact_fct, g03_1_prclactivity_fct, g5_irri_fct, g7_rainfed_fct, h = 'g7_rainfed_fct')
)[[1]]


### G07 - Missing/invalid (upland/lowland)

## If the answer in G05 = 2 (No) then G07 should not be blank or invalid
(
  cv_g7_rainfed_blank <- section_g01_10 %>% 
   filter(g01_agriact == 1, g03_1_prclactivity %in% c(1, 3), g5_irri == 2, !(g7_rainfed %in% c(1, 2))) %>% 
   select_cv(g01_agriact_fct, g03_1_prclactivity_fct, g5_irri_fct, g7_rainfed_fct, h = 'g7_rainfed_fct')
)[[1]]


### G08 - Missing/invalid physical area of the parcel

## If the answer in G01 = 01 (agricultural land) then g08 should not be blank or invalid.
(
  cv_g8_prclarea_blank <- section_g01_10 %>% 
    filter(
      g01_agriact == 1, g8_prclarea < 0 | 
      g8_prclarea > 100 | g8_prclarea2 < 0 | 
      (is.na(g8_prclarea) & is.na(g8_prclarea2))
    ) %>% 
    distinct() %>%
   select_cv(g01_agriact_fct, g8_prclarea1_fct, g8_prclarea, g8_prclarea2)
)[[1]]


### G09 - Missing/invalid line number

## If the answer in G01 = 1 (agricultural land) then there should be HH members selected in G09.
(
  cv_g9_comanaged_blank <- section_g01_10 %>%
    left_join(ref_hh_count, by = 'case_id') %>% 
    filter(g01_agriact == 1, !grepl('\\d', g9_comanaged) | as.integer(g9_comanaged) < 1 | as.integer(g9_comanaged) > n) %>%
    distinct() %>%
    select_cv(g01_agriact_fct, g03_1_prclactivity_fct, g9_comanaged, h = 'g9_comanaged')
)[[1]]


### G10 - Inconsistence total parcel area

## G10 is the total parcel area of the HH. It should be equal to the sum encoded in G08.

g09_parcel_total <- section_g01_10 %>% 
  group_by(case_id) %>% 
  summarise(
    ha_sum = sum(g8_prclarea, na.rm = T),
    sq = sum(g8_prclarea2, na.rm = T)
  )

(
  cv_g10_total_area_parcel <- section_g %>%
    filter(g01_agriact == 1) %>% 
    select(1:13, g01_agriact_fct, g10_totareaprcl) %>%
    left_join(g09_parcel_total, by = 'case_id') %>% 
    mutate(
      g10_totareaprcl = as.character(g10_totareaprcl),
      ha_sum = as.character(ha_sum)
    ) %>% 
    filter(g10_totareaprcl != ha_sum) %>% 
    select_cv(g01_agriact_fct, g10_totareaprcl, ha_sum, h = c('g10_totareaprcl', 'ha_sum'))
)[[1]]



### G11.1 - Missing/invalid engaged in agri or fishery activities

## If the household has sustenance activity (F02D = 1 and F02E = 1) and/or engaged in entrepreneurial activity (F02A = 1 and F02B = 1 and F02C = 1) then G11.1 should not be blank nand should be in the valueset.
(
  cv_g11_1_hhengage_blank <- section_g %>% 
    filter(
      f01_foodconsum == 1, 
      f02_dfarming == 1 | f02_eraising == 1 | f03_crop == 1 | f03_livestock == 1, 
      g01_agriact %in% c(1:3),
      !(g11_1_hhengage %in% c(1, 2))
    ) %>%
    select_cv(f01_foodconsum_fct, f02_dfarming_fct, f02_eraising_fct, f03_crop_fct, f03_livestock_fct, g01_agriact_fct, g11_1_hhengage, h = 'g11_1_hhengage')
)[[1]]


### G11.1 - Not applicable since household has no household sustenance and entrepreneurial acitivty

## If the household did not engage in household sustenance (F02D = 2 and F02E = 2) and entrepreneurial activity (F02A = 2 and F02B = 2 and F02C = 2) then G11.1 should have no answer.
(
  cv_g11_1_hhengage_wskipping <- section_g %>% 
    filter(
      f01_foodconsum == 2,
      f02_dfarming == 2, 
      f02_eraising == 2, 
      f03_crop == 2, 
      f03_livestock == 2, 
      is.na(g11_1_hhengage)
    ) %>% 
    select_cv(f01_foodconsum, f02_dfarming, f02_eraising, f03_crop, f03_livestock, g11_1_hhengage)
)[[1]]


### G11.2 - Missing/invalid line number of household members 10 years old and over

## If the household only has household sustenance activity (F02D = 1 and F02E = 1) and/or is engaged in agricultural and fishery activity (G11.1 = 1) then G11.2 should not be blank/invalid.
(
  cv_g11_2_agrimem_blank_hhsustenance <- section_g11_19 %>% 
    filter(g11_1_hhengage == 1, age >= 10, as.integer(line_number_id) < 0 | as.integer(line_number_id) > n) %>% 
    select_cv(g11_1_hhengage, g11_lno, h = 'g11_lno')
)[[1]]


### G12 - Missing/invalid type of agri engagement

## If the household is engaged in agricultural and fishery activity (G11.1 = 1) then G12 should not be blank. HH should have selected among the agricultural and fishery acitivty/ies.
(
  cv_g12_agrimain_blank <- section_g11_19 %>%
    filter(g11_1_hhengage == 1, !is.na(line_number_id)) %>%
    filter_at(vars(matches('^g12[a-z]_.*'), -matches('_fct$')), any_vars(!(. %in% c(1, 2)))) %>% 
    select_cv(g11_1_hhengage_fct, g11_lno, matches('^g12[a-z]_.*_fct$'))
)[[1]]


### G12 - Blank specify field of other agricultural and fishery acitivty/ies if the selected answer in G12Z = 1

## If G12Z = 1 (Other agricultural and fishery activity/ies), Others Specify must not be blank. Others specify field must have an entry if G12Z = 1.
(
  cv_g12_agrimain_oblank <- section_g11_19 %>% 
    filter(g11_1_hhengage == 1, g12z_otheragrimain == 1, is.na(g12za_otheragrimain)) %>% 
    select_cv(g11_1_hhengage, g11_lno, g12z_otheragrimain_fct, g12za_otheragrimain, h = 'g12za_otheragrimain')
)[[1]]


### G12 - Answer in G12Z is 'No' but specify field is not blank.

## If G12Z = 2 then specify field should be blank. HH does nit have any other agricultural and fishery activity/ies.
(
  cv_g12_agrimain_notblank <- section_g11_19 %>% 
    filter(g11_1_hhengage == 1, g12z_otheragrimain == 2, !is.na(g12za_otheragrimain)) %>% 
    select_cv(g11_1_hhengage_fct, g11_lno, g12z_otheragrimain_fct, g12za_otheragrimain, h = 'g12za_otheragrimain')
)[[1]]


### G12 - Answer in G12A is 'No' but HH is engaged in farming, gardening, crop farming, and/or gardening

## If household has sustenance activity in farming, gardening (F02D = 1) and/or engaged in entrepreneurial activity in crop farming gardening (F03A = 2), then G12A should be 'Yes'.

#Any YES in F02D and F03A, G12A should be YES
(
  cv_g12a_agrimain_noanswer1 <- section_g11_19 %>% 
    filter(f02_dfarming == 1 | f03_crop == 1, g12a_agrimain_grwcrps == 2) %>% 
    distinct(line_number_id, .keep_all = T) %>% 
    mutate_at(vars(matches('^f0[2-3].*_fct$')), toupper) %>% 
    select_cv(
      g11_lno, 
      f02_dfarming_fct, 
      f03_crop_fct, 
      g12a_agrimain_grwcrps_fct, 
      condition = '1 - YES',
      h = c('f02_dfarming_fct', 'f03_crop_fct', 'g12a_agrimain_grwcrps_fct')
    )
)[[1]]


### G12 - Answer in G12B is NO but HH is engaged in raising livestock and poultry.

## If household has household sustenance activity in raising livestock and poultry (F02E = 1) and/or engaged in entrepreneurial activity in livestock and poultry raising (F03B = 2), then G12B should be YES (= 1).

#Any YES in F02E and F03B, G12B should be YES
(
  cv_g12b_agrimain_noanswer1 <- section_g11_19 %>% 
    filter(f02_eraising == 1 | f03_livestock == 1, g12b_agrimain_lvstckpltry == 2) %>% 
    mutate_at(vars(matches('^f0[2-3].*_fct$')), toupper) %>% 
    select_cv(
      f02_eraising_fct, 
      f03_livestock_fct, 
      g12b_agrimain_lvstckpltry_fct,
      condition = '1 - YES',
      h = c('f02_eraising_fct', 'f03_livestock_fct')
    )
)[[1]]


### G12 - Answer in G12C is NO but HH is engaged in fishing fishery related activity

## If HH has sustenance activity in fishing, gathering shells, snails, seaweeds, corals, etc (F02A = 1) and/or engaged in entrepreneurial activity in fishing (F03C = 2), then G12D, G12D, or G12E should be YES (= 1).

#Any YES in F02A and F03C, G12C should be YES
(
  cv_g12c_agrimain_noanswer1 <- section_g11_19 %>% 
    filter(f02_afishing == 1 | f03_fish == 1) %>%
    filter_at(vars(matches('g12[c-e].*'), -matches('_fct$')), any_vars(. == 2)) %>% 
    mutate_at(vars(matches('^f0[2-3].*_fct$')), toupper) %>%
    select_cv(
      f02_afishing_fct, 
      f03_fish_fct, 
      matches('^g12[c-e].*_fct$'),
      condition = '1 - YES',
      h = c(
        'f02_afishing_fct',
        'f03_fish_fct',
        'g12c_agrimain_aquacltr_fct',
        'g12d_agrimain_fshcptr_fct',
        'g12e_agrimain_gleaning_fct'
      )
    )
)[[1]]


### G13 - Answer in G13 is blank/not in valueset

## If the household is engaged in either growing of crops (G12A = 1) or livestock and poultry (G12B = 1) then G13 should not be blank. G13 asks about the type of engagement in growing of crops or livestock and poultry.

#Any YES in G12A and G12B, G13 should not be blank
(
  cv_g13_typengage_grownlvstck_blank1 <- section_g11_19 %>% 
    filter(g12a_agrimain_grwcrps == 1 | g12b_agrimain_lvstckpltry == 1, !(g13_typengage_grownlvstck %in% c(1:5))) %>% 
    select_cv(
      g12a_agrimain_grwcrps_fct, 
      g12b_agrimain_lvstckpltry_fct, 
      g13_typengage_grownlvstck_fct,
      h = 'g13_typengage_grownlvstck_fct'
    )
)[[1]]


### G13 - Not applicable since G12C-Z are all 'No'

## G13 should be blank since answers in G13C to G13Z are all 'No'.

(
  cv_g14_prodact_na <- section_g11_19 %>% 
    filter_at(vars(matches('^g12[c-fz]_.*'), -matches('_fct$')), all_vars(. == 2)) %>% 
    filter(!is.na(g13_typengage_grownlvstck)) %>% 
    distinct() %>%
    select_cv(
      matches('^g12[c-fz]_.*_fct$'),
      g13_typengage_grownlvstck_fct
    )
)[[1]]


### G14 - Answered 'Yes' in G12A or G12B and G14 is all NO (=2)

## If household is engaged in growing of crops (G12A = 1) and/or engaged in livestock and poultry raising (G12B = 2) then there should be any YES in the production activity/ies (G14). G14 should not be all no (= 2).
(
  cv_g14_prodact_allno1 <- section_g11_19 %>% 
    filter(g12a_agrimain_grwcrps == 1 | g12b_agrimain_lvstckpltry == 1) %>% 
    filter_at(vars(matches('^g14[a-fz]_.*'), -matches('_fct$')), all_vars(. == 2)) %>% 
    select_cv(
      g12a_agrimain_grwcrps_fct, 
      g12b_agrimain_lvstckpltry_fct, 
      matches('^g14[a-fz]_.*_fct$')
    )
)[[1]]


### G14 - Answer 'Yes' G12A = 1 or G12B and G14 is blank/not in valueset

## If household is engaged in growing of crops (G12A = 1) and/or engaged in livestock and poultry raising (G12B = 2) then there should be any YES in the production activity/ies (G14). G14 should not be blank/invalid.
(
  cv_g14_prodact_blank1 <- section_g11_19 %>% 
    filter(g12a_agrimain_grwcrps == 1 | g12b_agrimain_lvstckpltry == 1) %>% 
    filter_at(vars(matches('^g14[a-fz]_.*'), -matches('_fct$')), any_vars(!(. %in% c(1, 2)))) %>% 
    select_cv(g12a_agrimain_grwcrps_fct, g12b_agrimain_lvstckpltry_fct, matches('^g14[a-fz]_.*_fct'))
)[[1]]


### G14A-Z - Not applicable since G12C-Z are all 'No'

## If answered all 'No' in G12C-Z, G14A-Z must be blank.
(
  cv_g14_prodact_na <- section_g11_19 %>% 
    filter_at(vars(matches('^g12[c-fz]_.*'), -matches('_fct$')), all_vars(. == 2)) %>% 
    filter_at(vars(matches('^g14[a-z]_.*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(
      matches('^g12[c-fz]_.*_fct$'),
      matches('^g14[a-z]_.*_fct$')
    )
)[[1]]


### G14Z - Missing entry for specify field

## G14Z must have an entry if answered 'Yes' in G14Z.
(
  cv_g14_agrimain_other <- section_g11_19 %>% 
    filter(g14z_oth == 1, is.na(g14za_oth)) %>% 
    select_cv(g14z_oth_fct, g14za_oth, h = 'g14za_oth')
)[[1]]


### G14Z - Not applicable 

## Specify field must be blank if answered 'No' in G14Z.
(
  cv_g14_agrimain_other_na <- section_g11_19 %>% 
    filter(g14z_oth == 2, !is.na(g14za_oth)) %>% 
    select_cv(g14z_oth_fct, g14za_oth, h = 'g14za_oth')
)[[1]]


### G15 - Answer in G15 is blank/not in valueset

## If the household is engaged in either aquaculture (G12C = 1) or fish capture (G12D = 1) or gleaning (G12E = 1) then G15 should not be blank. G15 asks about the type of engagement in aquaculture or fish capture or gleaning.

#Any YES in G12A and G12B, G15 should not be blank
(
  cv_g15_typengage_aquanfshnglean_blank <- section_g11_19 %>% 
    filter(g12c_agrimain_aquacltr == 1 | g12d_agrimain_fshcptr == 1 | g12e_agrimain_gleaning == 1) %>% 
    filter(!(g15_typengage_aquanfshnglean %in% c(1:5))) %>%
    select_cv(
      g12c_agrimain_aquacltr_fct,
      g12d_agrimain_fshcptr_fct,
      g15_typengage_aquanfshnglean_fct,
      h = 'g15_typengage_aquanfshnglean_fct'
    )
)[[1]]


### G15 - Not applicablle

## If answered all 'No' in G12C to G12E, G15 must be blank.
(
  cv_g15_typengage_aquanfshnglean_wvalues1 <- section_g11_19 %>% 
    filter_at(vars(matches('^g12[c-e]_.*'), -matches('_fct$')), all_vars(. == 2)) %>% 
    filter(!is.na(g15_typengage_aquanfshnglean)) %>% 
    select_cv(
      matches('^g12[c-e]_.*_fct$'), 
      g15_typengage_aquanfshnglean_fct,
      h = 'g15_typengage_aquanfshnglean_fct'
    )
)[[1]]


### G16 - All 'No' but answered at least one 'Yes' in G12C, G12D, G12E

## If the household is engaged in Aquaculture (G12C = 1) or fish capture (G12D = 1) or Gleaning (G12E = 1) then production activity/ies in fishery activity/ies (G16) should not be all NO (= 2).
(
  cv_g16_prodact_allno1 <- section_g11_19 %>% 
    filter_at(vars(matches('^g12[c-e]_.*'), -matches('_fct$')), any_vars(. == 1)) %>% 
    filter_at(vars(matches('^g16[a-jz]_.*'), -matches('_fct$')), all_vars(. == 2)) %>% 
    select_cv(
      matches('^g12[c-e]_.*_fct$'), 
      matches('^g16[a-jz]_.*_fct$')
    )
)[[1]]


### G16 - Blank/not in valueset at least one 'Yes' in G12C, G12D, G12E

## If the household is engaged in Aquaculture (G12C = 1) or fish capture (G12D = 1) or Gleaning (G12E = 1) then production activity/ies in fishery activity/ies (G16) should not be all blank.
(
  cv_g16_prodact_blank1 <- section_g11_19 %>% 
    filter_at(vars(matches('^g12[c-e]_.*'), -matches('_fct$')), any_vars(. == 1)) %>% 
    filter_at(vars(matches('^g16[a-jz]_.*'), -matches('_fct$')), any_vars(!(. %in% c(1, 2)))) %>% 
    select_cv(
      matches('^g12[c-e]_.*_fct$'), 
      matches('^g16[a-jz]_.*_fct$')
    )
)[[1]]


### G16 - Not applicable

## G16A to G15Z must be blank if answered 'No' in G12C to G12E
(
  cv_g16_prodact_blank_na <- section_g11_19 %>% 
    filter_at(vars(matches('^g12[c-e]_.*'), -matches('_fct$')), all_vars(. == 2)) %>% 
    filter_at(vars(matches('^g16[a-jz]_.*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(
      matches('^g12[c-e]_.*_fct$'), 
      matches('^g16[a-jz]_.*_fct$')
    )
)[[1]]


### G16Z - Missing entry for specify field

## If answered 'Yes' in G16Z, specify field must have an entry. 
(
  cv_g16_other <- section_g11_19 %>% 
    filter(g16z_oth == 1, is.na(g16za_oth)) %>% 
    select_cv(g16z_oth_fct, g16za_oth, h = 'g16za_oth')
)[[1]]



### G16Z - Not applicable

## If answered all 'No' in G16Z, specify field must be blank.
(
  cv_g16_other_na <- section_g11_19 %>% 
    filter(g16z_oth == 2, !is.na(g16za_oth)) %>% 
    select_cv(g16z_oth_fct, g16za_oth, h = 'g16za_oth')
)[[1]]



### G17 - Answer in G17 is blank/not in valueset

## If the answered at least one 'Yes' to G12A to G12E then G17 should not be blank.
(
  cv_g17_agriorgmem_blank <- section_g11_19 %>%
    filter_at(vars(matches('^g12[a-e]_.*')), any_vars(. == 1)) %>% 
    filter(!(g17_agriorgmem %in% c(1, 2))) %>% 
    select_cv(matches('^g12[a-e]_.*'), g17_agriorgmem_fct)
)[[1]]


### G17 - Value in G17 but G12F = 1 and G12Z = 2

## If the household is engaged in Renting of agricultural machineries, fishing boats/vessels (G12F = 1) and Other agricultural and fishery activity/ies (G12Z = 1) then G17 should not have an answer.
(
  cv_g17_agriorgmem_wskipping1 <- section_g11_19 %>%
    filter(g12f_agrimain_renting == 1 | g12z_otheragrimain == 1) %>% 
    filter((g17_agriorgmem %in% (c(1, 2)))) %>% 
    select_cv(g12f_agrimain_renting_fct, g12z_otheragrimain_fct, g17_agriorgmem_fct)
)[[1]]


### G18 - Missing/invalid (argi organization)

## G18 must not be blank/invalid if answered 'Yes' in G17.
(
  cv_g18_org_missing <- section_g11_19 %>% 
    select(1:9, g17_agriorgmem, g17_agriorgmem_fct, g18_howmanyorg, matches('^g18')) %>% 
    filter(g17_agriorgmem == 1) %>% 
    gather_g18_org() %>% 
    filter(g18_howmanyorg >= n, is.na(org) | is.na(org_name)) %>% 
    select_cv(g17_agriorgmem_fct, org, org_name, condition = NA, h = c('org', 'org_name'))
)[[1]]


### G18 - Not applicable

## If answered 'No' in G18 (name of agri organization), specify field must be blank.
(
  cv_g18_org_na <- section_g11_19 %>% 
    select(1:9, g17_agriorgmem, g17_agriorgmem_fct, g18_howmanyorg, matches('^g18')) %>% 
    filter(g17_agriorgmem == 2) %>% 
    gather_g18_org() %>% 
    filter(g18_howmanyorg >= n, !is.na(org) | !is.na(org_name)) %>% 
    select_cv(g17_agriorgmem_fct, org, org_name)
)[[1]]



### G19 - Answer in G19 is blank/not in valueset

## If the household is engaged in hydroponics (G01 = 2) then G19 should not be blank and should be in the valueest.
(
  cv_g19_typsyshydro_blank <- section_g11_19 %>%
    filter(g01_agriact == 2, g12e_agrimain_gleaning == 2, g12z_otheragrimain == 2) %>%
    filter_at(vars(matches('^g19[a-fz]_.*'), -matches('_fct$')), any_vars(!(. %in% c(1, 2)))) %>% 
    select_cv(g01_agriact_fct, matches('^g19[a-fz]_.*_fct$'))
)[[1]]


### G19 - Value in G19 but G01 is not enagged in hydroponics

## If the household is not engaged in hydroponics (G01 = 1 or G01 = 3) then G19 should not have an answer.
(
  cv_g19_typsyshydro_wskipping <- section_g11_19 %>%
    filter(g01_agriact %in% c(1, 3)) %>% 
    filter_at(vars(matches('^g19[a-fz]_.*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(g01_agriact_fct, matches('^g19[a-fz]_.*_fct$'))
)[[1]]


### G19Z - Blank specify field of other type of hydroponics system if the selected answer in G19Z = 1

## If G19Z = 1 (other type of hydroponics system), Others Specify must not be blank. Others specify field must have an entry if G19Z = 1.
(
  cv_g19_typsyshydro_oblank <- section_g11_19 %>%
    filter(g01_agriact == 2, g19z_typsyshydro == 1, is.na(g19az_typsyshydrooth)) %>% 
    select_cv(g01_agriact_fct, g19z_typsyshydro_fct, g19az_typsyshydrooth, h = 'g19az_typsyshydrooth')
)[[1]]


### G19Z - Not applicable

## If answered 'No' in G19Z, specify field must be blank.
(
  cv_g19_typsyshydro_other_na <- section_g11_19 %>%
    filter(g01_agriact == 2, g19z_typsyshydro == 2, !is.na(g19az_typsyshydrooth)) %>% 
    select_cv(g01_agriact_fct, g19z_typsyshydro_fct, g19az_typsyshydrooth, h = 'g19az_typsyshydrooth')
)[[1]]


### G24 - Answer in G24 is blank/not in valueset

## If the household engaged in growing of crops (G12A = 1) is continuously engaged in crop farming activity in the last 3 years (G23 = 1) then G24 should not be blank.
(
  cv_g24_hrvest_blank <- section_g %>% 
    filter(g23_crop3yrs == 1, !(g24_hrvest %in% c(1:3))) %>% 
    select_cv(g23_crop3yrs_fct, g24_hrvest_fct, h = 'g24_hrvest')
)[[1]]


### G24 - Answer in G24 must be blank

## If the household is not continuously engaged in crop farming activity (G23 = 2) then G24 should not have an answer.
(
  cv_g24_hrvest_notblank <- section_g %>% 
    filter(g23_crop3yrs == 2, !is.na(g24_hrvest)) %>% 
    select_cv(g23_crop3yrs_fct, g24_hrvest_fct, h = 'g24_hrvest_fct')
)[[1]]


### G25 - Answer in G25 is blank/not in valueset

## If the household is continuously engaged in crop farming activity (G23 = 1), and experienced a decrease in harvest (G24 = 1) then G25 should not be blank.


# Harvest decreased there must be reason for the decrease of harvest
(
  cv_g25_reasondec_blank <- section_g %>% 
    filter(g23_crop3yrs == 1, g24_hrvest == 1, !(g25_reasondec %in% c(1:9, 99))) %>% 
    select_cv(g23_crop3yrs_fct, g24_hrvest_fct, g25_reasondec_fct, h = 'g25_reasondec')
)[[1]]


### G25 - Missing entry for specify field

## If answered 99 in G25, specify field must have an entry.
(
  cv_g25_other <- section_g %>% 
    filter(g23_crop3yrs == 1, g24_hrvest == 1, g25_reasondec == 99, is.na(g25a_reasondecoth)) %>% 
    select_cv(g23_crop3yrs_fct, g24_hrvest_fct, g25_reasondec_fct, g25a_reasondecoth, h = 'g25a_reasondecoth')
)[[1]]


### G25 - Not applicable

## G25 must be blank since G25 is not 99.
(
  cv_g25_other_na <- section_g %>% 
    filter(g23_crop3yrs == 1, g24_hrvest == 1, g25_reasondec != 99, !is.na(g25a_reasondecoth)) %>% 
    select_cv(g23_crop3yrs_fct, g24_hrvest_fct, g25_reasondec_fct, g25a_reasondecoth, h = 'g25a_reasondecoth')
)[[1]]


### G25 - Answer in G25 must be blank

## If the household is continuously engaged in crop farming activity (G23 = 1) but experienced an increase in harvest or the harvest remained the same (G24 = 2 or G24 = 3), then G25 should not have an answer.

# Harvest increase/remain the same, should be blank and skip to G27
(
  cv_g25_reasondec_notblank <- section_g %>% 
    filter(g24_hrvest %in% c(2:3), !is.na(g25_reasondec)) %>% 
    select_cv(g23_crop3yrs_fct, g24_hrvest_fct, g25_reasondec_fct, h = 'g25_reasondec_fct')
)[[1]]


### G26 - Answer in G26 is blank/not in valueset

## If the household is continuously engaged in crop farming activity (G23 = 1), experienced a decrease in harvest (G24 = 1), and the decrease in harvest is due climate-related reasons (G25 = 1:6) then G26 should not be blank.

# Harvest decreased there must be percentage decrease
(
  cv_g26_prcntgedec_blank <- section_g %>% 
    filter(g24_hrvest == 1, g25_reasondec %in% c(1:6), !(g26_prcntgedec %in% c(1:100))) %>% 
    select_cv(g24_hrvest_fct, g25_reasondec_fct, g26_prcntgedec, h = 'g26_prcntgedec')
)[[1]]


### G26 - Answer in G26 must be blank

## If the household experienced a decrease in harvest (G24 = 1), but the decrease is not due to climate-related reasons (G25 = 7:9,99), then G26 should not have an answer.
(
  cv_g26_prcntgedec_notblank <- section_g %>% 
    filter(g25_reasondec %in% c(7:9, 99), !is.na(g26_prcntgedec)) %>% 
    select_cv(g24_hrvest_fct, g25_reasondec_fct, g26_prcntgedec, h = 'g26_prcntgedec')
)[[1]]



### G31 - Answer in G31 is blank/not in the valueset

## If the household member/s is/are livestock and poultry operator (G12B = 1 and G13 = 1) and household is continuously engaged in livestock and poultry raising activty (G30 = 1) then G31 should not be blank.
(
  cv_g31_decrease3yrs_nitv <- section_g %>% 
    filter(g30_lvstckpltry3yrs == 1, !(g31_decrease3yrs %in% c(1:3))) %>% 
    select_cv(g30_lvstckpltry3yrs_fct, g31_decrease3yrs_fct, h = 'g31_decrease3yrs_fct')
)[[1]]


### G31 - Answer in G31 must be blank

## If the household member/s is/are livestock and poultry operator (G12B = 1 and G13 = 1) but is not continuously engaged in livestock and poultry raising activity (G30 = 2) then G31 should be blank.
(
  cv_g31_decrease3yrs_wval <- section_g %>% 
    filter(g30_lvstckpltry3yrs == 2, !is.na(g31_decrease3yrs)) %>% 
    select_cv(g30_lvstckpltry3yrs_fct, g31_decrease3yrs_fct, h = 'g31_decrease3yrs_fct')
)[[1]]


### G32 - Answer in G32 is blank/not in the valueset

## If the household member/s is/are livestock and poultry operator (G12B = 1 and G13 = 1) and experienced decrease in the volume of livestock and poultry production (G31 = 1) then G32 should not be blank.
(
  cv_g32_reasondec_nitv <- section_g %>% 
    filter(g31_decrease3yrs == 1, !(g32_reasondec %in% c(1:6, 9))) %>% 
    select_cv(g31_decrease3yrs_fct, g32_reasondec_fct, h = 'g32_reasondec_fct')
)[[1]]


### G32 - Answer in G32 must be blank

## If the household member/s is/are livestock and poultry operator (G12B = 1 and G13 = 1) but did not experienced a decrease in the volume of livestock and poultry production (G31 = 2:3) then G32 should not have an answer.
(
  cv_g32_reasondec_nitv <- section_g %>% 
    filter(g31_decrease3yrs %in% c(2, 3), !is.na(g32_reasondec)) %>% 
    select_cv(g31_decrease3yrs_fct, g32_reasondec_fct, h = 'g32_reasondec_fct')
)[[1]]


### G32 - Blank specify field of other primary reason for the decrease in livestock and poultry produced if the selected answer in G32 = 9.

## If G32 = 9 (other primary reason for the decrease in livestock and poultry produced), Others Specify must not be blank.
## Others specify field must have an entry if G32 = 9.
(
  cv_g32a_reasondec_oth_nitv <- section_g %>% 
    filter(g31_decrease3yrs == 1, g32_reasondec == 9, is.na(g32a_reasondec_oth)) %>% 
    select_cv(g31_decrease3yrs_fct, g32_reasondec_fct, g32a_reasondec_oth, h = 'g32a_reasondec_oth')
)[[1]]


### G32 - Specify field of other primary reason for the decrease in livestock and poultry produced should be blank.

## If G32 = 1:6, then others Specify must be blank.
(
  cv_g32a_reasondec_oth_nitv_na <- section_g %>% 
    filter(g31_decrease3yrs == 1, g32_reasondec != 9, !is.na(g32a_reasondec_oth)) %>% 
    select_cv(g31_decrease3yrs_fct, g32_reasondec_fct, g32a_reasondec_oth, h = 'g32a_reasondec_oth')
)[[1]]



### G33 - Percentage decrease in the latest livestock and poultry produce must not be blank

## If the household is continuously engaged in livestock and poultry activity (G30 = 1), experienced a decrease in livestock and poultry produce (G31 = 1), and the decrease in livestock and poultry produced is due climate-related reasons (G32 = 1:4) then G33 should not be blank.
(
  cv_g33_prcntgedec_nitv <- section_g %>% 
    filter(
      g31_decrease3yrs == 1, 
      g32_reasondec %in% c(1:4), 
      is.na(g33_prcntgedec) | as.integer(g33_prcntgedec) < 1 | as.integer(g33_prcntgedec) > 100
    ) %>% 
    select_cv(g31_decrease3yrs_fct, g32_reasondec_fct, g33_prcntgedec, h = 'g33_prcntgedec')
)[[1]]


### G33 - Percentage decrease in the latest livestock and poultry produce must be blank

## If the household is continuously engaged in livestock and poultry activity (G30 = 1), experienced a decrease in livestock and poultry produce (G31 = 1), and the decrease in livestock and poultry produced is not due climate-related reasons (G32 = 5:6,9) then G33 should be blank.
(
  cv_g33_prcntgedec_nitv_na <- section_g %>% 
    filter(g31_decrease3yrs == 1, g32_reasondec %in% c(5, 6, 9), !is.na(g33_prcntgedec)) %>% 
    select_cv(g31_decrease3yrs_fct, g32_reasondec_fct, g33_prcntgedec, h = 'g33_prcntgedec')
)[[1]]