# # # 1. =========================================================================

form3_files <- read.xlsx('./references/waiver_case_id.xlsx')

form_3 <- form3_files %>% 
  mutate(filename = case_id) %>% 
  mutate(case_id = if_else(grepl('^3315', case_id) & pilot_area == 'San Gabriel, La Union', paste0('01', case_id), case_id)) %>%
  mutate(case_id = if_else(grepl('^5542', case_id) & pilot_area == 'Sual, Pangasinan', paste0('01', case_id), case_id)) %>%
  mutate(case_id = if_else(grepl('^3134', case_id) & pilot_area == 'Santa Maria, Isabela', paste0('02', case_id), case_id)) %>%
  mutate(case_id = if_else(grepl('^0812', case_id) & pilot_area == 'Samal, Bataan', paste0('03', case_id), case_id)) %>%
  mutate(case_id = if_else(grepl('^4527', case_id) & pilot_area == 'City of Sipalay, Negros Occidental', paste0('06', case_id), case_id)) %>%
  mutate(case_id = if_else(grepl('^4609', case_id) & pilot_area == 'Dauin, Negros Oriental', paste0('07', case_id), case_id)) %>%
  mutate(case_id = if_else(grepl('^3708', case_id) & pilot_area == 'City of Baybay, Leyte', paste0('08', case_id), case_id)) %>%
  mutate(case_id = if_else(grepl('^0301', case_id) & pilot_area == 'City of Bayugan, Agusan del Sur', paste0('16', case_id), case_id)) %>%
  mutate(case_id = if_else(grepl('^1102', case_id) & pilot_area == 'City of Baguio, Benguet', paste0('14', case_id), case_id)) %>% 
  mutate(case_id = str_sub(case_id, 1, 27))

form_3_valid <- form_3 %>% 
  filter(!grepl('[a-zA-z]', case_id), nchar(case_id) == 27, size >= 13000)

cv_no_sign <- hpq_data$SUMMARY %>%
  filter(pilot_area == eval_area) %>%
  select(case_id, brgy_name, HSN, RESULT_OF_VISIT, RESPO_WAIVER) %>%
  filter(!(case_id %in% form_3_valid$case_id), HSN < 7777, RESPO_WAIVER == 1) %>% 
  collect()

cv_form_3_invalid <- form_3 %>% 
  filter(pilot_area == eval_area) %>%
  filter(!grepl('[a-zA-z]', case_id), nchar(case_id) == 27, size < 13000)

# Duplicate cases
# ref_submission_status <- read.csv('./references/data_submission_status.csv') %>% 
#   filter(pilot_area == eval_area)
# 
# d_completeness <- hpq_individual %>% 
#   mutate(ea = str_sub(case_id, 1, 15)) %>% 
#   select(ea, pilot_area, brgy_name) %>%
#   distinct(ea) %>% 
#   nrow()
# 
# d_ea_count <- ref_submission_status$ea_count
# 
# cv_ea_count <- data.frame(matrix(ncol = 2, nrow = 0)) %>% 
#   tibble() %>% 
#   rename(
#     'Number of EA Processed' = 1, 
#     'Number of EA' = 2
#   )
# 
# if(d_ea_count != d_completeness) {
#   cv_ea_count <- data.frame(d_completeness, d_ea_count) %>% 
#     rename(
#       'Number of EA Processed' = 1, 
#       'Number of EA' = 2
#     )
# } 

# 3. =========================================================================
# List of Cases that do not have data on the no. of household members.
d_no_hhmem <- hpq_data$SUMMARY %>%
  filter(HSN < 7777, RESULT_OF_VISIT == 1) %>%
  compute() %>% 
  nrow()

# 4. =========================================================================
# Check consistency if household count 

d_with_hh_head <- hpq_individual %>%
  filter(RESULT_OF_VISIT == 1, A02RELHEAD == 1) %>% 
  nrow()

cv_hh_head_inconsistent <- data.frame(matrix(ncol = 2, nrow = 0)) %>% 
  tibble() %>% 
  rename(
    'Number of Regular Households' = 1, 
    'Number of Household Heads' = 2
  )

if(d_no_hhmem != d_with_hh_head) {
  cv_hh_head_inconsistent <- data.frame(d_no_hhmem, d_with_hh_head) %>% 
    rename(
      'Number of Regular Households' = 1, 
      'Number of Household Heads' = 2
    )
} 


cv_hhsize_10_and_more <- hpq_individual %>%  
  group_by(pilot_area, brgy_name, case_id) %>%  
  count() %>% 
  filter(n >= 15) %>% 
  ungroup() %>% 
  select(case_id, pilot_area, 'Household Size' = n)

# # 5. =========================================================================
# # If BSN is the same, R01 should also be the same 
# cv_same_bsn_same_r1 <- hpq_data$SUMMARY %>% 
#   filter(BSN < 5555, HSN < 7777) %>% 
#   collect() %>% 
#   mutate(
#     geo_ea = paste0(
#       sprintf("%02d", REGION),
#       sprintf("%02d", PROVINCE),
#       sprintf("%02d", CITY),
#       sprintf("%03d", BARANGAY),
#       sprintf("%06d", EA),
#       sprintf("%04d", BSN)
#     )
#   ) %>% 
#   select(geo_ea, BSN, R1) %>% 
#   group_by(BSN, geo_ea) %>% 
#   nest() %>% 
#   mutate(
#     data = map(data, distinct),
#     count = map_int(data, nrow)
#   ) %>% 
#   filter(count > 1) %>% 
#   unnest(data) %>% 
#   mutate(BSN = sprintf("%04d", BSN)) %>% 
#   select(
#     'REG-PROV-MUN-BRGY-EA Code' = geo_ea, BSN,
#     'R01 (Type of Building)' = R1
#   )
# 

print('Crossed-section complete!')