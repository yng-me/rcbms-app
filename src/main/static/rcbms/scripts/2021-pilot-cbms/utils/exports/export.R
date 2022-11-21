print('Now preparing to export into an Excel format...')

tb <- createWorkbook()
modifyBaseFont(tb, fontName = 'Arial', fontSize = 10)

# =========================================================== #
# Export settings
# =========================================================== #

source('./utils/exports/export_helper.R')
#source('./utils/exports/export_refs.R')
source('./utils/exports/export_config.R')
source('./utils/exports/export_facade.R')

# ============================================================================== #
# Table of Contents
# ============================================================================== #
source('./utils/exports/export_summary.R')

# ============================================================================== #
# Generating Tables
# ============================================================================== #
for(k in 1:nrow(tb_output)) {
  
  start_col <- 2
  start_row <- 5
  
  tb_title <- paste0('Table ', tb_output$table_number[k], '. ', tb_output$title[k])
  
  if(is.na(tb_output$without_by_brgy[k])) {
    tb_title <- paste0(tb_title, d_by)
  }
  
  tb_sheet <- paste0(tb_output$table_number[k], '. ', tb_output$tab_name[k])
  tb_first_col_title <- tb_output$first_col_title[k]
  tb_variable <- tb_output$variable_name[k]
  tb_data_eval <- eval(parse(text = tb_variable))
  
  tb_footnote <- ref_tb$footnote %>% filter(variable_name == tb_variable)
  
  decimal_format <- tb_output$decimal_format[k]
  precision_format <- tb_output$precision[k]
  col_width_all <- tb_output$col_width_all[k]
  col_width_first <- tb_output$col_width_first[k]
  col_width_last <- tb_output$col_width_last[k]
  row_height_header <- tb_output$row_height_header[k]
  row_reset_last <- tb_output$row_reset_last[k]
  
  addWorksheet(tb, tb_sheet, gridLines = F)
  
  writeFormula(
    tb,
    tb_sheet,
    startCol = 2,
    startRow = 1,
    x = makeHyperlinkString(
      sheet = 'List of Tables', 
      text = 'Back'
    )
  )
  
  writeData(tb, tb_sheet, tb_title, start_col, 2)
  
  if(inherits(tb_data_eval, 'list') == TRUE) {
    
    # Subcategory based on list names
    tb_d <- names(tb_data_eval)
    
    for(l in 1:length(tb_d)) {
      
      if(l == 1) {
        tb_d_label <- toupper(tb_d[l])
      } else {
        tb_d_label <- tb_d[l]
      }
      
      tb_data <- tb_data_eval[[l]] %>% rename_na_ts(remove_zero = F)

      source('./utils/exports/export_style_simple.R')

      start_row <- n_rows + 4
      
    }
    
    
  } else {
    
    tb_d_label <- toupper(current_area)
    
    tb_data <- tb_data_eval
    
    if(!is.na(tb_first_col_title)) {
      tb_data <- tb_data_eval %>% 
        rename((!!as.name(tb_first_col_title)) := 1)
    }
    
    tb_data <- tb_data %>% rename_na_ts()

    source('./utils/exports/export_style_simple.R')
    
  }
  
  # Main title
  addStyle(tb, tb_sheet, table_main_title, 2, start_col, TRUE, TRUE)
  addStyle(tb, tb_sheet, table_back_button, 1, start_col, TRUE, TRUE)
  
  # table first column format
  addStyle(tb, tb_sheet, table_first_column, 5:n_rows, start_col, TRUE, TRUE)

  # Number format
  addStyle(tb, tb_sheet, table_number_format, 5:n_rows, 3:n_cols, TRUE, TRUE)
  
  col_number_format <- '#,#0.00'
  
  # Decimal format
  if(!is.na(decimal_format)) {
    
    if(!is.na(precision_format)) {
      precision <- paste0(rep(0, as.integer(precision_format)), collapse = '')
      col_number_format <- paste0('#,#0.', precision)
    }
    
    col_to_decimal <- eval(parse(text = decimal_format)) + 1
    
    addStyle(
      tb, 
      tb_sheet, 
      createStyle(
        indent = 1,
        numFmt = col_number_format
      ), 
      5:n_rows, 
      col_to_decimal,
      TRUE, 
      TRUE
    )
  }
  
    # Conditional format
  tb_cols <- colnames(tb_data)

  
  for(f in 2:length(tb_cols)) {
    if(grepl('[Pp]ercent', tb_cols[f]) == TRUE) {
      col_to_decimal <- f + 1
      
      addStyle(
        tb, 
        tb_sheet, 
        createStyle(
          indent = 1,
          numFmt = col_number_format
        ), 
        5:n_rows, 
        col_to_decimal,
        TRUE, 
        TRUE
      )
    }
    
    if(grepl('[Rr]atio', tb_cols[f]) == TRUE) {
      col_to_decimal <- f + 1
      addStyle(tb, tb_sheet, table_right, 6:n_rows, col_to_decimal, TRUE, TRUE)
    }
  }
  
  
  # ============================================================================== #
  # Column Widths
  # ============================================================================== #
  if(is.na(col_width_all)) {
    col_width_all <- 18
  } else {
    col_width_all <- eval(parse(text = col_width_all))
  }
  
  if(is.na(col_width_first)) {
    col_width_first <- 30
  }
  
  setColWidths(tb, tb_sheet, 1:start_col, 2)
  setColWidths(tb, tb_sheet, start_col, col_width_first)
  setColWidths(tb, tb_sheet, 3:n_cols, col_width_all)
  
  if(!is.na(col_width_last)) {
    setColWidths(tb, tb_sheet, n_cols, col_width_last)
  }
  
  # ============================================================================== #
  # Footnotes
  # ============================================================================== #
  
  f_row_to <- n_rows + 2
  f_row_from <- n_rows + 2
  
  if(nrow(tb_footnote) > 0) {
    if(nrow(tb_footnote) > 1) {
      f_note_label <- 'Notes:'
    } else {
      f_note_label <- 'Note:'
    }
    
    f_start_row <- n_rows + 2
    writeData(tb, tb_sheet, f_note_label, start_col, f_start_row)
    
    for (w in 1:nrow(tb_footnote)) {
      note_indicator <- tb_footnote$indicator[w]
      note_it <- paste0(note_indicator, ' ', tb_footnote$description[w])
      f_row <- f_start_row + w
      writeData(tb, tb_sheet, note_it, start_col, f_row)
      mergeCells(tb, tb_sheet, cols = start_col:n_cols, f_row)
    }
    
    f_row_from <- n_rows + 3
    f_row_to <- f_row_from + nrow(tb_footnote)
  }
  
  f_end <- f_row_to + 2
  
  writeData(
    tb, 
    tb_sheet, 
    'Source: 2021 Pilot Community-Based Monitoring System (CBMS), Philippine Statistics Authority', 
    start_col, 
    f_row_to + 1
  )

  addStyle(tb, tb_sheet, table_footnote, f_row_from:f_row_to, start_col, TRUE, TRUE)
  addStyle(tb, tb_sheet, createStyle(fontSize = 8, textDecoration = c("bold", "italic")), f_row_to + 1, start_col, TRUE, TRUE)
  mergeCells(tb, tb_sheet, col_range, f_row_to + 1)
  mergeCells(tb, tb_sheet, col_range, 2)
}


print('Saving Excel file...')

# ============================================================================== #
# Save as Excel File
# ============================================================================== #
saveWorkbook(tb, export_path, overwrite = T)

print(paste0('Export completed: ', current_area))