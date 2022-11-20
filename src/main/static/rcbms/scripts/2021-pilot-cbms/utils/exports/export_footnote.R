tb_footnote_with_indicator <- tb_footnote %>% 
  filter(!is.na(indicator))

if(nrow(tb_footnote_with_indicator) > 0) {
  for (w in 1:nrow(tb_footnote_with_indicator)) {
    f_placement <- tb_footnote_with_indicator$placement[w]
    c_placement <- str_sub(f_placement, 1, 1)
    r_placement <- as.integer(str_sub(f_placement, 2, -1))
    
    if(col2int(c_placement) == merge_cols[1] & merge_rows[1] == r_placement) {
      heading_label <- paste0(heading_label, ' ~', tb_footnote_with_indicator$indicator[w], '~')
    }
  }
}
