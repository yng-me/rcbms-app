source('./utils/library.R')
source('./utils/references.R')

if(config$covert_to_parquet_first == TRUE) {
  source('./utils/parquet.R')  
}

parquet_files <- list.files('./data/parquet') %>% 
  str_sub(., 1, -9)

hpq_data <- setNames(
  lapply(paste0('./data/parquet/', parquet_files, '.parquet'), open_dataset),
  parquet_files
)

rm(parquet_files)

if(config$pilot_area == 'all') {
  ref_areas_available <- hpq_data$SUMMARY %>% 
    distinct(pilot_area) %>% 
    collect() 
} else {
  ref_areas_available <- hpq_data$SUMMARY %>% 
    distinct(pilot_area) %>% 
    filter(pilot_area == config$pilot_area) %>% 
    collect() 
}

# Labels to be used in the first column of every table disaggregated by area
output_label <- c('Pilot Area', 'Barangay')

# Define set of outputs to be generated
if(config$disaggregation == 'all') {
  output <- c('pilot_area', 'brgy_name')
} else {
  output <- config$disaggregation
}

# Set export settings (defined in the Excel workbook)
# output_mode <- str_remove(config$mode, '^.*_')
output_ref_source <- paste0('table_ref_', str_remove(config$mode, '^.*_'))

if(str_remove(config$mode, '^.*_') == 'output') {
  output_mode <- 'tables'
} else {
  output_mode <- str_remove(config$mode, '^.*_')
}

# Call script based on a defined mode in config
if(config$mode == 'additional_tables') {
  source('./utils/mode/additional_tables.R')
} else if (config$mode == 'generate_inconsistencies_with_output') {
  source('./utils/mode/generate_inconsistencies.R')
} else {
  source(paste0('./utils/mode/', config$mode, '.R'))
}

# Generate MPI 
if(config$generate_mpi == TRUE) {
  source('./scripts/mpi/mpi.R')
}
