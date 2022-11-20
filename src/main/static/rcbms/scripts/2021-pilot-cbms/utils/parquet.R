source('./utils/library.R')

# ------------------------------------------------------------------
convert_age_cv <- function(from, to = '2021-10-01') {
  from_lt = as.POSIXlt(ymd(from))
  to_lt = as.POSIXlt(to)
  
  age = to_lt$year - from_lt$year
  
  ifelse(
    to_lt$mon < from_lt$mon |
    (to_lt$mon == from_lt$mon & to_lt$mday < from_lt$mday),
    age - 1, 
    age
  )
}

# ------------------------------------------------------------------

source_folder <- 'text'

ref_pilot_areas <- read.xlsx('./references/pilot_ref.xlsx') %>% 
  mutate(
    pilot_area = if_else(prov == 'Benguet', mun, paste0(mun, ', ', prov)),
    geo = substr(geo, 2, 10)
  ) %>% 
  select(geo, pilot_area, brgy_name = brgy, class) %>% 
  mutate(class = factor(class, c('U', 'R'), c('Urban', 'Rural')))

selected_files <- read.csv('./references/files.csv') %>% 
  mutate(file = str_remove(file, '\\.(txt|TXT)$')) %>% 
  pull(file)

files <- as_tibble(list.files(paste0('./data/', source_folder, '/'), recursive = T)) %>%
  separate(col = value, into = c('name', 'record_type'), sep = '/') %>% 
  mutate(
    geo = str_sub(name, 1, 6),
    record_type = str_remove(record_type, '\\.(txt|TXT)$')
  ) %>% 
  filter(record_type %in% selected_files)

areas <- files %>% distinct(geo, .keep_all = T) %>% select(geo, name)
paths <- files %>% distinct(record_type) %>% pull(record_type)
#paths <- c(paths, files_alt)
sections <- LETTERS[6:18]

hpq <- list()

for(i in 1:nrow(areas)) {
  
  for(j in 1:length(paths)) {

    hpq_data <- importer(
      paste0(
        './data/', 
        source_folder, '/', 
        areas$name[i], '/', 
        paths[j], '.txt'
      )
    )
    
    if(paths[j] == 'A01_08_RECORD') {
      
      suppressWarnings(
        hpq_individual <- hpq_data %>% 
          mutate(
            s = A05SEX,
            A01HHMEM = str_trim(toupper(A01HHMEM)),
            age_computed = convert_age_cv(A06DATEBORN),
            A07AGE = as.integer(A07AGE),
            case_id_m = paste0(case_id, sprintf('%02d', LINENO))
          ) %>% 
          mutate(birthday = ymd(A06DATEBORN))
      )
      
      hpq[[paste0(areas$geo[i], '_SECTION_A_E')]] <- hpq_individual
      
    } else if (paths[j] == 'SECTION_P1_P4') {
      
      hpq[[paste0(areas$geo[i], '_', paths[j])]] <- hpq_data %>% 
        rename(P3TLNO = ncol(.))
      
    } else if (paths[j] == 'Exported') {
      
      hpq_data <- hpq_data %>% 
        rename_at(vars(matches('^P[34]TLNO_')), ~ str_replace(., 'P4', 'P3'))
      
      hpq[[paste0(areas$geo[i], '_SUMMARY')]] <- hpq_data %>% 
        select(
          1:12, 
          RESULT_OF_VISIT, 
          AGREE_INT, 
          RESPO_WAIVER, 
          WAIVER_REASON, 
          WAIVER_REASON_OTH,
          HH_LATITUDE, 
          HH_LONGITUDE, 
          GPSLAT, 
          GPSLONG,
          SITIO_PUROK,
          ADDRESS
        )
      
      for(k in 1:length(sections)) {
        hpq[[paste0(areas$geo[i], '_SECTION_', sections[k])]] <- hpq_data %>% 
          select(1:12, 63:71, 75:81, 107:ncol(.)) %>% 
          rename(G_TOTALFOOD = TOTALFOOD) %>% 
          select(1:12, starts_with(sections[k])) 
        
      }
      
    } else {
      
      hpq[[paste0(areas$geo[i], '_', paths[j])]] <- hpq_data
      
    }
  }
}

distinct_files <- files %>% 
  distinct(record_type) %>% 
  filter(!(record_type %in% c('A01_08_RECORD', 'Exported'))) %>% 
  pull(record_type)

export_paths <- c(
  'SECTION_A_E',
  paste0('SECTION_', sections),
  'SUMMARY',
  distinct_files
)

  
for(path in seq_along(export_paths)) {
  extract <- paste0(areas$geo, '_', export_paths[path])
  data <- do.call('rbind', hpq[extract]) %>% tibble() 
  write_parquet(data, paste0('./data/parquet/', export_paths[path], '.parquet'))
}

rm(hpq, sections, hpq_data, extract, data, hpq_individual, areas, files, paths)

print('--------------------------------------------------------------')
print('Data files successfully converted to Parquet format.')
print('--------------------------------------------------------------')
