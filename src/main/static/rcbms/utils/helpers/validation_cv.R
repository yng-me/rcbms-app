validation_cv <- function(section) {
  validation_cv <- as_tibble(ls(pattern = '^cv_')) %>% 
    mutate(cases = map(.$value, function(x) { eval(as.name(x))[[2]] })) %>% 
    unnest(cases) %>% 
    mutate(
      case_id = if_else(is.na(case_id) & !is.na(geo_bsn), paste0(geo_bsn, 'xxxxxxxx'), case_id),
      case_id = if_else(is.na(case_id) & !is.na(geo_husn), paste0(geo_husn, 'xxxx'), case_id)
    )
  save(validation_cv, file = paste0('../data/validation/',  section, '.Rdata'))
}
