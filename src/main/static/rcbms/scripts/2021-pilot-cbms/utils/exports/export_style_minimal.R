if(l == 1) {
  tb_d_label <- toupper(tb_d[l])
  
  writeData(
    tb, tb_sheet, tb_data, start_col, 
    start_row + merge_depth, 
    colNames = tb_without_merge_cell, 
    borders = 'all', 
    borderStyle = 'dashed', 
    borderColour = 'gray'
  )
  
  writeData(tb, tb_sheet, tb_d_label, start_col, start_row - 1)
  
} else {
  
  tb_d_label <- tb_d[l]
  
  writeData(tb, tb_sheet, tb_d_label, start_col, start_row - 1)
  writeData(
    tb, tb_sheet, tb_data, start_col, 
    start_row + merge_depth, 
    colNames = tb_without_merge_cell, 
    borders = 'all', 
    borderStyle = 'dashed', 
    borderColour = 'gray', 
    colNames = F
  )
  
  
}

a <- do.call('rbind', ts_04a_age_group_prop) 

b <- rownames(a) %>% tibble() %>% 
  rename(a = 1) %>% 
  separate(a, c('b', 'd'), '\\.', extra = 'merge') %>% 
  bind_cols(a)

# ===================================

ss <- createWorkbook()
addWorksheet(ss, 'a')

cn <- names(ts_04a_age_group_prop)
r <- 2

for(i in 1:length(cn)) {
  if(i == 1) {
    
    c <- names(ts_04a_age_group_prop[[i]]) %>% t
      
    writeData(ss, 'a', c, startRow = 1, borders = 'all', borderColour = 'gray', colNames = F)
    writeData(ss, 'a', cn[i], startRow = 2, borders = 'all', borderColour = 'gray', colNames = F)
    writeData(ss, 'a', ts_04a_age_group_prop[[i]], startRow = r + 1, borders = 'all', borderColour = 'gray', colNames = F)
    r <- r + 1
    
    addStyle(ss, 'a', createStyle(indent = 2), rows = 3:rs, cols = 1, gridExpand = T, stack = T)
    mergeCells(ss, 'a', cols = 1:ncol(ts_04a_age_group_prop[[i]]), rows = 2)
    addStyle(ss, 'a', createStyle(indent = 1, textDecoration = 'bold'), rows = r - 1, cols = 1:ncol(ts_04a_age_group_prop[[i]]), gridExpand = T, stack = T)
    setRowHeights(ss, 'a', rows = r - 1, 25)
    
  } else {
    
    rr <- nrow(ts_04a_age_group_prop[[i]]) - 3
    
    writeData(ss, 'a', cn[i], startRow = r - 1, borders = 'all', borderColour = 'gray', colNames = F)
    writeData(ss, 'a', ts_04a_age_group_prop[[i]], colNames = F, startRow = r,borders = 'all', borderColour = 'gray')
    
    addStyle(ss, 'a', createStyle(indent = 2), rows = r:rr, cols = 1, gridExpand = T, stack = T)
    mergeCells(ss, 'a', cols = 1:ncol(ts_04a_age_group_prop[[i]]), rows = r - 1)
    addStyle(ss, 'a', createStyle(indent = 1, textDecoration = 'bold'), rows = r - 1, cols = 1:ncol(ts_04a_age_group_prop[[i]]), gridExpand = T, stack = T)
    
    setRowHeights(ss, 'a', rows = r - 1, 25)
  }
  
  r <- r + nrow(ts_04a_age_group_prop[[i]]) + 1
  
  
}

addStyle(ss, 'a', createStyle(valign = 'center'), rows = 1:r, cols = 1:5, gridExpand = T, stack = T)
addStyle(ss, 'a', createStyle(indent = 1), rows = 1:r, cols = 2:5, gridExpand = T, stack = T)
setColWidths(ss, 'a', cols = 1:5, c(35, 15, 15, 15, 15))

saveWorkbook(ss, 'a.xlsx', overwrite = T)











