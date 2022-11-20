# Cases with justification

eval_summary <- ref_output_all %>% 
    left_join(ref_sections_desc, by = 'section') %>% 
    mutate(section = if_else(section == '1', 'Crossed Section', paste0('Section ', section))) %>% 
    group_by(section, label, is_clean) %>% 
    count() %>%
    pivot_wider(names_from = is_clean, values_from = n) %>%
    adorn_totals(c('row', 'col')) %>%
    mutate(
      `0` = if_else(is.na(`0`), 0L, `0`), 
      `1` = if_else(is.na(`1`), 0L, `1`),
      prop = round(`1` / Total, 2)
    ) %>% 
    select(
      Section = section,
      'Section Name' = label,
      'Consistency Checks Count' = `Total`,
      'Passed' = `1`,
      'Failed' = `0`,
      'Proportion of Passed' = prop
    ) %>% 
    arrange(Section)


eval_by_section <- ref_output_all %>% 
    mutate(section = if_else(
      section == '1', 'Crossed Section', paste0('Section ', section))
    ) %>% 
    select(section, title, tab_name, count, priority)

eval_unique_sections <- eval_by_section %>% 
    distinct(section) %>%
    pull(section)

case_wise <- ref_output %>% 
    filter(!(variable_name %in% c(
      'cv_hh_head_inconsistent', 
      'cv_same_bsn_same_r1', 
      'cv_ea_count'))
    ) %>% 
    mutate(cases = map(.$variable_name, toCase)) %>% 
    unnest(cases) %>% 
    arrange(case_id, section)

a_case_wise <- case_wise %>% 
  select(
    'Case ID' = case_id,
    'Line No.' = LINENO,
    'Section' = section,
    'Priority' = priority,
    'Sheet Name' = tab_name_o, 
    'Instruction' = description
    ) %>% 
    mutate('Remarks / Justification' = '')

a_case_wise_count <- case_wise %>% 
    group_by(case_id) %>% 
    nest() %>% 
    mutate(n = map_int(data, nrow)) %>% 
    pull(n)

ref_export_settings_all <- ref_output_all %>%
    select(tab_name, title, description)

start_row <- 15 + nrow(eval_summary)
nrow_cases <- nrow(a_case_wise) + 5

border_summary <- 12 + nrow(eval_summary)
rows_summary <- nrow(eval_by_section) + start_row
