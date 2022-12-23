get_df <- function(df) eval(as.name(df)) %>% tibble()
logs_path <- paste0(config$paths$output_path, '/Export Logs.xlsx')
ref_exists <- file.exists(logs_path)

ref_as_of_date <- paste0(
  sprintf('%02d', day(today())), ' ', 
  month(today(), label = TRUE, abbr = FALSE), ' ',
  year(today())
)

ref_as_of <- paste0('Number of Cases (',  ref_as_of_date, ')')

ref_cv_all <- exp_eval_summary %>% 
  select(1, 2, 4) %>% 
  rename((!!as.name(ref_as_of)) := 3)

if(ref_exists == TRUE) {
  
  ref_cv_prev <- read.xlsx(logs_path) %>% 
    tibble() %>% 
    rename_all(~ str_replace_all(., '\\.', ' ')) 
  
  ref_last <- names(ref_cv_prev) 
  ref_last_col <- ref_last[length(ref_last)]
  
  if(ref_last_col == ref_as_of) {
    ref_cv_combined <- ref_cv_prev %>% 
      select(-contains(paste0(ref_last_col))) %>% 
      right_join(ref_cv_all, by =  c('Section', 'Title'))
  } else {
    ref_cv_combined <- ref_cv_prev %>%
      right_join(ref_cv_all, by =  c('Section', 'Title'))
  }
  
} else {
  ref_cv_combined <- ref_cv_all
}

ref_cv_combined_distinct <- ref_cv_combined %>%
  distinct(Section, Title, .keep_all = T)

nr <- nrow(ref_cv_combined_distinct) + 1

wl <- createWorkbook()
addWorksheet(wl, ref_as_of_date)
writeData(wl, ref_as_of_date, ref_cv_combined_distinct, borders = 'all')
setColWidths(wl, ref_as_of_date, 1, 13)
setColWidths(wl, ref_as_of_date, 2, 80)
setColWidths(wl, ref_as_of_date, 3:ncol(ref_cv_combined_distinct), 20)
setRowHeights(wl, ref_as_of_date, 1, 40)
setRowHeights(wl, ref_as_of_date, 2:nr, 20)
addStyle(wl, ref_as_of_date, createStyle(halign = 'center'), 1, 2:ncol(ref_cv_combined_distinct), T, T)
addStyle(wl, ref_as_of_date, createStyle(valign = 'center', textDecoration = 'bold', wrapText = T, border = c('top', 'botton', 'left', 'right')), 1, 1:ncol(ref_cv_combined_distinct), T, T)
addStyle(wl, ref_as_of_date, createStyle(indent = 1, fontName = 'Arial', valign = 'center'), 1:nr, 1:ncol(ref_cv_combined_distinct), T, T)

if(ref_exists == TRUE) {
  addStyle(wl, ref_as_of_date, createStyle(fgFill = '#fffbed'), 1:nr, ncol(ref_cv_combined_distinct), T, T)
}

saveWorkbook(wl, logs_path, overwrite = T)