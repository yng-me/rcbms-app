prop_ts_m <- function(
    data, 
    by,
    col, 
    code_ref,
    rename_total = 'Total Households', 
    filter = NULL, 
    label = NULL
) {
  
  if(is.null(label)) label <- d_label
  
  code_refs <- ref_codes %>% 
    filter(list_name == code_ref) %>% 
    select(label, type = value)
  
  is_all_unique <- code_refs %>% 
    distinct(label) %>% 
    group_by(label) %>% 
    count() %>% 
    filter(n > 1)
  
  if(nrow(is_all_unique) > 0) stop('Code refs contains duplicate values/labels')
  
  if(!is.null(filter)) {
    data <- data %>% filter(eval(as.name(filter)) == 1) 
  }
  
  join_with <- data %>% 
    group_by(!!as.name(by)) %>% 
    count() %>% 
    adorn_totals
  
  data %>%
    mutate(type = str_trim({{col}})) %>%
    mutate(type = strsplit(type, split = '')) %>%
    unnest(type) %>% 
    group_by(!!as.name(by), type) %>% 
    count() %>% 
    ungroup() %>% 
    inner_join(code_refs, by = 'type') %>% 
    arrange(type) %>% 
    select(-type) %>% 
    pivot_wider(
      names_from = label,
      values_from = n,
      values_fill = 0, 
      names_sort = F
    ) %>% 
    adorn_totals %>% 
    inner_join(join_with, by = by) %>% 
    mutate_at(
      vars(-c(1, n)), 
      list(percent = ~ (. / n) * 100)
    ) %>% 
    select(1, n, everything()) %>% 
    rename((!!as.name(label)) := 1) %>% 
    rename_ts %>% 
    rename((!!as.name(rename_total)) := 2)
}

