ref_pilot_areas <- read.xlsx('./references/pilot_ref.xlsx') %>% 
  mutate(pilot_area = paste0(mun, ', ', prov), geo = substr(geo, 2, 10)) %>% 
  select(geo, pilot_area, brgy_name = brgy)

ref_sections_desc <- read_excel(
    path = './references/refs.xlsx', 
    sheet = 'HPQ Sections', 
    range = cell_cols("B:C"),
  ) %>%
  mutate(value = toupper(value)) %>% 
  rename(section = value, label = label) %>% 
  rbind(c('1', 'Crossed-Section'))

ref_sections_reviewed <- as_tibble(list.files('./references/sections')) %>% 
  filter(grepl('.xlsx$', value, ignore.case = T)) %>% 
  distinct() %>% 
  pull(value) %>% 
  str_sub(1, -6)

ref_sections <- paste0('./scripts/inconsistencies/', list.files('./scripts/inconsistencies'))

ref_export_settings <- paste0('./references/sections/', list.files('./references/sections')) %>% 
  tibble() %>% 
  filter(!grepl('^./references/sections/~\\$', .)) %>% 
  pull(.)


for(i in 1:nrow(ref_areas_available)) {
  
  eval_area <- ref_areas_available$pilot_area[i]
  
  filterInconsistencies <- function(data) data.frame(variable_name = data, count = nrow(eval(as.name(data))))
  
  toCase <- function(data) {
    # print(data)
    eval(as.name(data)) %>% 
      transmute(
        case_id = case_id, 
        LINENO = ifelse('LINENO' %in% colnames(.), LINENO, NA)
      )
  }
  
  notAllBlank <- function(x) any(!is.na(x))
  
  rov <- hpq_data$SUMMARY %>%  
    select(case_id, RESULT_OF_VISIT) %>% 
    collect()
  
  hpq_individual <- hpq_data$SECTION_A_E %>% 
    filter(pilot_area == eval_area) %>% 
    left_join(rov, by = 'case_id') %>% 
    collect() 
  

    # ============================================================ #
  # Execute all consistency by sections
  if(config$mode == 'generate_inconsistencies_with_output') {
    lapply(ref_sections, FUN = source)
    hh_count <- nrow(rov)
    
    # ============================================================ #
    
    ref_consistencies <- as_tibble(ls(pattern = '^cv_'))
    ref_inconsistencies_list <- lapply(ref_consistencies$value, filterInconsistencies)
    ref_with_inconsistencies <- do.call("rbind", ref_inconsistencies_list) %>% 
      mutate(is_clean = if_else(count > 0, 0, 1))
    
    output_priorities <- c('A', 'B')
    
    ref_export_list <- list()
    
    for(index in seq_along(ref_export_settings)) {
      
      ref_export_list[[index]] <- read.xlsx(ref_export_settings[[index]]) %>%
        select(tab_name = 1, variable_name = 2, title = 3, description = 4, priority = 5) %>%
        filter(
          nchar(variable_name) > 1 & variable_name != '', 
          nchar(tab_name) > 1 & tab_name != '',
          priority %in% output_priorities
        ) %>% 
        mutate(
          section = toupper(str_sub(ref_export_settings[index], -6, -6)),
          tab_name_o = tab_name,
          tab_name = if_else(
            nchar(tab_name) >= 23, 
            str_trim(substr(tab_name, 1, 25)), 
            str_trim(tab_name)
          ),
          variable_name = paste0('cv', substr(str_trim(variable_name), 2, nchar(str_trim(variable_name))))
        ) %>%
        tibble()
    }
    
    ref_output_all <- do.call('rbind', ref_export_list) %>%
      distinct(tab_name, .keep_all = TRUE) %>% 
      full_join(ref_with_inconsistencies, by = 'variable_name') %>% 
      filter(
        nchar(variable_name) > 1 & variable_name != '', 
        nchar(tab_name) > 1 & tab_name != '',
        !is.na(count)
      )
    
    ref_output <- ref_output_all %>% filter(is_clean == 0)

  # ============================================================ #
  # Export
    source('./utils/inconsistencies/config.R')
    source('./utils/inconsistencies/summary.R')
    source('./utils/inconsistencies/export.R')
  }
}
