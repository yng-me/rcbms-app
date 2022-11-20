addWorksheet(tb, 'List of Tables', gridLines = F)
writeData(tb, 'List of Tables', 'List of Tables', 2, 1)
writeData(tb, 'List of Tables', '2021 Pilot Community-Based Monitoring System (CBMS)', 2, 2)


tb_output_summary <- tb_output %>% 
  transmute(
    'Table Number' = table_number,
    'Sheet' = tab_name,
    'Title' = title,
  )

writeData(tb, 'List of Tables', tb_output_summary, 2, 4)

tbs_nrows <- nrow(tb_output_summary) + 4
tbs_ncols <- ncol(tb_output_summary) + 1

for (s in 1:nrow(tb_output_summary)) {
  
  hyperlink <- paste0(tb_output_summary$`Table Number`[s], '. ', tb_output_summary$Sheet[s])
  hyperlink_name <- paste0('Table ', tb_output_summary$`Table Number`[s])

  writeFormula(
    tb, 'List of Tables',
    startCol = 2,
    startRow = 4 + s,
    x = makeHyperlinkString(sheet = hyperlink, text = hyperlink_name)
  )
}

setColWidths(tb, 'List of Tables', 1, 2)
setColWidths(tb, 'List of Tables', 2, 18)
setColWidths(tb, 'List of Tables', 3, 35)
setColWidths(tb, 'List of Tables', 4, 200)

setRowHeights(tb, 'List of Tables', 1, 40)
setRowHeights(tb, 'List of Tables', 4, 30)
setRowHeights(tb, 'List of Tables', 5:tbs_nrows, 20)

addStyle(tb, 'List of Tables', table_main_title, 1, 2, TRUE, TRUE)
addStyle(tb, 'List of Tables', createStyle(indent = 1), 4:tbs_nrows, 2:tbs_ncols, TRUE, TRUE)

# table row (horizontal only)
addStyle(tb, 'List of Tables', table_horizontal_line_inner, 4:tbs_nrows, 2:tbs_ncols, TRUE, TRUE)

# table row (vertical only)
addStyle(tb, 'List of Tables', table_vertical_line_inner, 4:tbs_nrows, 2:tbs_ncols, TRUE, TRUE)

addStyle(tb, 'List of Tables', table_border_right_outer, 4:tbs_nrows, 4, TRUE, TRUE)
addStyle(tb, 'List of Tables', table_border_left_outer, 4:tbs_nrows, 2, TRUE, TRUE)
addStyle(tb, 'List of Tables', table_border_bottom_outer, tbs_nrows, 2:tbs_ncols, TRUE, TRUE)
addStyle(tb, 'List of Tables', table_header, 4, 2:tbs_ncols, TRUE, TRUE)

# Dashed borders
addStyle(tb, 'List of Tables', table_border_bottom_double_inner, 4, 2:tbs_ncols, TRUE, TRUE)

# Header format and alignment
addStyle(tb, 'List of Tables', table_header, 4, 2:4, TRUE, TRUE)
addStyle(tb, 'List of Tables', createStyle(textDecoration = 'bold'), 4, 2:4, TRUE, TRUE)

