
tb_freq <- function(
    data,
    x,
    y = NULL,
    z = NULL,
    include_prop = TRUE,
    include_cum = TRUE,
    include_total = FALSE,
    include_na = TRUE,
    rename_total = 'Total',
    rename_first_col = NULL,
    rename_na = 'Unknown',
    code_ref = NULL,
    orientation = NULL
  )
{
  if(!is.null(col)) {
    data %>% janitor::tabyl({{row}}, {{col}}) 
  }
}
