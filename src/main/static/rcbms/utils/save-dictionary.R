data_dictionary <- setNames(
  lapply(names(hpq), function(x) {
    
    d <- refs$dictionary %>%
      filter()
    
    as_tibble(names(hpq[[x]])) %>%
      mutate(record = x) %>%
      left_join(d, by = 'value') %>%
      select(record, item = items, variable = value, label)
  }),
  names(hpq)
)

parquet_dictionary <- do.call('rbind', data_dictionary) %>%
  tibble() %>%
  filter(!grepl('_fct$', variable)) %>%
  filter(!grepl('^a13_pcn2$', variable)) %>%
  filter(!grepl('_psgc$', variable)) %>%
  filter(!grepl('^line_number_id$', variable)) %>%
  filter(!grepl('^a01', variable)) %>%
  filter(!grepl('^geo$', variable)) %>%
  filter(!grepl('^start$', variable)) %>%
  filter(!grepl('^end$', variable)) %>%
  filter(!grepl('^duration_hr$', variable)) %>%
  filter(!grepl('^duration_min$', variable)) %>%
  filter(!grepl('^a07_age', variable)) %>%
  filter(!grepl('^ts$', variable)) %>%
  filter(!grepl('^te$', variable)) %>%
  filter(!grepl('_lnoctr$', variable)) %>%
  filter(!grepl('^g51_fishops$', variable)) %>%
  filter(!grepl('^g53a[ab]_oth$', variable)) %>%
  filter(!grepl('^g53a[ab]_oth$', variable)) %>%
  filter(!grepl('^g22a_agrimach_', variable)) %>%
  filter(!grepl('^g29a_lvstckpltrymach_', variable)) %>%
  filter(!grepl('^g42[abz]_aqufarmmach_', variable)) %>%
  filter(!grepl('^g54a_oth_', variable)) %>%
  filter(!grepl('^h[45][a-c]_total$', variable)) %>%
  filter(!grepl('^h2$', variable)) %>%
  filter(!grepl('^l27_raredisn1$', variable)) %>%
  filter(!grepl('^o05[h-k]_lno$', variable)) %>%
  filter(!grepl('^p0[56]k_comm$', variable)) %>%
  filter(!grepl('^mode_data$', variable)) %>%
  filter(!grepl('^(time|date)uploaded$', variable)) %>%
  filter(!grepl('^finalresultvisit$', variable))

arrow::write_parquet(
  parquet_dictionary,
  paste0(wd_ref_path, '/data/parquet/parquet_dictionary.parquet')
)

