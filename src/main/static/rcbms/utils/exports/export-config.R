# Export title and file name ---------------------------------------------------
source('./utils/references.R')

formatted_date <- paste0(
  sprintf('%02d', day(today())), ' ', 
  month(today(), label = TRUE, abbr = FALSE), ' ',
  year(today())
) 

if(Sys.info()[1] == 'Darwin' || Sys.info()[1] == 'darwin') {
  output_path_prefix <- './output'
} else {
  output_path_prefix <- config$paths$output_path
}

new_dir <- paste0(output_path_prefix, '/As of ', formatted_date)

if_else(!dir.exists(output_path_prefix), dir.create(output_path_prefix, showWarnings = F), F)
if_else(!dir.exists(new_dir), dir.create(new_dir, showWarnings = F), F)

export_path_temp <- paste0(
  new_dir,
  '/List of Cases with Inconsistencies - Generated as of (', 
  formatted_date, ')'
)

export_path <- paste0(export_path_temp, '.xlsx')
eval_date <- paste0('As of ', formatted_date)

eval_check_mode <- 'BEFORE EDIT'
if(config$run_after_edit == T) eval_check_mode <- 'AFTER EDIT'

# Export settings --------------------------------------------------------------

references_list_temp <- list()
ref_data <- "./references/export_settings.xlsx"
ref_tab_names <- excel_sheets(path = ref_data)

for (c in 1:length(ref_tab_names)) { 
  suppressWarnings(
    references_list_temp[[ref_tab_names[c]]] <- read_excel(
      path = ref_data, 
      sheet = ref_tab_names[c], 
      range = cell_cols("A:F")
    )
  )
}

refs[['export_settings']] <- do.call("rbind", references_list_temp) %>% 
  select(
    tab = 1,
    variable_name = 2, 
    title = 3, 
    description = 4, 
    priority = 5, 
    section = 6
  ) %>%
  filter(!is.na(variable_name), !is.na(section)) %>% 
  tibble()

rm(references_list_temp, ref_data, ref_tab_names)


# Case wise --------------------------------------------------------------------

validation_files <- list.files('./data/validation')

validation_data <- setNames(
  lapply(
    validation_files, 
    function(x) {
      get(load(paste0('./data/validation/', x))) %>% 
        select(
          variable_name = value,
          case_id,
          region,
          province,
          city_mun,
          brgy,
          ean,
          lno
        )
    }
  ),
  str_remove(validation_files, '.Rdata')
)


exp_case_wise <- do.call('rbind', validation_data) %>% 
  right_join(refs$export_settings, by = 'variable_name') %>% 
  mutate(
    section = if_else(
      section == '1', 
      'Cross-section',
      paste0('Section ', section)
    ), 
  ) %>% 
  # mutate(lno = if_else(grepl('\\d{2}', lno), '', lno)) %>% 
  na_if('') %>% 
  mutate(ean = if_else(is.na(ean) & !is.na(case_id), str_sub(case_id, 10, 15), ean)) %>%
  select(
    'Case ID' = case_id,
    'Region' = region,
    'Province' = province,
    'City/Mun' = city_mun,
    'Barangay' = brgy,
    'EA' = ean,
    'Line Number' = lno,
    'Priority' = priority,
    'Section' = section,
    'Title' = title,
    'Description' = description,
    tab
  ) 


# Justifications ----------------------------------------------------------------
if(Sys.info()[1] == 'Darwin' || Sys.info()[1] == 'darwin') {
  justification_path <- './references/justifications/'
} else {
  justification_path <- config$paths$justification_path
}

j_files <- as_tibble(paste0(justification_path, '\\', list.files(justification_path))) %>% 
  filter(grepl('\\.xlsx$', value, ignore.case = T), !grepl('\\$', value)) %>% 
  pull(value)

if(config$include_justifiction & dir.exists(justification_path) & length(j_files) > 0) {
  
  j_df_valid <- list()

  for(k in 1:length(j_files)) {
    
    wb_j <- loadWorkbook(j_files[k])
    
    if('Cases with Inconsistencies' %in% names(wb_j)) {
      j_df_valid[[k]] <- j_files[k]
    }
  }
  
  
  j_df <- lapply(j_df_valid, function(x) {
    if(!is.null(x)) {
      read.xlsx(x, 'Cases with Inconsistencies', startRow = 4)
    }
  })
  
  justifications <- do.call('rbind', j_df)

  if(!is.null(justifications)) {
    
    if('tab' %in% names(justifications)) {
      justification <- justifications %>% 
        select(
          'Case ID' = Case.ID,
          'Line Number' = Line.Number,
          Section,
          tab,
          Status,
          'Remarks / Justification' = `Remarks./.Justification`
        ) %>% 
        filter(!is.na(Status) | !is.na(`Remarks / Justification`)) %>% 
        mutate('Line Number' = if_else(is.na(`Line Number`), '', sprintf('%02d', as.integer(`Line Number`)))) %>% 
        na_if('')
      
        exp_case_wise <- exp_case_wise %>% 
          left_join(
            justification, 
            by = c('Case ID', 'Line Number', 'Section', 'tab') 
          ) %>% 
          distinct()
          # filter(!grepl('JUSTIFIED', Status, ignore.case = T))  %>% 
        
    } else {
      
      justification <- justifications %>%
        select(
          'Case ID' = Case.ID,
          'Line Number' = Line.Number,
          Section,
          Title,
          Description,
          Status,
          'Remarks / Justification' = `Remarks./.Justification`
        ) %>% 
        filter(!is.na(Status) | !is.na(`Remarks / Justification`)) %>% 
        mutate('Line Number' = if_else(is.na(`Line Number`), '', sprintf('%02d', as.integer(`Line Number`)))) %>% 
        na_if('')
      
        exp_case_wise <- exp_case_wise %>% 
          left_join(
            justification, 
            by = c('Case ID', 'Line Number', 'Section', 'Title', 'Description')
          ) %>% 
          distinct()
          # filter(!grepl('JUSTIFIED', Status, ignore.case = T)) %>% 
    }
  } else {
    exp_case_wise <- exp_case_wise %>% 
      distinct() %>%
      mutate(
        Status = NA,
        'Remarks / Justification' = NA
      ) 
  }
  
} else {
  
  exp_case_wise <- exp_case_wise %>% 
    distinct() %>%
    mutate(
      Status = NA,
      'Remarks / Justification' = NA
    ) 
}


exp_eval_clean <- exp_case_wise %>% 
  filter(is.na(`Case ID`)) %>% 
  select(Section, Title, Priority, tab) %>% 
  mutate(`Number of Cases` = 0)

exp_eval_summary <- exp_case_wise %>% 
  filter(!is.na(`Case ID`)) %>% 
  group_by(Section, Title, Priority, tab) %>% 
  count(name = 'Number of Cases') %>% 
  ungroup() %>% 
  bind_rows(exp_eval_clean) %>% 
  arrange(Section, tab) %>% 
  select(-tab)

