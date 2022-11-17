
# Export config ----------------------------------------------------------------
library(tidyverse)
library(openxlsx)
library(readxl)
library(lubridate)
library(janitor)

source('./utils/exports/export-config.R')

# Initializing empty workbook --------------------------------------------------

wb <- createWorkbook()
modifyBaseFont(wb, fontName = 'Arial', fontSize = 12)

source('./utils/exports/export-facade.R')
source('./utils/exports/export-summary.R')
source('./utils/exports/export-log.R')

# Cases with inconsistencies sheet ---------------------------------------------

sheet_2 <- 'Cases with Inconsistencies'
addWorksheet(wb, sheet_2)

nrow_cases <- nrow(exp_case_wise) + 5

exp_case_wise_write <- exp_case_wise %>% 
  filter(!is.na(`Case ID`)) %>% 
  arrange(`Case ID`) 

writeData(wb, sheet_2, 'List of Cases with Inconsistencies', startRow = 1)
writeData(wb, sheet_2, eval_date, startRow = 2)
writeData(wb, sheet_2, eval_check_mode, startRow = 3)
writeDataTable(wb, sheet_2, exp_case_wise_write, startRow = 5)

addStyle(wb, sheet_2, title_style, 1, 1, T, T)
addStyle(wb, sheet_2, text_center, 6:nrow_cases, 5:7, T, T)
setColWidths(wb, sheet_2, 1:14, c(30, 25, 20, 20, 10, 10, 10, 10, 15, 50, 80, 0, 10, 35))
setColWidths(wb, sheet_2, 12, 0, hidden = T)
mergeCells(wb, sheet_2, cols = 1:7, rows = 1)

# 
# writeData(wb, sheet_2, 'Corrected', startCol = 27, startRow = 1)
# writeData(wb, sheet_2, 'Justified', startCol = 27, startRow = 2)
# writeData(wb, sheet_2, 'Pending', startCol = 27, startRow = 3)
# setColWidths(wb, sheet_2, cols = 27, hidden = T)
# 
# dataValidation(
#   wb, 
#   sheet_2, 
#   col = 11, 
#   rows = 6:nrow_cases, 
#   operator = 'equal',
#   type = 'list', 
#   value = "'sheet_2'!$AA$1:$AA$3"
# )


# Saving workbook --------------------------------------------------------------
saveWorkbook(wb, file = export_path, overwrite = TRUE)


# Open workbook after saving ---------------------------------------------------

#if(Sys.info()[1] == 'Darwin' || Sys.info()[1] == 'darwin') {
#  utils::browseURL(export_path)
#} else {
#  shell.exec(export_path)
#}
