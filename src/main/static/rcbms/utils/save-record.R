if(config$convert_to_rdata == T) {
  if(Sys.info()[1] == 'Darwin' || Sys.info()[1] == 'darwin') {
    save(hpq, file = './data/hpq.Rdata')
  } else {
    save(hpq, file = config$paths$rdata_path)
  }
}

ref_factors <- paste0('./utils/factors/', list.files('./utils/factors/'))
lapply(ref_factors, source)

if_else(!dir.exists('./data/parquet'), dir.create('./data/parquet', showWarnings = F), F)

parquet_names <- names(hpq)

for(pq in seq_along(parquet_names)) {
  df <- hpq[[parquet_names[pq]]] %>% convert_fct_cv()
  arrow::write_parquet(df, paste0('./data/parquet/', parquet_names[pq], '.parquet'))
}

parquet_geo <- hpq$geo_info %>% 
  distinct(geo, .keep_all = T) %>% 
  select(region, province, city_mun, brgy, ends_with('psgc')) %>% 
  filter(!is.na(region), !is.na(province), !is.na(city_mun), !is.na(brgy))

arrow::write_parquet(parquet_geo, './data/parquet/geo.parquet')

source('./utils/save-dictionary.R')