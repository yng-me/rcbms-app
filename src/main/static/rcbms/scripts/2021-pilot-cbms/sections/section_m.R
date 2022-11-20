# Section M ==  == =
section_m <- hpq_data$SECTION_M %>%  
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  select(case_id, pilot_area, starts_with('M')) %>% 
  collect()

#  ===========================================================
#  Regular HH with no response in M1
cv_m01_na <- section_m %>%
  filter(is.na(M1)) %>%
  select(case_id, pilot_area, M1)
#  ===========================================================

# List of Cases with response in M2A TO M2E but m01=2 ==  == 
cv_m01 <- section_m %>%
  mutate(s = rowSums(select(., matches('M2_[A-E]')))) %>%
  filter(M1 == 2, !is.na(s)) %>%
  select(case_id, pilot_area, M1, matches('M2_[A-E]'))

# List of cases of non response in M1 == =
cv_m01_1 <- section_m %>% 
filter(!(M1 %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, M1)

# ===========================================================================
m1_list <- list()
for(i in 1:5) {
  m1_var <- paste0('M2_', LETTERS[i])
  # Not in the value set
  m1_list[[paste0('cv_m2_', letters[i])]] <- section_m %>% 
    filter(M1 == 1, !(eval(as.name(paste(m1_var))) %in% c(1, 2, NA))) %>% 
    select(case_id, pilot_area, M1, !!as.name(paste(m1_var)))
  
  # Missing answer (NA)
  m1_list[[paste0('cv_m2_', letters[i], '_na')]] <- section_m %>% 
    filter(M1 == 2, !is.na(eval(as.name(paste(m1_var))))) %>% 
    select(case_id, pilot_area, M1, !!as.name(paste(m1_var)))
}
list2env(m1_list, envir = .GlobalEnv)
# ===========================================================================

# List of cases of non response in M3 but M2A1=1 == =
cv_m03_1 <- section_m %>% 
  filter(!(M3 %in% c(1:5, 9)), M2_A == 1, M1 == 1) %>%
  select(case_id, pilot_area, M1, M2_A, M3)

# List of cases of response in M3 but M2A=2 == =
cv_m03_2 <- section_m %>% 
  filter(!is.na(M3), M2_A == 2, M1 == 1) %>%
  select(case_id, pilot_area, M1, M2_A, M3)

# Check if M2_B=1, value in M4 is blank == =
cv_m04_1 <- section_m %>% 
  filter(is.na(M4), M2_B == 1, M1 == 1) %>%
  select(case_id, pilot_area, M1, M2_B, M4)

# Check if M2_B=1, value in M5 is blank == =
cv_m05_1 <- section_m %>% 
  filter(is.na(M5), M2_B == 1, M1 == 1) %>%
  select(case_id, pilot_area, M1, M2_B, M5)

# Check if M2_C=1, value in M6 is blank == =
cv_m06_1 <- section_m %>% 
  filter(is.na(M6), M2_C == 1, M1 == 1) %>%
  select(case_id, pilot_area, M1, M2_C, M6)

# Check if M2_D=1, value in M5 is blank == =
# cv_m07_1 <- section_m %>% 
  # filter(is.na(M7), M2_D == 1 | M2_E == 1, M1 == 1) %>%
  # select(case_id, pilot_area, M1, M2_D, M2_E, M5)

# Check NA/not in the value set in M07 == =
cv_m07 <- section_m %>% 
  filter(!(M7 %in% c(1, 2))) %>%
  select(case_id, pilot_area, M1, M7)

# Check NA/not in the value set in M08 == =
cv_m08_1 <- section_m %>% 
  filter(!(M8 %in% c(1, 2, 8))) %>%
  select(case_id, pilot_area, M1, M8)

# Check M19 TO M12 with values but M08 = 2 or 8 ==  == 
cv_m08_2 <- section_m %>% 
  filter(M8 %in% c(2, 8), !is.na(M9)) %>%
  select(case_id, pilot_area, M8:M12, -contains('SPECIFY')) 

cv_m08_3 <- section_m %>% 
  filter(M8 %in% c(2, 8), !is.na(M10)) %>%
  select(case_id, pilot_area, M8:M12, -contains('SPECIFY'))

cv_m08_4 <- section_m %>% 
  filter(M8 %in% c(2, 8), !is.na(M11)) %>%
  select(case_id, pilot_area, M8:M12, -contains('SPECIFY'))

cv_m08_5 <- section_m %>% 
  filter(M8 %in% c(2, 8), !is.na(M12)) %>%
  select(case_id, pilot_area, M8:M12, -contains('SPECIFY'))

# Check NA/not in the value set in M09 == =
cv_m09_1 <- section_m %>% 
  filter(!(M9 %in% c(1:9, 99)), M8 == 1) %>%
  select(case_id, pilot_area, M8, M9)

# Check M9 with values, M08=2 == =
#cv_m09_2 <- section_m %>% 
  #filter(!is.na(M9), M8 == 2) %>%
  #select(case_id, pilot_area, M8, M9)

# Check NA/not in the value set in M09 == =
#c_m09_3 <- section_m %>% 
  #filter(!(M9 %in% c(1:9, 99)), M8 == 1) %>%
  #select(case_id, pilot_area, M8, M9)

# Check NA/not in the value set in M10 == =
cv_m10_1 <- section_m %>% 
  filter(!(M10 %in% c(1, 2)), M8 == 1) %>%
  select(case_id, pilot_area, M8, M10)

# Check NA/not in the value set in M11 == =
cv_m11_1 <- section_m %>% 
  filter(!(M11 %in% c(1:7, 9)), M10 == 1) %>%
  select(case_id, pilot_area, M10, M11)

# Check if M10=2 and with values in M11 == =
cv_m11_2 <- section_m %>% 
  filter(!is.na(M11), M10 == 2) %>%
  select(case_id, pilot_area, M10, M11)

# Check if M12 have entries if M10 =1 == =
cv_m12_1 <- section_m %>% 
  filter(is.na(M12), M10 == 1) %>%
  select(case_id, pilot_area, M10, M12)

# Check if M12 NO entries if M10 =2 == =
cv_m12_2 <- section_m %>% 
  filter(!is.na(M12), M10 == 2) %>%
  select(case_id, pilot_area, M10, M12)

# =============================================
# Not in the value set in M13A
cv_m13_a <- section_m %>% 
  filter(!(M13_01 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_01)

# Not in the value set in M13B
cv_m13_b <- section_m %>% 
  filter(!(M13_02 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_02)

# Not in the value set in M13C
cv_m13_c <- section_m %>% 
  filter(!(M13_03 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_03)

# Not in the value set in M13D
cv_m13_d <- section_m %>% 
  filter(!(M13_04 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_04)

# Not in the value set in M13E
cv_m13_e <- section_m %>% 
  filter(!(M13_05 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_05)

# Not in the value set in M13F
cv_m13_f <- section_m %>% 
  filter(!(M13_06 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_06)

# Not in the value set in M13G
cv_m13_g <- section_m %>% 
  filter(!(M13_07 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_07)

# Not in the value set in M13H
cv_m13_h <- section_m %>% 
  filter(!(M13_08 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_08)

# Not in the value set in M13I
cv_m13_i <- section_m %>% 
  filter(!(M13_09 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_09)

# Not in the value set in M13Z-----
cv_m13_z <- section_m %>% 
  filter(!(M13_10 %in% c(1:2))) %>%
  select(case_id, pilot_area, M13_10)


# Not in the value set in M24----
cv_m24 <- section_m %>% 
  filter(!(M24 %in% c(1:2)), M18 == 1) %>%
  select(case_id, pilot_area, M24)

# Not in the value set in M25A----
cv_m25a_1 <- section_m %>% 
  filter(!(M25A %in% c(1:2)), M24 == 1) %>%
  select(case_id, pilot_area, M25A)

# M24 is 2, M25A should be blank
cv_m25a_2 <- section_m %>% 
  filter((M25A %in% c(1:2)), M24 == 2) %>%
  select(case_id, pilot_area, M25A)

# Not in the value set in M25B---
cv_m25b_1 <- section_m %>% 
  filter(!(M25B %in% c(1:2)), M24 == 1) %>%
  select(case_id, pilot_area, M25B)

# M24 is 2, M25B should be blank
cv_m25b_2 <- section_m %>% 
  filter((M25B %in% c(1:2)), M24 == 2) %>%
  select(case_id, pilot_area, M25B)

# Not in the value set in M25C---
cv_m25c_1 <- section_m %>% 
  filter(!(M25C %in% c(1:2)), M24 == 1) %>%
  select(case_id, pilot_area, M25C)

# M24 is 2, M25C should be blank
cv_m25c_2 <- section_m %>% 
  filter((M25C %in% c(1:2)), M24 == 2) %>%
  select(case_id, pilot_area, M25C)

# Not in the value set in M25D---
cv_m25d_1 <- section_m %>% 
  filter(!(M25D %in% c(1:2)), M24 == 1) %>%
  select(case_id, pilot_area, M25D)

# M24 is 2, M25D should be blank
cv_m25d_2 <- section_m %>% 
  filter((M25D %in% c(1:2)), M24 == 2) %>%
  select(case_id, pilot_area, M25D)

# Not in the value set in M25Z---
cv_m25z_1 <- section_m %>% 
  filter(!(M25Z %in% c(1:2)), M24 == 1) %>%
  select(case_id, pilot_area, M25Z)

# M24 is 2, M25Z should be blank
cv_m25z_2 <- section_m %>% 
  filter((M25Z %in% c(1:2)), M24 == 2) %>%
  select(case_id, pilot_area, M25Z)

# Not in the value set in M26---
cv_m26 <- section_m %>% 
  filter(!(M26 %in% c(1:2))) %>%
  select(case_id, pilot_area, M26)

# Not in the value set in M27---
cv_m27 <- section_m %>% 
  filter(!(M27 %in% c(1:2))) %>%
  select(case_id, pilot_area, M27)

# Not in the value set in M28---
cv_m28 <- section_m %>% 
  filter(!(M28 %in% c(1:2))) %>%
  select(case_id, pilot_area, M28)

# Not in the value set in M29---
cv_m29 <- section_m %>% 
  filter(!(M29 %in% c(1:2))) %>%
  select(case_id, pilot_area, M29)

# Not in the value set in M14typhoon ==  == 
cv_m13_typhoon <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_01')))) %>%
  filter(M13_01 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_01, m_14_sum, matches('M14_[A-Z]_01'))
# Not in the value set in M14flood ==  == 
cv_m13_flood <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_02')))) %>%
  filter(M13_02 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_02, m_14_sum, matches('M14_[A-Z]_02'))
# Not in the value set in M14drought ==  == 
cv_m13_drought <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_03')))) %>%
  filter(M13_03 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_03, m_14_sum, matches('M14_[A-Z]_03'))

# Not in the value set in M14earthquake == =
cv_m13_equake <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_04')))) %>%
  filter(M13_04 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_04, m_14_sum, matches('M14_[A-Z]_04'))

# Not in the value set in M14volcanic eruption == == == =
cv_m13_veruption <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_05')))) %>%
  filter(M13_05 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_05, m_14_sum, matches('M14_[A-Z]_05'))

# Not in the value set in M14landslide == == == 
m_m13_landslide <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_06')))) %>%
  filter(M13_06 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_06, m_14_sum, matches('M14_[A-Z]_06'))

# Not in the value set in M14fire ==  == =
cv_13_fire <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_07')))) %>%
  filter(M13_07 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_07, m_14_sum, matches('M14_[A-Z]_07'))

# Not in the value set in M14pandemic == == == 
cv_m13_pandemic <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_08')))) %>%
  filter(M13_08 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_08, m_14_sum, matches('M14_[A-Z]_08'))

# Not in the value set in M14armed conflict == == == 
cv_m13_aconflict <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M14_'))
  ) %>%
  mutate(m_14_sum = rowSums(select(., matches('M14_[A-Z]_09')))) %>%
  filter(M13_09 == 1, is.na(m_14_sum)) %>%
  select(case_id, pilot_area, M13_09, m_14_sum, matches('M14_[A-Z]_09'))

# Check NA in M15 == =
cv_m15 <- section_m %>% 
  filter(is.na(M15A), (M13_01 == 1|M13_02 == 1|M13_03 == 1|M13_04 == 1|M13_05 == 1|
                        M13_06 == 1|M13_07 == 1|M13_08 == 1|M13_09 == 1|M13_10 == 1), 
         (M14_C_01 == 1|M14_C_02 == 1|M14_C_03 == 1|M14_C_04 == 1|M14_C_05 == 1|M14_C_06 == 1|
            M14_C_07 == 1|M14_C_08 == 1|M14_C_09 == 1|M14_C_10 == 1)) %>%
  select(case_id, pilot_area, M13_01:M13_10, M15A)


# Check NA/not in the value set in M16 == =

cv_m16_a_01<- section_m %>% 
  filter(!(M8 %in% c(1, 2, 8))) %>%
  select(case_id, pilot_area, M1, M8)

# Not in the value set in M16typhoon ==  == 
cv_m16_typhoon <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_01')))) %>%
  filter(M16_A_01 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_01, m_16_sum, matches('M16_[A-Z]_01'))

# Not in the value set in M16flood ==  == 
cv_m16_flood <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_02')))) %>%
  filter(M16_A_02 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_02, m_16_sum, matches('M16_[A-Z]_02'))

# Not in the value set in M16drought ==  == 
cv_m16_drought <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_03')))) %>%
  filter(M16_A_03 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_03, m_16_sum, matches('M16_[A-Z]_03'))

# Not in the value set in M16Earthquake ==  == 
cv_m16_equake <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_04')))) %>%
  filter(M16_A_04 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_04, m_16_sum, matches('M16_[A-Z]_04'))

# Not in the value set in M16Volcanic Eruption ==  == 
cv_m16_veruption <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_05')))) %>%
  filter(M16_A_05 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_05, m_16_sum, matches('M16_[A-Z]_05'))

# Not in the value set in M16Landslide ==  == 
cv_m16_landslide<- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_06')))) %>%
  filter(M16_A_06 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_06, m_16_sum, matches('M16_[A-Z]_06'))

# Not in the value set in M16Fire ==  == 
cv_m16_fire <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_07')))) %>%
  filter(M16_A_07 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_07, m_16_sum, matches('M16_[A-Z]_07'))

# Not in the value set in M16Pandemic ==  == 
cv_m16_pandemic <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_08')))) %>%
  filter(M16_A_08 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_08, m_16_sum, matches('M16_[A-Z]_08'))

# Not in the value set in M16Armed Conflict ==  == 
cv_m16_aconflict <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_09')))) %>%
  filter(M16_A_09 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_09, m_16_sum, matches('M16_[A-Z]_09'))

# Not in the value set in M16Others ==  == 
cv_m16_others <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M16_'))
  ) %>%
  mutate(m_16_sum = rowSums(select(., matches('M16_[A-Z]_10')))) %>%
  filter(M16_A_10 == 1, is.na(m_16_sum)) %>%
  select(case_id, pilot_area, M16_A_10, m_16_sum, matches('M16_[A-Z]_10'))


# Not in the value set in M17typhoon ==  == 
cv_m17_typhoon <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_01')))) %>%
  filter(M17_A_01 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_01, m_17_sum, matches('M17_[A-Z]_01'))

# Not in the value set in M17flood ==  == 
cv_m17_flood <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_02')))) %>%
  filter(M17_A_02 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_02, m_17_sum, matches('M17_[A-Z]_02'))

# Not in the value set in M17drought ==  == 
cv_m17_drought <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_03')))) %>%
  filter(M17_A_03 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_03, m_17_sum, matches('M17_[A-Z]_03'))

# Not in the value set in M17Earthquake ==  == 
cv_m17_equake <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_04')))) %>%
  filter(M17_A_04 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_04, m_17_sum, matches('M17_[A-Z]_04'))

# Not in the value set in M17Volcanic Eruption ==  == 
cv_m17_veruption <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_05')))) %>%
  filter(M17_A_05 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_05, m_17_sum, matches('M17_[A-Z]_05'))

# Not in the value set in M17Landslide ==  == 
cv_m17_landslide<- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_06')))) %>%
  filter(M17_A_06 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_06, m_17_sum, matches('M17_[A-Z]_06'))

# Not in the value set in M17Fire ==  == 
cv_m17_fire <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_07')))) %>%
  filter(M17_A_07 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_07, m_17_sum, matches('M17_[A-Z]_07'))

# Not in the value set in M17Pandemic ==  == 
cv_m17_pandemic <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_08')))) %>%
  filter(M17_A_08 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_08, m_17_sum, matches('M17_[A-Z]_08'))

# Not in the value set in M17Armed Conflict ==  == 
cv_m17_aconflict <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_09')))) %>%
  filter(M17_A_09 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_09, m_17_sum, matches('M17_[A-Z]_09'))

# Not in the value set in M17Others ==  == 
cv_m17_others <- section_m %>%
  select(case_id, 
         pilot_area, 
         starts_with(c('M13', 'M17_'))
  ) %>%
  mutate(m_17_sum = rowSums(select(., matches('M17_[A-Z]_10')))) %>%
  filter(M17_A_10 == 1, is.na(m_17_sum)) %>%
  select(case_id, pilot_area, M17_A_10, m_17_sum, matches('M17_[A-Z]_10'))


# M20a to M20g must be blank
cv_m20_a <- section_m %>% 
  filter((M19_01 %in% c(1:2)), (!is.na(M20_01)), M18_A == 1) %>%
  select(case_id, pilot_area, M19_01, M20_01)

cv_m20_b <- section_m %>% 
  filter((M19_02 %in% c(1:2)), (!is.na(M20_02)), M18_A == 1) %>%
  select(case_id, pilot_area, M19_02, M20_02)

cv_m20_c <- section_m %>% 
  filter((M19_03 %in% c(1:2)), (!is.na(M20_03)), M18_A == 1) %>%
  select(case_id, pilot_area, M19_03, M20_03)

cv_m20_d <- section_m %>% 
  filter((M19_04 %in% c(1:2)), (!is.na(M20_04)), M18_A == 1) %>%
  select(case_id, pilot_area, M19_04, M20_04)

cv_m20_e <- section_m %>% 
  filter((M19_05 %in% c(1:2)), (!is.na(M20_05)), M18_A == 1) %>%
  select(case_id, pilot_area, M19_05, M20_05)

cv_m20_f <- section_m %>% 
  filter((M19_06 %in% c(1:2)), (!is.na(M20_06)), M18_A == 1) %>%
  select(case_id, pilot_area, M19_06, M20_06)

cv_m20_g <- section_m %>% 
  filter((M19_07 %in% c(1:2)), (!is.na(M20_07)), M18_A == 1) %>%
  select(case_id, pilot_area, M19_07, M20_07)

# M20H less than or equal to 0
cv_m20_h1 <- section_m %>% 
  filter(M18_A == 1, M19_08 == 1, (M20_08 < 0 |M20_08 == 0)) %>%
  select(case_id, pilot_area, M19_08, M20_08)

# M20I less than or equal to 0
cv_m20_i1 <- section_m %>% 
  filter(M18_A == 1, M19_09 == 1, (M20_09< 0 |M20_09 == 0)) %>%
  select(case_id, pilot_area, M19_09, M20_09)

# M20J less than or equal to 0
cv_m20_j1 <- section_m %>% 
  filter(M18_A == 1, M19_10 == 1, (M20_10< 0 |M20_10 == 0)) %>%
  select(case_id, pilot_area, M19_10, M20_10)

# M20K less than or equal to 0
cv_m20_k1 <- section_m %>% 
  filter(M18_A == 1, M19_11 == 1, (M20_11< 0 |M20_11 == 0)) %>%
  select(case_id, pilot_area, M19_11, M20_11)

# M20L less than or equal to 0
cv_m20_l2 <- section_m %>% 
  filter(M18_A == 1, M19_12 == 1, (M20_12< 0 |M20_12 == 0)) %>%
  select(case_id, pilot_area, M19_12, M20_12)

# M20M less than or equal to 0
cv_m20_m1 <- section_m %>% 
  filter(M18_A == 1, M19_13 == 1, (M20_13< 0 |M20_13 == 0)) %>%
  select(case_id, pilot_area, M19_13, M20_13)

# M20N less than or equal to 0
cv_m20_n1 <- section_m %>% 
  filter(M18_A == 1, M19_14 == 1, (M20_14< 0 |M20_14 == 0)) %>%
  select(case_id, pilot_area, M19_14, M20_14)

# M20O less than or equal to 0
cv_m20_o1 <- section_m %>% 
  filter(M18_A == 1, M19_15 == 1, (M20_15< 0 |M20_15 == 0)) %>%
  select(case_id, pilot_area, M19_15, M20_15)

# M20P less than or equal to 0
cv_m20_p1 <- section_m %>% 
  filter(M18_A == 1, M19_16 == 1, (M20_16< 0 |M20_16 == 0)) %>%
  select(case_id, pilot_area, M19_16, M20_16)

# M20Q less than or equal to 0
cv_m20_q1 <- section_m %>% 
  filter(M18_A == 1, M19_17 == 1, (M20_17< 0 |M20_17 == 0)) %>%
  select(case_id, pilot_area, M19_17, M20_17)

# M19 is 1 but M20H is blank
cv_m20_h2 <- section_m %>% 
  filter(M18_A == 1, M19_08 == 1, (is.na(M20_08))) %>%
  select(case_id, pilot_area, M19_08, M20_08)

# M19 is 1 but M20I is blank
cv_m20_i2 <- section_m %>% 
  filter(M18_A == 1, M19_09 == 1, (is.na(M20_09))) %>%
  select(case_id, pilot_area, M19_09, M20_09)

# M19 is 1 but M20J is blank
cv_m20_j2 <- section_m %>% 
  filter(M18_A == 1, M19_10 == 1, (is.na(M20_10))) %>%
  select(case_id, pilot_area, M19_10, M20_10)

# M19 is 1 but M20K is blank
cv_m20_k2 <- section_m %>% 
  filter(M18_A == 1, M19_11 == 1, (is.na(M20_11))) %>%
  select(case_id, pilot_area, M19_11, M20_11)

# M19 is 1 but M20L is blank
cv_m20_l2 <- section_m %>% 
  filter(M18_A == 1, M19_12 == 1, (is.na(M20_12))) %>%
  select(case_id, pilot_area, M19_12, M20_12)
# M19 is 1 but M20M is blank
cv_m20_m2 <- section_m %>% 
  filter(M18_A == 1, M19_13 == 1, (is.na(M20_13))) %>%
  select(case_id, pilot_area, M19_13, M20_13)
# M19 is 1 but M20N is blank
cv_m20_n2 <- section_m %>% 
  filter(M18_A == 1, M19_14 == 1, (is.na(M20_14))) %>%
  select(case_id, pilot_area, M19_14, M20_14)

# M19 is 1 but M20O is blank
cv_m20_o2 <- section_m %>% 
  filter(M18_A == 1, M19_15 == 1, (is.na(M20_15))) %>%
  select(case_id, pilot_area, M19_15, M20_15)

#  M19 is 1 but M20P is blank
cv_m20_p2 <- section_m %>% 
  filter(M18_A == 1, M19_16 == 1, (is.na(M20_16))) %>%
  select(case_id, pilot_area, M19_16, M20_16)
# M19 is 1 but M20P is blank
cv_m20_q2 <- section_m %>% 
  filter(M18_A == 1, M19_17 == 1, (is.na(M20_17))) %>%
  select(case_id, pilot_area, M19_17, M20_17)
# M19 is 1 but M20Z is blank
cv_m20_z2 <- section_m %>% 
  filter(M18_A == 1, M19_18 == 1, (is.na(M20_18))) %>%
  select(case_id, pilot_area, M19_18, M20_18)


# M-2 == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == 

# M19 is 1 but M22_a is NA
cv_m22_1_food <- section_m %>% 
  select(case_id, pilot_area, M19_01, M22_01) %>% 
  filter(M19_01 == 1, is.na(M22_01)) 

# M19 is 2 but M22_a have entry
cv_m22_1.2_food <- section_m %>% 
  select(case_id, pilot_area, M19_01, M22_01) %>% 
  filter(M19_01 == 2, !is.na(M22_01)) 

# M19 is 1 but M22_b is NA
cv_m22_2_maintenance <- section_m %>% 
  select(case_id, pilot_area, M19_02, M22_02) %>% 
  filter(M19_02 == 1, is.na(M22_02)) 

# M19 is 2 but M22_b have entry
cv_m22_2.2_maintenance <- section_m %>% 
  select(case_id, pilot_area, M19_02, M22_02) %>% 
  filter(M19_02 == 2, !is.na(M22_02))   

# M19 is 1 but M22_c is NA
cv_m22_3_clothes <- section_m %>% 
  select(case_id, pilot_area, M19_03, M22_03) %>% 
  filter(M19_03 == 1, is.na(M22_03)) 

# M19 is 2 but M22_c have entry
cv_m22_3.2_clothes <- section_m %>% 
  select(case_id, pilot_area, M19_03, M22_03) %>% 
  filter(M19_03 == 2, !is.na(M22_03))  

# M19 is 1 but M22_d is NA
cv_m22_4_needs <- section_m %>% 
  select(case_id, pilot_area, M19_04, M22_04) %>% 
  filter(M19_04 == 1, is.na(M22_04)) 

# M19 is 2 but M22_d have entry
cv_m22_4.2_needs <- section_m %>% 
  select(case_id, pilot_area, M19_04, M22_04) %>% 
  filter(M19_04 == 2, !is.na(M22_04))  

# M19 is 1 or 2 but M22_e have entry
cv_m22_5_medical <- section_m %>% 
  select(case_id, pilot_area, M19_05, M22_05) %>% 
  filter((M19_05 %in% c(1, 2)), !is.na(M22_05)) 

# M19 is 1 or 2 but M22_f have entry
cv_m22_6_money <- section_m %>% 
  select(case_id, pilot_area, M19_06, M22_06) %>% 
  filter((M19_06 %in% c(1, 2)), !is.na(M22_06)) 

# M19 is 1 or 2 but M22_g have entry
cv_m22_7_documents <- section_m %>% 
  select(case_id, pilot_area, M19_07, M22_07) %>% 
  filter((M19_07 %in% c(1, 2)), !is.na(M22_07))

# M19 is 1 but M22_h is NA
cv_m22_8_water <- section_m %>% 
  select(case_id, pilot_area, M19_08, M22_08) %>% 
  filter(M19_08 == 1, is.na(M22_08)) 

# M19 is 2 but M22_h have entry
cv_m22_8.2_water <- section_m %>% 
  select(case_id, pilot_area, M19_08, M22_08) %>% 
  filter(M19_08 == 2, !is.na(M22_08)) 

# M19 is 1 but M22_i is NA
cv_m22_9_lighter <- section_m %>% 
  select(case_id, pilot_area, M19_09, M22_09) %>% 
  filter(M19_09 == 1, is.na(M22_09)) 

# M19 is 2 but M22_i have entry
cv_m22_9.2_lighter <- section_m %>% 
  select(case_id, pilot_area, M19_09, M21_09) %>% 
  filter(M19_09 == 2, !is.na(M21_09)) 

# M19 is 1 but M22_j is NA
cv_m22_10_candle <- section_m %>% 
  select(case_id, pilot_area, M19_10, M22_10) %>% 
  filter(M19_10 == 1, is.na(M22_10)) 

# M19 is 2 but M22_j have entry
cv_m22_10.2_candle <- section_m %>% 
  select(case_id, pilot_area, M19_10, M22_10) %>% 
  filter(M19_10 == 2, !is.na(M22_10)) 

# M19 is 1 but M22_k is NA
cv_m22_11_battery <- section_m %>% 
  select(case_id, pilot_area, M19_11, M22_11) %>% 
  filter(M19_11 == 1, is.na(M22_11)) 

# M19 is 2 but M22_k have entry
cv_m22_11.2_battery <- section_m %>% 
  select(case_id, pilot_area, M19_11, M22_11) %>% 
  filter(M19_11 == 2, !is.na(M22_11)) 

# M19 is 1 but M22_l is NA
cv_m22_12_masks <- section_m %>% 
  select(case_id, pilot_area, M19_12, M22_12) %>% 
  filter(M19_12 == 1, is.na(M22_12)) 

# M19 is 2 but M22_l have entry
cv_m22_12.2_masks <- section_m %>% 
  select(case_id, pilot_area, M19_12, M22_12) %>% 
  filter(M19_12 == 2, !is.na(M22_12)) 

# M19 is 1 or 2 but M22_m have entry
cv_m22_13_flashlight<- section_m %>% 
  select(case_id, pilot_area, M19_13, M22_13) %>% 
  filter((M19_13 %in% c(1, 2)), !is.na(M22_13))

# M19 is 1 or 2 but M22_n have entry
cv_m22_14_radio <- section_m %>% 
  select(case_id, pilot_area, M19_14, M22_14) %>% 
  filter((M19_14 %in% c(1, 2)), !is.na(M22_14))

# M19 is 1 or 2 but M22_o have entry
cv_m22_15_whistle <- section_m %>% 
  select(case_id, pilot_area, M19_15, M22_15) %>% 
  filter((M19_15 %in% c(1, 2)), !is.na(M22_15))

# M19 is 1 or 2 but M22_p have entry
cv_m22_16_blanket <- section_m %>% 
  select(case_id, pilot_area, M19_16, M22_16) %>% 
  filter((M19_16 %in% c(1, 2)), !is.na(M22_16))

# M19 is 1 or 2 but M22_q have entry
cv_m22_17_cellphone <- section_m %>% 
  select(case_id, pilot_area, M19_17, M22_17) %>% 
  filter((M19_17 %in% c(1, 2)), !is.na(M22_17))

# M19 is 1 but M22_z is NA
cv_m22_18_Others <- section_m %>% 
  select(case_id, pilot_area, M19_18, M22_18) %>% 
  filter(M19_18 == 1, is.na(M22_18)) 

# M19 is 2 but M22_z have entry
cv_m22_18.2_Others <- section_m %>% 
  select(case_id, pilot_area, M19_18, M22_18) %>% 
  filter(M19_18 == 2, !is.na(M22_18))

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#  Display Sum of all answers in M21
cv_m23 <- section_m %>%
  select(case_id, pilot_area, starts_with(c('M21_', 'M23'))) %>% 
  mutate(sum_m21 = rowSums(select(., M21_01:M21_18))) %>% 
  filter(sum_m21 != M23)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

rm(section_m)

print('Section M complete!')