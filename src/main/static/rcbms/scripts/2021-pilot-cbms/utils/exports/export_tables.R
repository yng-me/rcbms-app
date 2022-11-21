tidy <- paste0('./utils/tidy/', list.files('./utils/tidy/'))
lapply(tidy, source)

if(config$mode != 'additional_tables') {
  output_filename <- paste0(current_area, ' (Generated as of ', formatted_date, ').xlsx')

  tables <- paste0('./scripts/', output_mode, '/', list.files(paste0('./scripts/', output_mode)))
  lapply(tables, source)
  
  source('./utils/exports/export.R')
}
