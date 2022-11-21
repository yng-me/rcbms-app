library(tidyverse)

wd_ref_path <- '.'

parquet_files <- as_tibble(list.files('./data/parquet')) %>%
  mutate(value = str_sub(value, 1, -9)) %>%
  pull(value)



refs <- list()

refs[['dictionary']] <- readxl::read_xlsx(paste0(wd_ref_path, '/references/dictionary.xlsx')) %>%
  janitor::clean_names() %>%
  filter(variable != 'SECTION') %>% 
  mutate(value = tolower(variable)) %>% 
  mutate(label = str_remove(label, ':$')) %>% 
  distinct(variable, .keep_all = T)

hpq <- setNames(
  lapply(paste0('./data/parquet/', parquet_files, '.parquet'), arrow::open_dataset),
  parquet_files
)

source('./utils/save-dictionary.R')