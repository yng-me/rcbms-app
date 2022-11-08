left_join_section_a <- function(data, by = 'line_number_id') {
  hpq$section_a %>% 
    select(case_id, line_number_id, lno, a01_hhname, a05_sex, a06_birthday, age) %>% 
    left_join(data, by = by)
}
