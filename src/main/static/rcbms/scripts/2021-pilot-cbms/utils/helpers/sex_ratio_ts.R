sex_ratio_ts <- function(data, raw = F) {
  
  if(raw == T) {
    df <- data %>% 
      mutate(
        m = if_else(female > 0, male / female, 1),
        f = if_else(male > 0, female / male, 1),
        s = paste0(round(m * 100, 0), ':', round(f * 100, 0)
        )
      ) %>% 
      select(s)
  } else {
    
    df <- data %>% 
      mutate(
          m = if_else(`<Frequency> Female` > 0, `<Frequency> Male` / `<Frequency> Female`, 1),
          f = if_else(`<Frequency> Male` > 0, `<Frequency> Female` / `<Frequency> Male`, 1),
          'Sex Ratio (Male:Female)' = paste0(round(m * 100, 0), ':', round(f * 100, 0)
        )
      ) %>% 
      select(-contains('<Percent> Both Sexes'), -c(m, f)) %>% 
      rename((!!as.name(d_label)) := 1) 
    
  }
  
  return(df)
  
}
