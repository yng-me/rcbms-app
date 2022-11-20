for(i in 1:length(output)) {
  
  d <- output[i]
  d_label <- output_label[i]
  
  if(d == 'barangay' | d == 'brgy_name') {
    
    
    for(j in 1:nrow(ref_areas_available)) {
      
      current_area <- ref_areas_available$pilot_area[j]
      d_by <- paste0(': ', current_area)
      
      brgys <- hpq_data$SUMMARY %>% 
        select(pilot_area, brgy_name) %>% 
        filter(pilot_area == current_area) %>% 
        collect() %>% 
        distinct(brgy_name) %>% 
        arrange(brgy_name) %>% 
        pull(brgy_name)
      
      current_area_filter <- current_area 
      
      source('./utils/exports/export_tables.R')
      
    }
    
  }
  
  if(d == 'pilot_area' | d == 'area') {
    
    current_area <- 'All Pilot Areas'
    brgys <- ref_areas_available$pilot_area
    current_area_filter <- brgys
    d_by <- ' for each pilot area'
    
    source('./utils/exports/export_tables.R')
  }
  
}