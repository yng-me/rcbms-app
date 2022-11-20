eval_title <- 'Data Evaluation Summary for the 2021 Pilot CBMS'

formatted_date <- paste0(
  sprintf('%02d', day(today())), ' ', 
  month(today(), label = TRUE, abbr = FALSE), ' ',
  year(today())
) 


if_else(!dir.exists('output'), dir.create('output', showWarnings = F), F)
if_else(!dir.exists('output/Inconsistencies'), dir.create('output/Inconsistencies', showWarnings = F), F)

new_dir <- paste0('output/Inconsistencies/As of ', formatted_date)

if_else(!dir.exists(new_dir), dir.create(new_dir, showWarnings = F), F)

export_path_temp <- paste0(
  './', new_dir,
  '/List of Cases with Inconsistencies (', 
  eval_area, 
  ') - Generated as of ', 
  formatted_date
)

export_path <- paste0(export_path_temp, '.xlsx')
eval_date <- paste0('As of ', formatted_date)


