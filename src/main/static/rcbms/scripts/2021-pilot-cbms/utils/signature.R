form3_path_1 <- list.files(
  path = '/Volumes/CBSD (Bhas)/Data Files/2021 Pilot CBMS/Waiver or Consent Form [not organized]', 
  full.names = T, 
  recursive = T, 
  pattern = '\\d+.*?\\.(jpg|jpeg|png)$'
)

form3_path_2 <- list.files(
  path = '/Volumes/CBSD (Bhas)/Data Files/2021 Pilot CBMS/Waiver or Consent Form', 
  full.names = T, 
  recursive = T, 
  pattern = '\\d+.*?\\.(jpg|jpeg|png)$'
)

form3_files_1 <- file.info(form3_path_1) %>% 
  rownames_to_column(var = 'value') %>% 
  mutate(
    pilot_area = str_remove(str_remove(str_extract(value, '\\d{6} .*, .*?/'), '/'), '\\d{6} '),
    case_id = basename(value)
  ) %>% 
  select(pilot_area, size, case_id)

form3_files <- file.info(form3_path_2) %>% 
  rownames_to_column(var = 'value') %>% 
  mutate(
    pilot_area = str_remove(str_remove(str_extract(value, '\\d{6} .*, .*?/'), '/'), '\\d{6} '),
    case_id = basename(value)
  ) %>% 
  select(pilot_area, size, case_id) %>% 
  bind_rows(form3_files_1) %>% 
  distinct(pilot_area, case_id, .keep_all = T)
  

write.xlsx(form3_files, './references/waiver_case_id.xlsx', overwrite = T)
