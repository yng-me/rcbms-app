
select_cv <- function(data, ..., h = NULL, condition = NULL) {
  
  df <- data %>% 
    select(
      matches('^(case_id|geo_bsn|geo_husn)$'), 
      region, 
      province, 
      city_mun, 
      brgy,
      matches('^ean$'),
      matches('^(LNO|A01_HHNAME|AGE|SEX)', ignore.case = T),
      ...
    ) %>% 
    mutate_at(vars(matches('^ean$')), ~ paste0(sprintf('%06d', as.integer(.)))) %>% 
    mutate_at(
      vars(starts_with(c('BSN', 'HUSN', 'HSN'), ignore.case = T)), 
      ~ paste0(sprintf('%04d', as.integer(.)))
    ) %>% 
    convert_fct_cv()
  
  df_x <- df %>% 
    mutate(
      lno = ifelse('lno' %in% colnames(.), sprintf('%02d', lno), ''),
      ean = ifelse('ean' %in% colnames(.), ean, '')
    ) %>% 
    select(
      matches('^(case_id|geo_bsn|geo_husn)$'), 
      region, 
      province, 
      city_mun, 
      brgy,
      ean,
      lno
    )
  
  df_name <- as_tibble(names(df)) %>% 
    left_join(refs$dictionary, by = 'value') %>% 
    mutate(label = if_else(is.na(label), value, paste0('(', toupper(value), ') ', label))) %>% 
    pull(label)
  
  colnames(df) <- df_name
  
  if(is.null(h)) {
    
    df <- df %>% 
      reactable(
        searchable = T, 
        bordered = T, 
        striped = T,
        wrap = F,
        resizable = T, 
        defaultPageSize = 15,
        showPageSizeOptions = T
      )
    
  } else {
    
    if(!is.null(condition)) {
      coldefs <- list(
        reactable::colDef(
          style = function(value) {
            if (value %in% condition) {
              list(backgroundColor = 'rgba(255, 125, 125, 0.1)')
            }
          }
        )
      )
    } else {
      coldefs <- list(reactable::colDef(style = list(backgroundColor = 'rgba(255, 125, 125, 0.1)')))
    }
    
    h_name <- as_tibble(h) %>% 
      mutate(value = str_remove(value, '_fct$')) %>% 
      left_join(refs$dictionary, by = 'value') %>% 
      mutate(label = if_else(is.na(label), value, paste0('(', toupper(value), ') ', label))) %>% 
      pull(label)
    
    coldefs <- rep(coldefs, length(h_name))
    
    names(coldefs) <- h_name
    
    df <- df %>% 
      reactable(
        searchable = T, 
        bordered = T, 
        striped = T,
        wrap = F,
        resizable = T,
        defaultPageSize = 15,
        showPageSizeOptions = T,
        columns = coldefs
      )
  }
  
  return(list(df, df_x))
  
}

reactable_cv <- function(data) {
  data %>% 
    reactable(
      searchable = T, 
      resizable = T,
      bordered = T, 
      striped = T,
      wrap = F
    )
}


select_cve <- function(data, row, col, type = 'm') {
  
  if(type == 'c') {
    df <- data %>% 
      group_by(province, city_mun, {{row}}, {{col}}) %>% 
      count() %>% 
      pivot_wider(names_from = {{col}}, values_from = n, values_fill = 0) 
  } else {
    df <- data %>% 
      group_by(province, city_mun, {{row}}) %>% 
      count()
  }
  
  df %>% 
    reactable(
      searchable = T, 
      resizable = T,
      bordered = T, 
      striped = T,
      wrap = F,
      pagination = F,
      groupBy = c('province', 'city_mun'),
      columns = list(
        province = colDef(
          # Render grouped cells without the row count
          grouped = JS("function(cellInfo) {
              return cellInfo.value
            }")
        ),
        city_mun = colDef(
          # Render grouped cells with the row count, only if there are multiple sub rows
          grouped = JS("function(cellInfo) {
            if (cellInfo.subRows.length > 1) {
              return cellInfo.value + ' (' + cellInfo.subRows.length + ')'
            }
              return cellInfo.value
            }")
        )
      )
      # columns = list(
      #   city_mun = colDef(
      #     filterable = T,
      #     filterInput = function(values, name) {
      #       tags$select(
      #         # Set to undefined to clear the filter
      #         onchange = sprintf("Reactable.setFilter('cars-select', '%s', event.target.value || undefined)", name),
      #         # "All" has an empty value to clear the filter, and is the default option
      #         tags$option(value = "", "All"),
      #         lapply(unique(values), tags$option),
      #         "aria-label" = sprintf("Filter %s", name),
      #         style = "width: 100%; height: 28px;"
      #       )
      #     }
      #   )
      # )
    )
}

