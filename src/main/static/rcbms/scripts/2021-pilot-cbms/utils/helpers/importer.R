importer <- function(path, drop_count = 11) {
  
  if(grepl('A01_08_RECORD', path) == TRUE) drop_count <- 12
  
  suppressWarnings(
    df <- read.delim(path, quote = '') %>%
      select(-contains(c('NOTE', 'REC_TYPE'))) %>% 
      mutate_at(vars(REGION:HSN), as.integer) %>% 
      mutate(
        geo = paste0(
          sprintf("%02d", REGION),
          sprintf("%02d", PROVINCE),
          sprintf("%02d", CITY),
          sprintf("%03d", BARANGAY)
        ),
        case_id = paste0(   
          sprintf("%02d", REGION),
          sprintf("%02d", PROVINCE),
          sprintf("%02d", CITY),
          sprintf("%03d", BARANGAY),
          sprintf("%06d", EA),
          sprintf("%04d", BSN),
          sprintf("%04d", HUSN),
          sprintf("%04d", HSN)
        )
      ) %>%
      filter(geo %in% ref_pilot_areas$geo) %>% 
      inner_join(ref_pilot_areas, by = "geo") %>%
      select(
        case_id, 
        pilot_area, 
        brgy_name, 
        class,
        everything(),
        -geo
      ) %>%
      mutate(across(where(is.character), ~ str_replace(., '^DEFAULT$', ''))) %>% 
      mutate(across(where(is.character), ~ str_replace(., '^(\\s{1,})|[*]*$', ''))) %>% 
      na_if('') %>% 
      filter(rowSums(is.na(.)) < (ncol(.) - drop_count)) %>%
      tibble()
  )
  
  return(df)
}
