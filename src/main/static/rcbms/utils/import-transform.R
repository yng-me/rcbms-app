# Load Section A ---------------------------------------------------------------

suppressWarnings(
  hpq$section_a <- importer_cv(paste0(wd_data_path, 'SECTION_A.TXT'), by_reg = reg_psgc) %>% 
    filter(!is.na(lno)) %>% 
    mutate(
      age = convert_age_cv(a06_birthday),
      line_number_id = if_else(!is.na(lno), paste0(case_id, sprintf('%02d', lno)), '')
    ) %>% 
    na_if('') %>% 
    select(1, line_number_id, 2:5, everything())
)
print('Done: Section A')

# Pivot Longer to get Line Number from Section A -------------------------------

for (i in 2:5) {
  
  letter <- paste0('section_', letters[i])
  df_all <- list()
  
  for(j in 1:35) {
    df_all[[j]] <- hpq[[letter]]  %>% 
      select(1:9, matches(paste0(sprintf('%02d', j), '$'))) %>% 
      rename_at(-c(1:9), ~ str_replace(., '_\\d{2}$', ''))
  }
  
  hpq[[letter]] <- do.call('rbind', df_all) %>% 
    tibble() %>% 
    filter(!is.na(lno)) %>% 
    arrange(case_id) %>% 
    mutate(line_number_id = if_else(
      !is.na(lno), paste0(case_id, sprintf('%02d', lno)), '')
    ) %>% 
    left_join(
      dplyr::select(
        hpq$section_a, 
        line_number_id,
        a01_hhname, 
        a01_lstname, 
        a01_firstname, 
        a05_sex, 
        age
      ), 
      by = 'line_number_id'
    ) %>% 
    select(
      case_id, 
      line_number_id, 
      2:10,
      a01_hhname, 
      a01_lstname, 
      a01_firstname, 
      a05_sex, 
      age,
      everything()
    )
  
  print(paste0('Done: Section ', toupper(letter)))
}


# Join from Section B to get OFI -----------------------------------------------

ref_b06 <- c('a', 'd', 'e')

for(k in 1:3) {
  s <- paste0('section_', ref_b06[k])
  hpq[[s]] <- hpq[[s]] %>% 
    left_join(
      dplyr::select(hpq$section_b, line_number_id, b06_ofi), 
      by = 'line_number_id'
    ) %>% 
    select(1:15, b06_ofi, everything())
}

print('Done: Joining OFI')

#rm(df_all, ref_b06, i, j, k, s)

suppressWarnings(
  hpq$interview_record <- importer_cv(paste0(wd_data_path, 'INTERVIEW_RECORD.TXT'), by_reg = reg_psgc) %>% 
    mutate(
      ts = if_else(is.na(dateofvisit), '', paste0(dateofvisit, sprintf('%04d', time_start))),
      te = if_else(is.na(dateofvisit), '', paste0(dateofvisit, sprintf('%04d', time_end)))
    ) %>%
    na_if('') %>% 
    mutate(
      start = mdy_hm(as.numeric(ts)),
      end = mdy_hm(as.numeric(te)),
      duration_hr = difftime(end, start, units = 'hours'),
      duration_min = difftime(end, start, units = 'mins')
    ) %>% 
    arrange(case_id, start, end)
)

print('Done: Interview Record')

hpq$summary_of_visit <- importer_cv(paste0(wd_data_path, 'SUMMARY_OF_VISIT.TXT'), by_reg = reg_psgc) 

print('Done: Summary of Visit')

hpq$geo_info <- importer_cv(paste0(wd_data_path, 'GEO_ID.TXT'), filter_reg = F, by_reg = reg_psgc) %>% 
  mutate(
    geo_bsn = str_sub(case_id, 1, -9),
    geo_husn = str_sub(case_id, 1, -5)
  )
print('Done: Geo Info')
# source('./utils/factors.R')
