ref_merge_heading <- names(tb_data) %>% 
  tibble() %>% 
  rename(heading = 1) %>% 
  mutate(heading = str_replace_all(heading, '\\r|\\n', '')) %>% 
  mutate(
    n = 1:nrow(.),
    labels = str_extract_all(heading, '<.*?>', T),
    match = str_extract_all(heading, '(<.*?>)'),
    label = str_replace_all(heading, '<.*?>\\s', ''),
    l = map_int(match, length) + 1
  ) 

ref_merge_depth <- as.integer(max(ref_merge_heading$l))
ref_merge_label <- ref_merge_heading %>% 
  filter(l == 1) %>% 
  select(l, label)
merge_l <- ref_merge_depth - 1

if(merge_l > 0) {

  ref_merge_labels <- ref_merge_heading$labels
  ref_merge_cells <- list()

  ref_merge_cells[[1]] <- ref_merge_labels[, 1] %>% 
    tibble() %>% 
    rename(label = 1) %>% 
    mutate(n = 1:nrow(.)) %>% 
    filter(str_trim(label) != '') %>% 
    group_by(label) %>% 
    summarise(
      min = min(n),
      max = max(n)
    ) %>% 
    mutate(p = 1)
  
  if(merge_l == 2) {
    #ref_merge_depth <- ref_merge_depth + 1
    ref_merge_cells[[2]] <- ref_merge_labels[, 2] %>% 
      tibble() %>% 
      rename(label = 1) %>% 
      add_column(g = ref_merge_labels[, 1]) %>% 
      mutate(n = 1:nrow(.)) %>% 
      filter(str_trim(label) != '') %>% 
      group_by(label, g) %>% 
      summarise(
        min = min(n),
        max = max(n), 
        .groups = 'drop'
      ) %>%
      select(label, min, max) %>% 
      mutate(p = 2)
  }
    
  ref_merge_cells[[ref_merge_depth]] <- ref_merge_heading$label %>% 
    tibble() %>% 
    rename(label = 1) %>% 
    mutate(n = 1:nrow(.)) %>% 
    filter(str_trim(label) != '') %>% 
    mutate(
      min = n,
      max = n,
      p = ref_merge_depth
    ) %>% 
    select(-n)
  
  merge_q <- ref_merge_heading %>% 
    unnest(match) %>% 
    distinct(label, .keep_all = T) %>% 
    select(label, l) %>% 
    bind_rows(ref_merge_label) 
  
  tb_merge_cells <- do.call('rbind', ref_merge_cells) %>% tibble() %>% 
    mutate(label = str_replace_all(label, '[<>]', '')) %>% 
    left_join(merge_q, by = 'label') %>% 
    arrange(min) %>% 
    mutate_at(vars(2:ncol(.)), as.integer) %>% 
    mutate(l = if_else(!is.na(l), l, p)) %>% 
    mutate(
      col = if_else(min == max, as.character(min), paste0('c(', min, ':', max, ')')),
      row = if_else(p == l, as.character(p), paste0('c(', l, ':', p, ')'))
    ) %>% 
    select(label, col, row)
  
  
  
  for(mm in 1:nrow(tb_merge_cells)) {
    
    merge_rows <- eval(parse(text = tb_merge_cells$row[mm])) + start_row - 1
    merge_cols <- eval(parse(text = tb_merge_cells$col[mm])) + 1
    
    heading_label <- tb_merge_cells$label[mm]
    source('./utils/exports/export_footnote.R')
    
    writeData(tb, tb_sheet, heading_label, merge_cols[1], merge_rows[1])
    mergeCells(tb, tb_sheet, merge_cols, merge_rows)
    
    addSuperSubScriptToCell(heading_label)  
    
  }
  
  merge_depth <- ref_merge_depth
  merge_depth_h <- merge_l
  start_row_plus <- start_row + merge_l
  start_row_header <- start_row:start_row_plus
  n_rows <- n_rows + merge_l
  row_range <- start_row:n_rows
  
  tb_without_merge_cell <- FALSE
}
