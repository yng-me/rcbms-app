prop_ts <- function(
    data,
    ...,
    label = NULL,
    rename_total = NULL, 
    remove_total = TRUE, 
    remove_zero = F,
    include_frequency = T,
    include_percent = T,
    c_name = NULL
) {
  
  if(nrow(data) == 0) {
    return(data)
  }
  
  data <- data %>% tabyl(...)
  
  if(is.null(rename_total)) {
    df <- data %>% 
      adorn_totals(c('row', 'col'), name = c('Total', 'RowTotal')) %>%
      mutate_at(
        2:ncol(.), 
        list(percent = ~ if_else(
          RowTotal == 0, 
          0, 
          (. / RowTotal) * 100))
      ) %>% 
      rename_ts
  } else {
    df <- data %>% 
      adorn_totals(c('row', 'col')) %>%
      rename((!!as.name(rename_total)) := Total) %>% 
      mutate_at(
        2:ncol(.), 
        list(percent = ~ (. / !!as.name(rename_total)) * 100)
      ) %>% 
      rename_ts %>% 
      select(1, contains(rename_total), everything(), -contains(paste0('<Percent> ', rename_total))) %>% 
      rename_at(vars(2), ~ str_replace(., '<Frequency> ', ''))
  }
  
  if(remove_total == TRUE) {
    df <- df %>% select(-contains('RowTotal'))
  } 
  
  if(!is.null(c_name)) {
    df <- df %>% rename_at(
      vars(3:ncol(.)), 
      ~ if_else(
        grepl('^<Percent>', .),
        paste0('<Percent> ', str_sub(., 1, -11), ' ', c_name),
        paste0('<Frequency> ', str_sub(., 1, -13), ' ', c_name),
      )
    )
  }
  
  if(remove_zero == TRUE) {
    df <- df %>% 
      filter(rowSums(select(., 2:ncol(.)), na.rm = T) > 0)
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
  
  return (df)
}