rename_ts <- function(data) {
  data %>% 
    rename_at(
      vars(2:ncol(.)), 
      ~ if_else(
        grepl('*_percent$', .),
        paste0('<Percent> ', str_sub(., 1, -9)),
        paste0('<Frequency> ', .)
      )
    ) %>% 
    tibble()
}



rename_ts_sex <- function(data) {
  data %>% 
    rename(
      '<Frequency> Both Sexes' = `<Frequency> Total`,
      '<Percent> Both Sexes' = `<Percent> Total`
    )
}

order_ts <- function(data) {
  data %>% 
    select(1, sort(names(.))) %>% 
    select(
    1, 
    starts_with('<Frequency>') & ends_with('Total'),
    starts_with('<Frequency>'),
    starts_with('<Frequency>') & ends_with('Unknown'),
    starts_with('<Percent>') & ends_with('Total'), 
    starts_with('<Percent>'),
    starts_with('<Percent>') & ends_with('Unknown'),
    starts_with('<Cumulative>'), 
    everything()
  )
}

total_ts <- function(.data, label = 'Total Households') {
  .data %>% 
    adorn_totals(c('row', 'col')) %>% 
    rename((!!as.name(d_label)) := 1, (!!as.name(label)) := Total) %>% 
    tibble()
}
