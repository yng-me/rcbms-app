#============================================================
# Formal financial account/s

print('Processing Section I...')


section_i <- hpq_data$SECTION_I %>% 
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  select(case_id, pilot_area, starts_with('I')) %>% 
  collect()

#============================================================
# Reason for not having financial account/s vs No active formal financial account/s
# Inconsistency check in I01 vs I02 - active formal financial account/s = 2 (NO) and reason for not having financial account/s is blank
# c_i02 <- section_i %>%
  #mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), I2 = str_trim(I2)) %>%
  #filter(sum_of_i_1 == 12, I2 == '') %>% 
  #select(case_id, pilot_area, starts_with(c('I1_', 'I2')))

# Inconsistency check in I01 vs I02 - active formal financial account/s = 2 (NO) and reason for not having financial account/s is in the valueset
#c_i02a <- section_i %>%
 # mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))),I2 = str_trim(I2)) %>%
#  filter(sum_of_i_1 == 12, I2 != '') %>%
 # select(case_id, pilot_area, starts_with(c('I1_', 'I2'))) 


i1_list <- list()
for(i in 1:6) {
  i1_list[[paste0('cv_i01_', letters[i], '_na')]] <- section_i %>% 
    filter(!(!!as.name(paste0('I1_', LETTERS[i]))) %in% c(1, 2)) %>% 
    select(case_id, pilot_area, matches(paste0('I1_', LETTERS[i])))
  
  #i1_list[[paste0('cv_i1_', letters[i], '_not_in_vs')]] <- 
}

list2env(i1_list, envir = .GlobalEnv)
rm(i1_list)

# ====================

cv_i02_with_ans <- section_i %>% 
  filter(rowSums(select(., starts_with('I1_')), na.rm = T) < 12, str_trim(I2) != '') %>% 
  select(case_id, pilot_area, starts_with('I1_'), I2)

cv_i02_missing <- section_i %>% 
  filter(rowSums(select(., starts_with('I1_')), na.rm = T) == 12, str_trim(I2) == '') %>% 
  select(case_id, pilot_area, starts_with('I1_'), I2)


#============================================================
# Reason for opening financial account vs With active formal financial account

# Inconsistency check between I01 and I03 - With active formal financial account and Reason for opening financial account
# 101 (A-F) = ANY YES and I03 = blank
cv_i03 <- section_i %>%
  mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), I3 = str_trim(I3)) %>%
  filter(sum_of_i_1 < 12, I3 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I3')))

# Inconsistency check between I01 and I03 - No active formal financial account and Reason for opening financial account
# 101 (A-F) = NO and I03 = value set
cv_i03a <- section_i %>%
  mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), I3 = str_trim(I3)) %>%
  filter(sum_of_i_1 == 12, I3 != "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I3')))

#============================================================
# Use of financial account/s vs With active formal financial account

# Inconsistency check between I01 and I04 - With active formal financial account (any yes) and Use of financial account
# 101 (A-F) = ANY YES and I04 = blank
cv_i04 <- section_i %>%
  mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), sum_of_i_4 = rowSums(select(., c(I4_01:I4_20)))) %>%
  filter(sum_of_i_1 < 12, sum_of_i_4 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I4_')))

# Inconsistency check between I01 and I04 - No active formal financial account and Use of financial account
# 101 (A-F) = NO and I04 is in the value set - IF I01(A-F) = NO, and any answer in I02, skip to I05
cv_i04a <- section_i %>%
  mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), sum_of_i_4 = rowSums(select(., c(I4_01:I4_20)))) %>%
  filter(sum_of_i_1 == 12, sum_of_i_4 != "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I4_')))


# Inconsistency check between I02 and I04 - reason for not having financial account and Use of financial account
# 102 = any answer A-Z and I04 = value set - ANY ANSWER IN I02, skip to I05
cv_i04b <- section_i %>%
  mutate(I2 = str_trim(I2), sum_of_i_4 = rowSums(select(., c(I4_01:I4_20)))) %>% 
  filter(I2 != "", sum_of_i_4 <= 40) %>% 
  select(case_id, pilot_area, starts_with(c('I2', 'I4_')))

#============================================================
# Reason for not having financial account/s vs Save money thru any form (not formal financial account)
# Inconsistency check in I02 vs I05 - Reason for not having financial account (any yes) and Save money thru any form (not formal financial account)
# I02 = A-Z and I05 = blank
cv_i05 <- section_i %>%
  filter(str_trim(I2) != "", is.na(I5)) %>% 
  select(case_id, pilot_area, starts_with(c('I2', 'I5')))

#=============================================================
# Save money thru any form (not formal financial account) vs Put or Keep Savings
# Inconsistency check in I05 vs I06 -  Save money through any form (not formal financial account/s) (No) and Put or Keep Savings
# I05 = 2 and I06 = value set

cv_i06 <- section_i %>%
  filter(I5 == 2, str_trim(I6) != '') %>% 
  select(case_id, pilot_area, starts_with(c('I5', 'I6')))

#=============================================================
# Reason for not saving money
# Inconsistency check between I01 = any yes and NA, I04 = A-G, I05 = 2 vs I07 = blank
cv_i07 <- section_i %>%
  filter(
    rowSums(select(., c(I4_01:I4_07)), na.rm = T) == 14 & I5 == 2, 
    is.na(I7)
  ) %>% 
  select(case_id, pilot_area, matches('I4_0[1-7]'), I5, I7, I7_SPECIFY1)

# Inconsistency check between I01(A-F) = NO, I02 = value set, I05 = NO (2) vs I07 = blank
cv_i07a <- section_i %>%
  mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), I2 = str_trim(I2)) %>%
  filter((sum_of_i_1  == 12 & I2 != "" & I5 == 2), I7 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I2', 'I5', 'I7')))

# Inconsistency check between I06 = value set vs I07 = blank
cv_i07b <- section_i %>%
  mutate(I6 = str_trim(I6), I7 = str_trim(I7)) %>%
  filter(I6 != "", is.na(I7)) %>% 
  select(case_id, pilot_area, starts_with(c('I6', 'I7')))

#==============================================================
# Have any loans
# Inconsistency check in I01 = NO, I02 = any yes, I05 = NO (2), I07 = A:Z vs I8 is blank
cv_i08 <- section_i %>%
  mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), I2 = str_trim(I2), I7 = str_trim(I7)) %>%
  filter(sum_of_i_1  == 12, I2 != '', I5 == 2, I7 != "", I8 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I2', 'I5', 'I7', 'I8')))

# Inconsistency check in I01 = A-f (any yes), I03 = value set, I04 = A-G (any yes) I05 = YES (1), I07 = A:Z vs I8 is blank
cv_i08a <- section_i %>%
  mutate(
    sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), I3 = str_trim(I3), 
    sum_of_i_4 = rowSums(select(., c(I4_01:I4_07))), 
    I5 = str_trim(I5), I6 = str_trim(I6)) %>%
  filter(sum_of_i_1  < 12, I3 != "", I5 == 1, sum_of_i_4 <= 14, I6 != "", I8 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I3', 'I4_', 'I5', 'I6', 'I8')))

#==============================================================
# Inconsistency check in I08 = Yes (1) and I9 is blank
cv_i09 <- section_i %>%
  mutate(I9 = str_trim(I9)) %>%
  filter(I8 == 1, I9 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I8', 'I9')))

#==============================================================
# Inconsistency check in I01 = A-F, I08 = NO (2) and I9 = value set and I10 = blank 
cv_i10 <- section_i %>%
  mutate(
    s = rowSums(select(., c(I1_A:I1_F)), na.rm = T), 
    I9 = str_trim(I9), 
    I10 = str_trim(I10)
  ) %>%
  filter(s < 12, I8 == 1, I9 == "" | I10 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I8', 'I9', 'I10')))

# Inconsistency check in I01 = A-F, I08 = YES (1) and I9 = value set and I10 = blank 
cv_i10a <- section_i %>%
  mutate(
    s = rowSums(select(., c(I1_A:I1_F)), na.rm = T), 
    I9 = str_trim(I9), 
    I10 = str_trim(I10)
  ) %>%
  filter(s < 12, I8 != 1, I9 == "" | I10 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I8', 'I9', 'I10')))


#==============================================================
# Inconsistency check in I01 = A-F, I08 = YES (8), I9 = value set, I10 = value set and I11 = blank
cv_i11 <- section_i %>%
  mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), sum_of_i_11 = rowSums(select(., c(I11_01:I11_12))), I9 = str_trim(I9), I10 = str_trim(I10)) %>%
  filter(sum_of_i_1 == 12, I8 == 1, I9 != "", I10 != "", sum_of_i_11 == "") %>% 
  select(case_id, pilot_area, starts_with(c('I1_', 'I8', 'I9', 'I10', 'I11_')))

# Inconsistency check in I01(A-F) = Any yes, I08 = YES and I11 = blank
cv_i11a <- section_i %>%
  mutate(sum_of_i_1 = rowSums(select(., c(I1_A:I1_F)))) %>%
  mutate(sum_of_i_11 = rowSums(select(., c(I11_01:I11_12)))) %>%
  filter(sum_of_i_1 < 12, I8 == 1, sum_of_i_11 == "") %>% 
  select(case_id, pilot_area, sum_of_i_11, starts_with(c('I1_', 'I11_')))

# Inconsistency check in I01 (A-F) = blank, I08 = YES and I9 = value set and I10 = blank
cv_i11b <- section_i %>%
  mutate(
    sum_of_i_1 = rowSums(select(., c(I1_A:I1_F))), 
    sum_of_i_11 = rowSums(select(., c(I11_01:I11_12)))
  ) %>%
  filter(sum_of_i_1 == "", sum_of_i_11 == "") %>% 
  select(case_id, pilot_area, sum_of_i_11, starts_with(c('I1_', 'I11_')))


i12_list <- list()
i12_letters <- c(LETTERS[1:11], 'Z')
for(i in 1:12) {
  i12_list[[paste0('cv_i12', tolower(i12_letters[i]))]] <- section_i %>% 
    filter(
      !!as.name(paste0('I11_', sprintf('%02d', i))) == 1,
      rowSums(select(., matches(paste0('I12_[A-KZ]_', sprintf('%02d', i))))) == 8) %>% 
    select(
      case_id, pilot_area, 
      matches(paste0('I11_', sprintf('%02d', i))), 
      matches(paste0('I12_[A-KZ]_', sprintf('%02d', i)))
    )
  
  i12_list[[paste0('cv_i12', tolower(i12_letters[i]), '_na')]] <- section_i %>% 
    filter(
      !!as.name(paste0('I11_', sprintf('%02d', i))) == 1,
      is.na(rowSums(select(., matches(paste0('I12_[A-KZ]_', sprintf('%02d', i))))))) %>% 
    select(
      case_id, pilot_area, 
      matches(paste0('I11_', sprintf('%02d', i))), 
      matches(paste0('I12_[A-KZ]_', sprintf('%02d', i)))
    )
  
  i12_list[[paste0('cv_i12', tolower(i12_letters[i]), '_1')]] <- section_i %>% 
    filter(
      !!as.name(paste0('I11_', sprintf('%02d', i))) == 2,
      !is.na(rowSums(select(., matches(paste0('I12_[A-KZ]_', sprintf('%02d', i))))))) %>% 
    select(
      case_id, pilot_area, 
      matches(paste0('I11_', sprintf('%02d', i))), 
      matches(paste0('I12_[A-KZ]_', sprintf('%02d', i)))
    )
}

list2env(i12_list, envir = .GlobalEnv)
rm(i12_list, section_i)


# print('Section I complete!')