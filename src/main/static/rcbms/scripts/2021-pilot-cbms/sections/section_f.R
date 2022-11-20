hpq_section_g <- hpq_data$SECTION_G %>% 
  filter(HSN < 7777, pilot_area == eval_area) %>% 
  select(case_id, TOTALFOOD = G_TOTALFOOD, starts_with('G')) %>% 
  collect()

section_f_ang_g <- suppressWarnings(
  hpq_data$SECTION_F %>% 
  collect() %>% 
  left_join(hpq_section_g, by = 'case_id') %>% 
  left_join(rov, by = 'case_id') %>%
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  mutate(
    F1A = as.double(F1A),
    F2_Z_SPECIFY = str_trim(F2_Z_SPECIFY),
    TOTALFOOD = as.numeric(TOTALFOOD),
    income_range_computed = case_when(
      F1A < 40000 ~ 1,
      F1A >= 40000 & F1A < 60000 ~ 2,
      F1A >= 60000 & F1A < 100000 ~ 3,
      F1A >= 100000 & F1A < 130000 ~ 4,
      F1A >= 130000 & F1A < 260000 ~ 5,
      F1A >= 260000 & F1A < 520000 ~ 6,
      F1A >= 520000 & F1A < 920000 ~ 7,
      F1A >= 920000 & F1A < 1570000 ~ 8,
      F1A >= 1570000 & F1A < 2620000 ~ 9,
      F1A >= 2620000 ~ 10
    ),
    total_food = rowSums(select(., G1_A:G1_N), na.rm = T),
    no_income = if_else(rowSums(select(., F2_A:F2_Z), na.rm = T) < 30, 1, 0),
    check_food_total = if_else(TOTALFOOD == total_food, 1, 0),
    neg_income = if_else(total_food * 52 < F1A, 1, 0)
  )
)
# 1. ==============================================================================
# Answer in F1A (annual income in PhP) is not consistent with F1B (income range)
cv_exact_vs_range <- section_f_ang_g %>% 
  filter(F1A > 0 | !is.na(F1A), F1B != income_range_computed) %>% 
  select(case_id, pilot_area, F1A, F1B, income_range_computed)

# 2. ==============================================================================
# F1B (Income range) missing
cv_no_income_range <- section_f_ang_g %>% 
  filter(is.na(F1B)) %>% 
  select(case_id, pilot_area, F1A, F1B)

f2_list <- list()
f2_letters <- paste0('F2_', c(LETTERS[1:14], 'Z'))

# 3-34. ==============================================================================
# Not in the value set
for(i in seq_along(f2_letters)) {
  f2_list[[paste0('cv_', tolower(f2_letters[i]), '_not_in_vs')]] <- section_f_ang_g %>% 
    filter(!(eval(as.name(paste(f2_letters[i]))) %in% c(1, 2, NA))) %>% 
    select(case_id, pilot_area, !!as.name(paste(f2_letters[i])))

  # Missing answer (NA)
  f2_list[[paste0('cv_', tolower(f2_letters[i]), '_na')]] <- section_f_ang_g %>% 
    filter(is.na(eval(as.name(paste(f2_letters[i]))))) %>% 
    select(case_id, pilot_area, !!as.name(paste(f2_letters[i])))
}

# 35. ==============================================================================
# other source of income but not specified
cv_no_income_source<- section_f_ang_g %>% 
  filter(F1A > 0 | F1B > 1, rowSums(select(., matches('^F2_[A-NZ]$')), na.rm = T) == 30) %>% 
  select(case_id, pilot_area, F1A, matches('^F2_[A-NZ]$'))

# 36. ==============================================================================
cv_food_higher_than_income <- section_f_ang_g %>% 
  filter(neg_income == 0) %>% 
  mutate(food = TOTALFOOD * 52) %>% 
  select(case_id, pilot_area, F1A, F1B, TOTALFOOD, 'Annual Food Consumption (TOTAL FOOD * 52)' = food)

# 37. ==============================================================================
# Total food item (system auto-computed) not the same with the sum of individual food items
cv_food_total_not_same <- section_f_ang_g %>% 
  filter(check_food_total == 0) %>%
  mutate(
    TOTALFOOD = round(TOTALFOOD, 2), 
    total_food = round(total_food, 2)) %>% 
  filter(TOTALFOOD != total_food) %>% 
  select(case_id, pilot_area, TOTALFOOD, 'Sum of Individual Food Items' = total_food)


list2env(f2_list, envir = .GlobalEnv)

print('Section F complete!')