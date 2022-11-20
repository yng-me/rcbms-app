# ============================================== #
# Reference for output tables
# ============================================== #
ref_tb <- list()
tb_ref_data <- paste0('./references/tables/', output_ref_source, '.xlsx')
tb_ref_tab_names <- excel_sheets(path = tb_ref_data)

for (t in 1:length(tb_ref_tab_names)) { 
  suppressWarnings(
    ref_tb[[tb_ref_tab_names[t]]] <- read_excel(
      path = tb_ref_data, 
      sheet = tb_ref_tab_names[t]
    )
  )
}

