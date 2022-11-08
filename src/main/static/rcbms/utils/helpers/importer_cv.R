importer_cv <- function(x, filter_reg = T, by_reg = NULL) {
  
  df <- read.delim(x, quote = '') 
  
  if(!is.null(by_reg)) {
    df <- df %>% 
      filter(REG_PSGC == by_reg)
  }
  
  if(filter_reg == T) {
    df <- df %>% 
      filter(HSN < 7777)
  }
  
  df <- df %>% 
    mutate(
      case_id = paste0(
        sprintf('%02d', as.integer(REG_PSGC)),
        sprintf('%02d', as.integer(PROV_PSGC)),
        sprintf('%02d', as.integer(CITY_MUN_PSGC)),
        sprintf('%03d', as.integer(BRGY_PSGC)),
        sprintf('%06d', as.integer(EAN)),
        sprintf('%04d', as.integer(BSN)),
        sprintf('%04d', as.integer(HUSN)),
        sprintf('%04d', as.integer(HSN))
      ),
      geo = paste0(
        sprintf('%02d', as.integer(REG_PSGC)),
        sprintf('%02d', as.integer(PROV_PSGC)),
        sprintf('%02d', as.integer(CITY_MUN_PSGC)),
        sprintf('%03d', as.integer(BRGY_PSGC))
      )
    ) %>% 
    left_join(refs$psgc, by = 'geo') %>% 
    select(
      case_id,
      region,
      province,
      city_mun,
      brgy,
      everything(), 
      ends_with('_PSGC'), 
      -contains('AUX')
    ) %>% 
    mutate_at(vars(matches('^(BSN|HUSN|HSN)$', ignore.case = T)), as.integer) %>% 
    mutate_if(is.character, stri_enc_toutf8) %>% 
    mutate_if(is.character, ~ str_remove(., '^\\s+')) %>% 
    mutate_if(is.character, ~ str_remove(., '\\s+$')) %>% 
    mutate_if(is.character, ~ if_else(grepl('^[.,]$', .), '', .)) %>% 
    na_if('') %>% 
    clean_names() %>% 
    filter(!(province == 'Benguet' & city_mun %in% c('Atok', 'Bokod'))) %>% 
    tibble()
  
  return(df)
  
}