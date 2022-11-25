
# Libraries --------------------------------------------------------------------

library(tidyverse)
library(yaml)
library(stringi)
library(janitor)
library(readxl)
library(arrow)
library(openxlsx)
library(lubridate)
library(jsonlite)
library(reactable)

# all_reg <- list.files('./data/reg')[17]

config <- read_yaml('config.yml', readLines.warn = F)
if_else(!dir.exists('./data/validation'), dir.create('./data/validation', showWarnings = F), F)

# References -------------------------------------------------------------------

wd_ref_path <- '.'
execMode <- 'before'
if(config$run_after_edit) {
  execMode <- 'after'
}
wd_data_path <- paste0(wd_ref_path, '/data/text/', execMode, '/')

source('./utils/references.R')

ref_files <- as_tibble(
  str_subset(list.files(wd_data_path), '\\.(txt|TXT)$')
) %>% 
  filter(!grepl('NOTE|INTERVIEW_RECORD|CERTIFICATION|SUMMARY_OF_VISIT|SECTION_A', value)) %>% 
  pull(value)

ref_filename <- tolower(str_sub(ref_files, 1, -5))


if(config$use_rdata == T) {
  
  if(Sys.info()[1] == 'Darwin' || Sys.info()[1] == 'darwin') {
    load('./data/hpq.Rdata')
  } else {
    load(config$paths$rdata_path)
  }
  source('./utils/save-record.R')

} else {
  
  if(config$save_by_area == T) {
    
    ref_all_reg <- refs$psgc %>% 
      distinct(region, .keep_all = T) %>% 
      mutate(reg_pscg = as.integer(str_sub(geo, 1, 2))) %>% 
      arrange(reg_pscg)
    
    for(r in 1:nrow(ref_all_reg)) {
      
      hpq <- list()
      reg <- ref_all_reg$region[r]
      reg_psgc <- ref_all_reg$reg_pscg[r]
      
      hpq <- setNames(
        lapply(paste0(wd_data_path, ref_files),  importer_cv, by_reg = reg_psgc),
        ref_filename
      )
      
      print('Done: Household Record')
      
      source('./utils/import-transform.R')
      if(config$append_new_record == T) {
        source('./utils/import-append.R')
      }
      
      wd_data_path <- paste0(wd_ref_path, '/data/text/')
      
      new_dir <- paste0('./data/reg/', reg)
      
      if_else(!dir.exists('./data/reg'), dir.create('./data/reg', showWarnings = F), F)
      if_else(!dir.exists(new_dir), dir.create(new_dir, showWarnings = F), F)
      
      save(hpq, file = paste0(new_dir, '/hpq.Rdata'))
      
      rm(hpq)
      print(paste0('Done: ', reg))
      
    }
  
  } else {
    
    reg_psgc <- NULL
    
    hpq <- setNames(
      lapply(paste0(wd_data_path, ref_files),  importer_cv),
      ref_filename
    )
    
    source('./utils/import-transform.R')
    
    if(config$append_new_record == T) {
      source('./utils/import-append.R')
    }
    wd_data_path <- paste0(wd_ref_path, '/data/text/')
    source('./utils/save-record.R')

  }

}

ref_hh_count <- hpq$section_a %>% 
  count(case_id)
