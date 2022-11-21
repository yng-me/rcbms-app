
# Reference for GEO-codes (2021 Pilot CBMS)
ref_pilot_areas <- read.xlsx('./references/pilot_ref.xlsx') %>% 
  mutate(
    pilot_area = if_else(prov == 'Benguet', mun, paste0(mun, ', ', prov)), 
    geo = substr(geo, 2, 10)
  ) %>% 
  select(geo, pilot_area, brgy_name = brgy)

ref_brgys <- read.xlsx('./references/cph_ref.xlsx') %>% 
  mutate(brgy_name = str_trim(brgy_name)) %>% 
  inner_join(ref_pilot_areas, by = c('pilot_area', 'brgy_name')) %>% 
  select(pilot_area, brgy_name, geo, pop_count)

ref_areas <- ref_pilot_areas %>% 
  mutate(geo = str_sub(geo, 1, 6)) %>% 
  distinct(pilot_area, .keep_all = T) %>% 
  select(geo, name = pilot_area) %>% 
  arrange(geo)

rm(ref_pilot_areas)

# Reference codes (codebook)
references_list_temp <- list()
ref_data <- "./references/refs.xlsx"
ref_tab_names <- excel_sheets(path = ref_data)

for (c in 1:length(ref_tab_names)) { 
  suppressWarnings(
    references_list_temp[[ref_tab_names[c]]] <- read_excel(
      path = ref_data, 
      sheet = ref_tab_names[c], 
      range = cell_cols("A:C"),
    ) %>% rename(list_name = 1, value = 2, label = 3)
  )
}

ref_codes <- do.call("rbind", references_list_temp) %>% tibble()
rm(references_list_temp, ref_data, ref_tab_names, c)

ip_refs <- read.xlsx('./references/ip_refs.xlsx') %>% 
  mutate(a10_ethnicity = as.integer(code)) %>% 
  select(a10_ethnicity, ip_type) %>% 
  tibble()
