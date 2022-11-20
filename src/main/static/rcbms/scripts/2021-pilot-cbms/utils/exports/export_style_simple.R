n_rows <- nrow(tb_data) + start_row
n_cols <- ncol(tb_data) + start_col - 1
n_cols_less <- n_cols - 1
row_range <- start_row:n_rows
col_range <- start_col:n_cols
tb_without_merge_cell <- TRUE
merge_depth <- 0
merge_depth_h <- 0
start_row_header <- start_row

# ============================================================================== #
# Write data into a table
# ============================================================================== #
source('./utils/exports/export_merge.R')

writeData(tb, tb_sheet, tb_d_label, start_col, start_row - 1)
writeData(
  tb, tb_sheet, tb_data, start_col, 
  start_row + merge_depth, 
  colNames = tb_without_merge_cell, 
  borders = 'all', 
  borderStyle = 'dashed', 
  borderColour = 'gray'
)

# ============================================================================== #
# Formatting and Styling
# ============================================================================== #
# Main title
addStyle(tb, tb_sheet, table_main_title, 2, start_col, TRUE, TRUE)
addStyle(tb, tb_sheet, table_back_button, 1, start_col, TRUE, TRUE)

# table row (horizontal only)
addStyle(tb, tb_sheet, table_horizontal_line_inner, row_range, col_range, TRUE, TRUE)

# Table subtitle/sub-category
addStyle(tb, tb_sheet, table_item_center_bold, start_row - 1, start_col, TRUE, TRUE)

# Outer borders
addStyle(tb, tb_sheet, table_border_right_outer, row_range, n_cols, TRUE, TRUE)
addStyle(tb, tb_sheet, table_border_left_outer, row_range, start_col, TRUE, TRUE)
addStyle(tb, tb_sheet, table_border_bottom_outer, n_rows, col_range, TRUE, TRUE)


addStyle(tb, tb_sheet, table_border_bottom_double_inner, start_row + merge_depth_h, col_range, TRUE, TRUE)

# Header format and alignment
addStyle(tb, tb_sheet, table_header, start_row, col_range, TRUE, TRUE)
addStyle(tb, tb_sheet, table_header_fill, start_row_header, col_range, TRUE, TRUE)
addStyle(tb, tb_sheet, table_vertical_line_inner, start_row_header, 3:n_cols_less, TRUE, TRUE)
addStyle(tb, tb_sheet, table_header_align_center, start_row_header, 3:n_cols, TRUE, TRUE)

# ============================================================================== #
# Row Heights
# ============================================================================== #
setRowHeights(tb, tb_sheet, 1, 20)
setRowHeights(tb, tb_sheet, 2, 35)
setRowHeights(tb, tb_sheet, row_range, 20)
setRowHeights(tb, tb_sheet, start_row - 1, 25)

if(tb_without_merge_cell == FALSE) {
  setRowHeights(tb, tb_sheet, start_row, 24)
  
  if(is.na(row_height_header)) {
    row_height_header <- 28
  } 
  
  row_hh_start <- start_row + 1
  row_hh_end <- start_row + merge_depth_h
  
  
  setRowHeights(tb, tb_sheet, row_hh_start:row_hh_end, eval(parse(text = row_height_header)))
} else {
  
  if(is.na(row_height_header)) {
    row_height_header <- 38
  } 
  
  setRowHeights(tb, tb_sheet, start_row, row_height_header)
}

if(is.na(row_reset_last)) {
  setRowHeights(tb, tb_sheet, n_rows, 25)
  addStyle(tb, tb_sheet, table_border_top_double_inner, n_rows, col_range, TRUE, TRUE)
}