# Create empty workbook
wb <- createWorkbook()
modifyBaseFont(wb, fontName = 'Arial', fontSize = 12)
source('./utils/inconsistencies/style.R')

# =========================================================================
# Summary Sheet
addWorksheet(wb, 'Summary')
writeData(wb, 'Summary', eval_title, startRow = 1)
writeData(wb, 'Summary', eval_area, startRow = 2)
writeData(wb, 'Summary', eval_date, startRow = 3)
writeData(wb, 'Summary', 'Source: DPS2', startRow = 4)
writeData(wb, 'Summary', 'Summary of Cases', startRow = 6)
writeData(wb, 'Summary', 'Total Number of Cases*', startRow = 7, startCol = 1)
writeData(wb, 'Summary', 'Total Number of Cases with Inconsistencies', startRow = 7, startCol = 2)
writeData(wb, 'Summary', hh_count, startRow = 8, startCol = 1)
writeData(wb, 'Summary', length(a_case_wise_count), startRow = 8, startCol = 2)
writeData(wb, 'Summary', '* May include duplicates in the count', startRow = 9, startCol = 1)
writeData(wb, 'Summary', 'Number of Consistency Checks Performed by Section', startRow = 11)
writeData(wb, 'Summary', eval_summary, startRow = 12)

for(index in seq_along(eval_unique_sections)) {
  eval_section_data <- eval_by_section %>% 
    filter(section == eval_unique_sections[index]) %>% 
    select(
      'Sheet Name' = tab_name, 
      'Title' = title,
      'Number of Cases' = count, 
      'Priority' = priority
    )
  
  nrow_s <- nrow(eval_section_data)
  border_s <- start_row + nrow_s
  
  writeData(wb, 'Summary', eval_unique_sections[index], startRow = start_row - 1)
  writeData(wb, 'Summary', eval_section_data, startRow = start_row)
  
  #========================
  addStyle(wb, 'Summary', font_bold, rows = 5, cols = 1, gridExpand = T, stack = T)
  addStyle(wb, 'Summary', font_bold, rows = 11, cols = 1, gridExpand = T)
  addStyle(wb, 'Summary', font_bold, rows = start_row - 1, cols = 1, gridExpand = T, stack = T)
  addStyle(wb, 'Summary', num_format, rows = 8, cols = 1:2, gridExpand = T, stack = T)
  addStyle(wb, 'Summary', table_style, rows = 7:8, cols = 1:2, gridExpand = T, stack = T)
  addStyle(wb, 'Summary', table_style, rows = start_row:border_s, cols = 1:4, gridExpand = T, stack = T)
  addStyle(wb, 'Summary', header_style, rows = 7, cols = 1:2, gridExpand = T, stack = T)
  addStyle(wb, 'Summary', header_style, rows = start_row, cols = 1:4, gridExpand = T, stack = T)
  addStyle(wb, 'Summary', text_center, rows = start_row:border_s, cols = 4, gridExpand = T, stack = T)
  
  for (j in seq_along(eval_section_data$`Sheet Name`)) {
    t_name <- eval_section_data$`Sheet Name`[j]
    if(eval_section_data$`Number of Cases`[j] > 0) {
      addStyle(wb, 'Summary', link_style, rows = start_row + j, cols = 1:4, gridExpand = T, stack = T)
      writeFormula(
        wb, 'Summary',
        startCol = 1,
        startRow = start_row + j,
        x = makeHyperlinkString(sheet = t_name, text = t_name)
      )
    }
  }
  start_row <- start_row + nrow_s + 3
}

addStyle(wb, 'Summary', title_style, rows = 1, cols = 1, gridExpand = T, stack = T)
addStyle(wb, 'Summary', header_style, rows = 12, cols = 1:6, gridExpand = T, stack = T)
addStyle(wb, 'Summary', table_style, rows = 12:border_summary, cols = 1:6, gridExpand = T, stack = T)
addStyle(wb, 'Summary', footnote_style, rows = 9, cols = 1, gridExpand = T, stack = T)

setColWidths(wb, 'Summary', cols = 1:2, widths = c(25, 75))
setColWidths(wb, 'Summary', cols = 3:6, widths = 12)
mergeCells(wb, 'Summary', cols = 1:6, rows = 1)

# =========================================================================
# Cases with Inconsistencies Sheet
addWorksheet(wb, 'Cases with Inconsistencies')
writeData(wb, 'Cases with Inconsistencies', 'List of Cases with Inconsistencies', startRow = 1)
writeData(wb, 'Cases with Inconsistencies', eval_area, startRow = 2)
writeData(wb, 'Cases with Inconsistencies', eval_date, startRow = 3)
writeDataTable(wb, 'Cases with Inconsistencies', a_case_wise, startRow = 5)

addStyle(wb, 'Cases with Inconsistencies', title_style, rows = 1, cols = 1, gridExpand = T, stack = T)
addStyle(wb, 'Cases with Inconsistencies', text_center, rows = 6:nrow_cases, cols = 2:4,  gridExpand = T, stack = T)

setColWidths(wb, 'Cases with Inconsistencies', cols = 1:7, widths = c(32, 10, 10, 10, 28, 75, 35))
mergeCells(wb, 'Cases with Inconsistencies', cols = 1:7, rows = 1)

# if(generate_all == T) {
  # ========================================================================
  # Itemized Sheet for the List of Cases with Inconsistencies 
  for(index in seq_along(ref_output$tab_name)) {
    
    data <- eval(as.name(paste((ref_output$variable_name)[index]))) %>% 
      select(
        'Case ID' = contains('case_id'), 
        'Pilot Area' = contains('pilot_area'),
        everything()
      ) %>% 
      mutate(
        Justification = '',
        Remarks = ''
      )
  
    tab_name <- ref_output$tab_name[index]
    output_dim <- dim(data)
    ncols <- as.double(output_dim[2])
    nrows <- as.double(output_dim[1]) + 4
    if(is.na(ref_output$description[index])) {
      description <- '*'
    } else {
      description <- paste0('INSTRUCTION: ', ref_output$description[index])
    }
    
    # Create tabs per inconsistency check
    addWorksheet(wb, ref_output$tab_name[index])
    
    # Save title per tab
    writeData(wb, tab_name, ref_output$title[index], startRow = 1) 
    
    # Save description per tab
    writeData(wb, tab_name, description, startRow = 2)
  
    # Save case IDs with inconsistencies
    writeDataTable(wb, tab_name, data, startRow = 4)
    
    addStyle(wb, tab_name, title_style, rows = 1, cols = 1)
    # addStyle(wb, tab_name, table_style, rows = 5:nrows, cols = 1:ncols, gridExpand = T, stack = T)
    
    setColWidths(wb, tab_name, cols = 1:2, widths = 32)
    setColWidths(wb, tab_name, cols = 3:ncols, widths = 20)
    mergeCells(wb, tab_name, cols = 1:ncols, rows = 1)
    
    freezePane(wb, tab_name, firstActiveRow = 5)
  }
# }

saveWorkbook(wb, file = export_path, overwrite = TRUE)


print(paste0(
  'Done processing inconsistencies for ', eval_area, 
  '. The exported file is located at: hpq_r/',
  new_dir, ' folder'
))
