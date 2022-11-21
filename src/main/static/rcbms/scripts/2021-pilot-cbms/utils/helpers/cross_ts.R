cross_ts <- function(
    data, 
    row, 
    col, 
    include_total = TRUE, 
    rename_total = 'Total',
    include_cum = FALSE,
    include_frequency = TRUE,
    include_percent = TRUE,
    code_ref = NULL,
    colnames = NULL,
    label = NULL,
    remove_zero = FALSE,
    by_sex = FALSE
) {
  
  
  if(!is.null(colnames)) {
    df <- data %>% 
      pivot_ts({{row}}, {{col}}, code_ref = colnames) %>% 
      adorn_totals('col', name = rename_total)
    
  } else {
    
    df <- data %>% 
      tabyl({{row}}, {{col}}) %>% 
      adorn_totals('col', name = rename_total)
  }
  
  pct <- df %>% 
    adorn_percentages('col') %>% 
    select(-1) %>% 
    replace(is.na(.), 0) %>% 
    mutate_all(~ . * 100) %>%
    rename_all(~ paste0('<Percent> ', .))
  
  df <- df %>% 
    rename_at(vars(2:ncol(.)), ~ paste0('<Frequency> ', .)) %>% 
    bind_cols(pct) 
  
  if(include_cum == TRUE) {
    cum <- df %>% 
      select(contains('Total')) %>% 
      cumsum %>% 
      rename_all(
        ~ if_else(
          grepl('^<Frequency> ', .),
          paste0('Cumulative Total'),
          paste0('Cumulative Percent')
        )
      )
    
    df <- df %>% bind_cols(cum)
  }
  
  if(!is.null(code_ref)) {
    df <- df %>% recode_ts(code_ref)
  }
  
  if(include_total == TRUE) {
    df <- df %>% 
      adorn_totals(,,,, -1, -contains('Cumulative')) %>%
      na_if('-') %>% 
      mutate_at(vars(contains('Cumulative')), as.numeric)
  }
  
  df <- df %>% 
    select(
      1, 
      starts_with('<Frequency>') & ends_with('Total'),
      starts_with('<Frequency>'),
      starts_with('<Percent>') & ends_with('Total'), 
      starts_with('<Percent>'),
      starts_with('<Cumulative>'), 
      everything()
    )
  
  if(remove_zero == TRUE) {
    df <- df %>% 
      filter(rowSums(select(., 2:ncol(.)), na.rm = T) > 0)
  }
  
  if(by_sex == TRUE) {
    df <- df %>% rename_ts_sex
  }
  
  if(!is.null(label)) {
    df <- df %>% rename((!!as.name(label)) := 1)
  }
  
  if(include_frequency == F) {
    df <- df %>% 
      select(-contains('<Frequency>')) %>% 
      rename_all(~ str_remove_all(., '<.*?> ')) %>% 
      rename_all(~ str_replace(., 'NA_', 'Unknown')) 
  }
  
  if(include_percent == F) {
    df <- df %>% 
      select(-contains('<Percent>')) %>% 
      rename_all(~ str_remove_all(., '<.*?> ')) %>% 
      rename_all(~ str_replace(., 'NA_', 'Unknown')) 
  }
  
  return(df)
  
}



