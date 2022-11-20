
# Output refs ------------------------------------------------------------------

# Load Excel reference file based on specified `mode`
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

# Filter list of data frames to be exported
tb_output_list <- ls(pattern = output_pattern)

tb_output <- ref_tb$output %>% 
  mutate(
    tab_name = if_else(
      nchar(tab_name) > 26, 
      str_sub(tab_name, 1, 26),
      tab_name
    )
  ) %>% 
  filter(variable_name %in% tb_output_list) 

if(!is.null(excluded_from_export)) {
  tb_output <- tb_output %>% 
    filter(!(variable_name %in% excluded_from_export))
}

# Output config ----------------------------------------------------------------

# Create new "output" folder if it doesn't exist.
if_else(!dir.exists('output'), dir.create('output', showWarnings = F), F)

# Create specified `ouput_folder`, defined in `mode` config, if it doesn't exist; 
# e.g. if "Tables" folder doesn't exist, it will create "Table" folder inside the "output" folder.
if_else(!dir.exists(paste0('output/', ouput_folder)), dir.create(paste0('output/', ouput_folder), showWarnings = F), F)

# Create new folder based on current date
new_dir <- paste0('output/', ouput_folder, '/As of ', formatted_date)
if_else(!dir.exists(new_dir), dir.create(new_dir, showWarnings = F), F)

# Set output path based on specified `mode` and filename.
export_path <- paste0('./', new_dir, '/', output_filename)

