ref_signature_case_id <- read.xlsx('./references/waiver_case_id.xlsx')

ref_rov <- hpq_data$SUMMARY %>% 
  select(
    case_id, 
    pilot_area, 
    brgy_name, 
    class,
    hsn = HSN, 
    husn = HUSN, 
    agreed = AGREE_INT, 
    rov = RESULT_OF_VISIT, 
    signed_waiver = RESPO_WAIVER,
    long = HH_LONGITUDE,
    lat = HH_LATITUDE,
    x = GPSLONG,
    y = GPSLAT
  ) %>% 
  filter(pilot_area %in% current_area_filter) %>% 
  collect() %>% 
  mutate_at(vars(5:9), as.integer) %>% 
  mutate(
    visited = if_else(hsn < 7777, 1L, 0L, 0L),
    agreed = ifelse(visited == 1, agreed, NA),
    agreed = if_else(
      visited == 1 & rov == 1 & is.na(agreed) & 
      (case_id %in% ref_signature_case_id$case_id | signed_waiver %in% c(1, 2)),
      1L,
      agreed
    ),
    agreed = if_else(rov != 1 & visited == 1, 2L, agreed),
    agreed = if_else(agreed > 1, 0L, agreed)
  ) %>% 
  mutate(
    occupancy = case_when(
      visited == 1 & rov == 1 & agreed == 1 ~ 1L, # Successfully interviewed 
      visited == 1 & rov != 1 | agreed != 1 ~ 0L # Refused to be interviewed or terminated
    )
  ) %>% 
  filter(!(is.na(rov) & is.na(occupancy) & visited == 1))

ref_rov_occupied <- ref_rov %>% 
  filter(occupancy == 1) %>% 
  pull(case_id)



