m_colnames <- names(tb_data) %>% 
  tibble() %>% 
  rename(name = 1) %>% 
  mutate(n = c(1:nrow(.)))


m_extract <- m_colnames %>% 
  mutate(
    m = if_else(grepl('.*<.*?>', name), 'match', 'unmatch'),
    o = if_else(grepl('.*<.*?>', name), 0, 1),
    #    s = str_extract(name, '\\(.*?\\)'),
    sa = str_extract_all(name, '<.*?>')
  ) %>% 
  mutate(col = map_int(sa, length))

m_with_merge_col <- m_extract %>% 
  summarise(s = sum(col)) %>% 
  pull(s)


if(m_with_merge_col[1] > 0 ) {
    m_col_merge <- m_extract %>% unnest(sa) %>% 
    mutate(
      ss = str_replace(name, '<.*?>', ''),
      sa = str_replace_all(sa, '[<>]', ''),
    ) %>% 
    select(-name) %>% 
    pivot_wider(names_from = m, values_from = col) %>% 
    group_by(sa) %>% 
    summarise(col = paste0('c(', min(n), ':', a = max(n), ')'))
  
  # ========================================================= #
  # Column Merge
  # ========================================================= #
  merge_columns <- m_extract %>% unnest(sa) %>% 
    mutate(
      ss = str_replace(name, '\\s<.*?>', ''),
      sa = str_replace_all(sa, '[<>]', '')
    ) %>% 
    #group_by(n, sa, row) %>% 
    select(-name) %>% 
    pivot_wider(names_from = m, values_from = col) %>% 
    mutate(row = paste0('c(1:', match, ')')) %>% 
    left_join(m_col_merge, by = 'sa') %>%
    arrange(n) %>% 
    select(n, colname = sa, label = ss, cell = col) %>% 
    group_by(colname, cell) %>% 
    nest()
  
  # ========================================================= #
  # Row Merge
  # ========================================================= #
  m_depth <- max(m_extract$col) + 1
  
  merge_rows <- m_extract %>% 
    filter(o == 1) %>% 
    mutate(cell = paste0('c(1:', m_depth, ')')) %>% 
    select(label = name, n, cell)
  
  
  if(nrow(merge_columns) > 0) {
    
    for(m in 1:nrow(merge_columns)) {
      
      m_unnest <- merge_columns %>% unnest(data)
      m_cols <- merge_columns$cell[m]
      
      m_label_1 <- m_unnest %>% 
        filter(cell == m_cols) %>%
        pull(colname)
      
      
      m_label_2 <- m_unnest %>% 
        filter(cell == m_cols) %>% 
        pull(label) %>% t
      
      # Merged columns
      merge_it <- eval(parse(text = m_cols)) + 1
      
      writeData(tb, tb_sheet, m_label_1[1], merge_it[1], start_row)
      writeData(tb, tb_sheet, m_label_2, merge_it[1], start_row + 1, colNames = F)
      
      mergeCells(tb, tb_sheet, merge_it, start_row)
        
    }
    
    merge_depth <- m_depth
    merge_depth_h <- 1
    start_row_plus <- start_row + 1
    start_row_header <- start_row:start_row_plus
    n_rows <- n_rows + 1
    row_range <- start_row:n_rows
    tb_without_merge_cell <- FALSE

  }
  
  
  if(nrow(merge_rows) > 0) {
    
    for(r in 1:nrow(merge_rows)) {
      
      m_col_start <- merge_rows$n[r] + 1
      m_row_merge <- eval(parse(text = merge_rows$cell[r])) + start_row - 1
      
      writeData(tb, tb_sheet, merge_rows$label[r], m_col_start, start_row)
      mergeCells(tb, tb_sheet, m_col_start, m_row_merge)
    }
    
  }
}











