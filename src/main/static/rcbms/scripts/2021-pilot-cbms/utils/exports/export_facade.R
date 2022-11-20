table_main_title <- createStyle(
  fontColour = '#07403b',
  textDecoration = 'bold',
  wrapText = T,
  fontSize = 13
)

table_header <- createStyle(
  borderStyle = 'medium',
  border = 'top',
  wrapText = TRUE,
  valign = 'center',
  fgFill = '#f5f5f5'
)

table_header_default <- createStyle(
  borderStyle = 'double',
  borderColour = '#757575',
  border = 'bottom',
  wrapText = TRUE,
  valign = 'center',
  fgFill = '#f5f5f5'
)

table_header_fill <- createStyle(
  fgFill = '#f5f5f5',
  wrapText = TRUE,
  valign = 'center'
)

table_header_align_left <- createStyle(
  halign = 'left'
)

table_header_align_center <- createStyle(
  halign = 'center'
)

# Inner border
table_horizontal_line_inner <- createStyle(
  borderStyle = 'dashed',
  borderColour = '#c7c7c7',
  border = 'TopBottom',
  valign = 'center',
  indent = 1
)

table_vertical_line_inner <- createStyle(
  border = 'LeftRight',
  borderColour = '#b5b5b5',
  valign = 'center'
)

# Outer border
table_border_right_outer <- createStyle(
  border = 'right',
  borderStyle = 'medium'
)

table_border_left_outer <- createStyle(
  border = 'left',
  borderStyle = 'medium'
)

table_border_bottom_outer <- createStyle(
  border = 'bottom',
  borderStyle = 'medium'
)

table_border_bottom_double_inner <- createStyle(
  borderStyle = 'double',
  borderColour = '#757575',
  border = 'bottom'
)

table_border_top_double_inner <- createStyle(
  borderStyle = 'double',
  borderColour = '#c7c7c7',
  border = 'top',
  textDecoration = 'bold'
)

table_first_column <- createStyle(
  halign = 'left',
  wrapText = T
)

table_number_format <- createStyle(
  numFmt = '#,##0'
)

table_decimal_format <- createStyle(
  indent = 1,
  #halign = 'right',
  numFmt = '#,#0.00'
)

table_right <- createStyle(
  indent = 1,
  halign = 'right'
)

table_item_center_bold <- createStyle(
  valign = 'center', 
  textDecoration = 'bold'
)

table_back_button <- createStyle(
  textDecoration = NULL, 
  fontColour = '#07403b',
  fontSize = 9
)

table_footnote <- createStyle(
  fontSize = 8, 
  halign = 'left', 
  indent = 1,
  valign = 'top', 
  fontColour = '#595959',
  #textDecoration = 'italic',
  wrapText = T
)

table_footnote_title <- createStyle(
  fontSize = 9, 
  textDecoration = 'bold'
)
