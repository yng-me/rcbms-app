freq_ts <- function(
  data, 
  var,
  sort = FALSE, 
  include_total = TRUE, 
  remove_zero = F,
  include_cum = TRUE,
  code_ref = NULL,
  label = NULL
) {
  
  data <- data %>% tabyl({{var}})
  
  if(sort == TRUE) {
    df <- data %>% mutate(Percent = percent * 100) %>% 
      select(1, Frequency = n, Percent) %>% 
      arrange(desc(Frequency)) %>% 
      tibble() 
  } else {
    df <- data %>% mutate(Percent = percent * 100) %>% 
      select(1, Frequency = n, Percent) %>% 
      tibble()
  }

  if(!is.null(code_ref)) {
    df <- df %>% recode_ts(code_ref)
  }
  
  
  if(include_cum == TRUE) {
    cum <- df %>% 
      select(-1) %>% 
      cumsum %>% 
      rename(
        'Cumulative Total' = Frequency, 
        'Cumulative Percent' = Percent
      )
    
    df <- df %>% 
      bind_cols(cum)
  }
  
  
  if(include_total == TRUE) {
    df <- df %>% 
      adorn_totals(,,,, -1, -contains('Cumulative')) %>%
      na_if('-') %>% 
      mutate_at(vars(contains('Cumulative')), as.numeric)
  }
  
  if(!is.null(label)) {
    df <- df %>% rename((!!as.name(label)) := 1)
  }
  
  if(remove_zero == T) {
    df <- df %>% filter(Frequency > 0)
  }
  
  return(df)
}
