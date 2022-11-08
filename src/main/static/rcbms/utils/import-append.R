wd_data_path <- paste0(wd_ref_path, '/data/append/21 Oct 2022/')

hpq_old <- hpq
hpq <- list()

hpq <- setNames(
  lapply(paste0(wd_data_path, ref_files),  importer_cv),
  ref_filename
)

source('./utils/import-transform.R')

hpq_names <- names(hpq_old)

hpq_new <- setNames(lapply(hpq_names, function(x) {
  hpq_old[[x]] %>% 
    bind_rows(hpq[[x]])
}), hpq_names)

rm(hpq_old, hpq)
hpq <- hpq_new
rm(hpq_new)
