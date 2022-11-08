
title_style <- createStyle(
  fontColour = '#07403b',
  textDecoration = 'bold',
  wrapText = T,
  fontSize = 16
)

font_bold <- createStyle(textDecoration = 'bold', valign = 'center')

row_stripes <- createStyle(
  fgFill = '#f1f1f1',
  # textDecoration = 'bold',
  wrapText = TRUE,
  valign = 'center'
)

text_center <- createStyle(halign = 'center')
footnote_style <- createStyle(textDecoration = 'italic', fontSize = 10, wrapText = T)
num_int <- createStyle(numFmt = '#,##0')
num_format <- createStyle(numFmt = '#,##0', indent = 1)
num_float <- createStyle(numFmt = '#,#0.00')
link_style <- createStyle(fgFill = '#fff5f5')

table_style <- createStyle(border = 'TopBottomLeftRight', wrapText = TRUE)

# Set table header style
header_style <- createStyle(
  textDecoration = 'bold', 
  valign = 'center',
  halign = 'center',
  fgFill = '#f1f1f1',
  wrapText = TRUE
)

header_style_first <- createStyle(
  halign = 'left'
)

header_title_style <- createStyle(
  textDecoration = 'bold',
  fontSize = 13,
  valign = 'center'
)