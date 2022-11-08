
refs <- list()

helpers <- paste0(wd_ref_path, '/utils/helpers/', list.files(paste0(wd_ref_path, '/utils/helpers/')))

lapply(helpers, source)

refs <- list()

refs[['psgc']] <- read_xlsx(paste0(wd_ref_path, '/references/psgc.xlsx')) %>% 
  clean_names() %>% 
  select(
    region, 
    province, 
    city_mun = city_municipality, 
    brgy = name,
    geo = correspondence_code
  ) %>% 
  mutate(geo = sprintf('%09d', as.integer(geo))) 

refs[['dictionary']] <- read_xlsx(paste0(wd_ref_path, '/references/dictionary.xlsx')) %>% 
  clean_names() %>% 
  filter(variable != 'SECTION') %>% 
  mutate(value = tolower(variable)) %>% 
  mutate(label = str_remove(label, ':$')) %>% 
  distinct(variable, .keep_all = T)

refs[['sections']] <- read_xlsx(paste0(wd_ref_path, '/references/dictionary.xlsx')) %>% 
  clean_names() %>% 
  filter(variable == 'SECTION') %>% 
  mutate(Section = paste0('Section ', items)) %>% 
  select(Section, label) %>% 
  distinct(Section, .keep_all = T)

ref_invalid_keyword <- '^(none|no|test|na|try|n.\\a\\.|[-]+)$'
ref_invalid_name <- '^(none|no|test|na|try|n.\\a\\.)$'