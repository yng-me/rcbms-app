
# Title and description --------------------------------------------------------

## Row 1
addWorksheet(wb, 'Summary', gridLines = F)
writeData(wb, 'Summary', 'Summary of Inconsistencies', startRow = 1)
writeData(wb, 'Summary', eval_date, startRow = 2)
writeData(wb, 'Summary', eval_check_mode, startRow = 3)
addStyle(wb, 'Summary', title_style, rows = 1, cols = 1, T, T)


# Summary of cases -------------------------------------------------------------

## Row 5
geo_id <- get(load('./data/records/geo_id.Rdata'))
exp_cases_count <- geo_id %>% nrow()
exp_unique_cases <- exp_case_wise %>% 
  filter(!grepl('x$', `Case ID`)) %>% 
  distinct(`Case ID`) %>% 
  nrow()
exp_all_cases <- exp_case_wise %>% nrow()

writeData(wb, 'Summary', 'Summary of cases', 1, 5)
writeData(wb, 'Summary', 'Total number of cases*', 1, 6)
writeData(wb, 'Summary', 'Number of unique cases with at least one inconsistency', 2, 6)
writeData(wb, 'Summary', 'Total Number of items with inconsistencies', 3, 6)
writeData(wb, 'Summary', exp_cases_count, 1, 7)
writeData(wb, 'Summary', exp_unique_cases, 2, 7)
writeData(wb, 'Summary', exp_all_cases, 3, 7)
writeData(wb, 'Summary', '* May include duplicates in the count', 1, 8)

addStyle(wb, 'Summary', font_bold, rows = 5, cols = 1, T, T)
addStyle(wb, 'Summary', header_style, rows = 6, cols = 1:3, T, T)
addStyle(wb, 'Summary', header_style_first, rows = 6, cols = 1, T, T)
addStyle(wb, 'Summary', table_style, rows = 6:7, cols = 1:3, T, T)
addStyle(wb, 'Summary', footnote_style, rows = 8, cols = 1, T, T)
addStyle(wb, 'Summary', num_format, 7, 1:3, T, T)
mergeCells(wb, 'Summary', cols = 1:3, rows = 8)

## Row 8

# Count by cases ---------------------------------------------------------------

exp_eval_by_case_count <- exp_case_wise %>% 
  group_by(Section) %>% 
  summarise(
    a = sum(Priority == 'A'),
    b = sum(Priority == 'B'),
    c = sum(Priority == 'C'),
    d = sum(Priority == 'D'),
    n = n()
  ) %>% 
  left_join(refs$sections, by = 'Section') %>% 
  mutate(label = if_else(Section == 'Cross-section', 'CROSS-SECTION', label)) %>% 
  select(
    1,
    Description = label,
    'Priority A' = a,
    'Priority B' = b,
    'Priority C' = c,
    'Priority D' = d,
    Total = n
  ) %>% 
  adorn_totals()

## Row 11
nrow_case_count <- nrow(exp_eval_by_case_count) + 12
ncol_case_count <- ncol(exp_eval_by_case_count)

writeData(wb, 'Summary', 'Number of Inconsistencies by Section and Priority Level', startCol = 1, startRow = 11)
writeData(wb, 'Summary', exp_eval_by_case_count, startCol = 1, startRow = 12)

addStyle(wb, 'Summary', font_bold, rows = 11, cols = 1, T, T)
addStyle(wb, 'Summary', header_style, rows = 12, cols = 1:ncol_case_count, T, T)
addStyle(wb, 'Summary', header_style_first, rows = 12, cols = 1, T, T)
addStyle(wb, 'Summary', table_style, 12:nrow_case_count, 1:ncol_case_count, T, T)
addStyle(wb, 'Summary', num_format, 12:nrow_case_count, 3:9, T, T)
addStyle(wb, 'Summary', num_float, 12:nrow_case_count, 10:11, T, T)

setRowHeights(wb, 'Summary', rows = 12, heights = 25)

# Count by checks --------------------------------------------------------------

exp_eval_by_checks <- exp_eval_summary %>% 
  group_by(Section) %>% 
  summarise(
    a = sum(Priority == 'A'),
    b = sum(Priority == 'B'),
    c = sum(Priority == 'C'),
    d = sum(Priority == 'D'),
    p = sum(`Number of Cases` == 0),
    f = sum(`Number of Cases` > 0),
    n = n()
  ) %>% 
  left_join(refs$sections, by = 'Section') %>% 
  mutate(label = if_else(Section == 'Cross-section', 'CROSS-SECTION', label)) %>% 
  adorn_totals() %>% 
  mutate(
    np = 100 * (p / n),
    nf = 100 * (f / n)
  ) %>% 
  select(
    1,
    Description = label,
    'Priority A' = a,
    'Priority B' = b,
    'Priority C' = c,
    'Priority D' = d,
    'Total Passed' = p,
    'Total Failed' = f,
    Total = n,
    'Total Passed (Percent)' = np,
    'Total Failed (Percent)' = nf
  )

nrow_checks <- nrow(exp_eval_by_checks)
nrow_case_count_start <- nrow_case_count + 4
nrow_case_count_end <- nrow_case_count_start + nrow_checks

exp_count_title <- 'Number of Consistency Checks Performed by Section and Priority Level'
writeData(wb, 'Summary', exp_count_title, startCol = 1, startRow = nrow_case_count_start - 1)
writeData(wb, 'Summary', exp_eval_by_checks, startCol = 1, startRow = nrow_case_count_start)

addStyle(wb, 'Summary', font_bold, rows = nrow_case_count_start - 1, cols = 1, T, T)
addStyle(wb, 'Summary', header_style, rows = nrow_case_count_start, cols = 1:ncol(exp_eval_by_checks), T, T)
addStyle(wb, 'Summary', header_style_first, rows = nrow_case_count_start, cols = 1, T, T)
addStyle(wb, 'Summary', table_style, nrow_case_count_start:nrow_case_count_end, 1:ncol(exp_eval_by_checks), T, T)
addStyle(wb, 'Summary', num_format, nrow_case_count_start:nrow_case_count_end, 3:9, T, T)
addStyle(wb, 'Summary', num_float, nrow_case_count_start:nrow_case_count_end, 10:11, T, T)


# Summary by section -----------------------------------------------------------

exp_sections <- exp_eval_summary %>% 
  distinct(Section) %>% 
  filter(!is.na(Section)) %>% 
  pull(Section)

start_row <- nrow_case_count_end + 4

for(exp_index in seq_along(exp_sections)) {
  exp_eval_section_data <- exp_eval_summary %>% 
    filter(Section == exp_sections[exp_index])
  
  nrow_s <- nrow(exp_eval_section_data)
  border_s <- start_row + nrow_s
  
  writeData(wb, 'Summary', exp_sections[exp_index], startRow = start_row - 1)
  writeData(wb, 'Summary', exp_eval_section_data, startRow = start_row)
  
  addStyle(wb, 'Summary', font_bold, rows = start_row - 1, cols = 1, T, T)
  addStyle(wb, 'Summary', header_style, rows = start_row, cols = 1:4, T, T)
  addStyle(wb, 'Summary', header_style_first, rows = start_row, cols = 1, T, T)
  addStyle(wb, 'Summary', text_center, rows = start_row:border_s, cols = 3, T, T)
  addStyle(wb, 'Summary', table_style, start_row:border_s, cols = 1:4, T, T)
  addStyle(wb, 'Summary', num_format, rows = start_row:border_s, cols = 4, T, T)
  
  for (h in seq_along(exp_eval_section_data$Title)) {
    t_name <- exp_eval_section_data$Title[h]
    if(exp_eval_section_data$`Number of Cases`[h] > 0) {
      addStyle(wb, 'Summary', link_style, rows = start_row + h, cols = 1:4, T, T)
    }
  }
  start_row <- start_row + nrow_s + 4
}

setColWidths(wb, 'Summary', cols = 1:7, widths = c(22, 70, rep(14, 5)))
mergeCells(wb, 'Summary', cols = 1:2, rows = 1)


