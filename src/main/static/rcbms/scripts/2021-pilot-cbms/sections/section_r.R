#Section R====

print('Processing Section R...')

section_r <- hpq_data$SECTION_R %>%
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  select(case_id, pilot_area, starts_with('R'), -contains(c('REF', 'SPECIFY'))) %>% 
  collect()

#Not in the value set R01====
cv_r01  <- section_r %>% 
  filter(!(R1 %in% c(1:9))) %>%
  select(case_id, pilot_area, R1)

#NA in R02====
cv_r02  <- section_r %>% 
  filter(is.na(R2)) %>%
  select(case_id, pilot_area, R1, R2)

#Not in the value set R03====
cv_r03  <- section_r %>% 
  filter(!(R3 %in% c(1:7,9)),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R3)

#Not in the value set R03_1====
cv_r03_1  <- section_r %>% 
  filter(!(R3_1 %in% c(1:5,9)),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R3)

#Not in the value set R04====
cv_r04  <- section_r %>% 
  filter(!(R4 %in% c(01:12,99)),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R4)

#Not in the value set R05====
cv_r05  <- section_r %>% 
  filter(!(R5 %in% c(1:7,9)),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R5)

#Not in the value set R06====
cv_r06  <- section_r %>% 
  filter(!(R6 %in% c(1:6,9)),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R6)

#NA in R07====
cv_r07  <- section_r %>% 
  filter(is.na(R7),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R7)

#Not in the value set R08====
cv_r08  <- section_r %>% 
  filter(!(R8 %in% c(1:13,99)),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R8)

#NA in R09====
cv_r09  <- section_r %>% 
  filter(is.na(R9),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R9)

#NA in R10====
cv_r10  <- section_r %>% 
  filter(is.na(R10),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R10)

#NA in R10_1====
cv_r10_1  <- section_r %>% 
  filter(is.na(R10_1),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R10_1)

#NA in R11====

cv_r11  <- section_r %>% 
  filter(R10 != 5, is.na(R11),(R1 %in% c(1:7))) %>%
  select(case_id, pilot_area, R1, R11)

cv_r11_r10  <- section_r %>% 
  filter(R10 == 5, !is.na(R11)) %>%
  select(case_id, pilot_area, R1, R11)

#NA in R12====
cv_r12  <- section_r %>% 
  filter(is.na(R12)) %>%
  select(case_id, pilot_area, R1, R12)

#NA in R13A====
cv_r13a  <- section_r %>% 
  filter(is.na(R13_A),R12== 1) %>%
  select(case_id, pilot_area, R2, R13_A)

#NA in R13B====
cv_r13b  <- section_r %>% 
  filter(is.na(R13_B),R12== 1) %>%
  select(case_id, pilot_area, R2, R13_B)

#NA in R13C====
cv_r13C  <- section_r %>% 
  filter(is.na(R13_C),R12== 1) %>%
  select(case_id, pilot_area, R2, R13_C)

#NA in R13C====
cv_r13D <- section_r %>% 
  filter(is.na(R13_D),R12== 1) %>%
  select(case_id, pilot_area, R2, R13_D)

#NA in R13C====
cv_r13Z <- section_r %>% 
  filter(is.na(R13_Z),R12== 1) %>%
  select(case_id, pilot_area, R2, R13_Z)

#NA in R14====
cv_r14 <- section_r %>% 
  filter(is.na(R14)) %>%
  select(case_id, pilot_area, R12,R14)

#NA in R15====
cv_r15 <- section_r %>% 
  filter(is.na(R15)) %>%
  select(case_id, pilot_area, R1, R15)

#NA in R16A====
cv_r16_a <- section_r %>% 
  filter(!(R16_A %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_A)

#NA in R16B====
cv_r16_b <- section_r %>% 
  filter(!(R16_B %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_B)

#NA in R16C====
cv_r16_c <- section_r %>% 
  filter(!(R16_C %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_C)

#NA in R16C====
cv_r16_c <- section_r %>% 
  filter(!(R16_C %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_C)

#NA in R16D====
cv_r16_d <- section_r %>% 
  filter(!(R16_D %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_D)

#NA in R16E====
cv_r16_e <- section_r %>% 
  filter(!(R16_E %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_E)

#NA in R16F====
cv_r16_f <- section_r %>% 
  filter(!(R16_F %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_F)

#NA in R16G====
cv_r16_g <- section_r %>% 
  filter(!(R16_G %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_G)

#NA in R16H====
cv_r16_h <- section_r %>% 
  filter(!(R16_H %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_H)

#NA in R16I====
cv_r16_i <- section_r %>% 
  filter(!(R16_I %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_I)

#NA in R16J====
cv_r16_j <- section_r %>% 
  filter(!(R16_J %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_J)

#NA in R16K====
cv_r16_k <- section_r %>% 
  filter(!(R16_K %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_K)

#NA in R16L====
cv_r16_l <- section_r %>% 
  filter(!(R16_L %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_L)

#NA in R16M====

cv_r16_m <- section_r %>% 
  filter(!(R16_M %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_M)

#NA in R16N====
cv_r16_n <- section_r %>% 
  filter(!(R16_N %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_N)

#NA in R16O====
cv_r16_o <- section_r %>% 
  filter(!(R16_O %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_O)

#NA in R16P====
cv_r16_p <- section_r %>% 
  filter(!(R16_P %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_P)

#NA in R16Q====
cv_r16_q <- section_r %>% 
  filter(!(R16_Q %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_Q)

#NA in R16R====
cv_r16_r <- section_r %>% 
  filter(!(R16_R %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_R)

#NA in R16S====
cv_r16_s <- section_r %>% 
  filter(!(R16_S %in% c(00:99))) %>%
  select(case_id, pilot_area, R16_S)

#Not in the value set in R17
cv_r17_na <- section_r %>% 
  filter(!grepl('[A-E]', str_trim(R17)), R16_H == 1) %>%
  select(case_id, pilot_area, R17)

#R17 not na
cv_r17_notna <- section_r %>% 
  filter(str_trim(R17) != '', R16_H == 0) %>%
  select(case_id, pilot_area, R16_H, R17)


#NA in R18A====
cv_r18_a <- section_r %>% 
  filter(!(R18_A %in% c(0:99))) %>%
  select(case_id, pilot_area, R18_A)

#NA in R18B====
cv_r18_b <- section_r %>% 
  filter(!(R18_B %in% c(0:99))) %>%
  select(case_id, pilot_area, R18_B)

#NA in R18C====
cv_r18_c <- section_r %>% 
  filter(!(R18_C %in% c(00:99))) %>%
  select(case_id, pilot_area, R18_C)

#NA in R18D====
cv_r18_d <- section_r %>% 
  filter(!(R18_D %in% c(00:99))) %>%
  select(case_id, pilot_area, R18_D)

#NA in R18E====
cv_r18_d <- section_r %>% 
  filter(!(R18_E %in% c(00:99))) %>%
  select(case_id, pilot_area, R18_E)

#NA in R18F====
cv_r18_f <- section_r %>% 
  filter(!(R18_F %in% c(00:99))) %>%
  select(case_id, pilot_area, R18_F)

#NA in R18G====
cv_r18_g <- section_r %>% 
  filter(!(R18_G %in% c(00:99))) %>%
  select(case_id, pilot_area, R18_G)

#Check not na/blanks in R2 to R11 if R01 = 8:9 
cv_r01_1  <- section_r %>%
  select(case_id, pilot_area,R1:R11) %>% 
  mutate(r01_r11_sum = rowSums(select(., R1, R2, R3,R4,R5,R6,R7,R8,R9,R10)))%>%
  filter(R1 %in% c(8:9),is.na(r01_r11_sum))

#R05=concrete and R06 not concrete
cv_r05vsr06_1  <- section_r %>% 
  select (case_id,pilot_area,R5,R6) %>% 
  filter(R5==1, (R6!=1))

#R05=cement and R06 not concrete/earth/sand/mud
cv_r05vsr06_2  <- section_r %>% 
  select (case_id,pilot_area,R5,R6) %>% 
  filter(R5==2, !(R6 %in% c(1,  5)))

#R05=Wood plank and R06 not concrete/wood/earth/sand/mud
cv_r05vsr06_3  <- section_r %>% 
  select (case_id,pilot_area,R5,R6) %>% 
  filter(R5==3, !(R6 %in% c(1:2, 5)))

#R05=Wood tile/parquet and R06 not concrete/wood
cv_r05vsr06_4  <- section_r %>% 
  select (case_id,pilot_area,R5,R6) %>% 
  filter(R5==4, !(R6 %in% c(1:2)))

#R05=Vinyl/carpet and R06 not concrete/wood
cv_r05vsr06_5  <- section_r %>% 
  select (case_id,pilot_area,R5,R6) %>% 
  filter(R5==5, !(R6 %in% c(1:2)))

#R05=Linoleum and R06 not concrete/wood
cv_r05vsr06_6  <- section_r %>% 
  select (case_id,pilot_area,R5,R6) %>% 
  filter(R5==6, !(R6 %in% c(1:5)))

#If R01  - Type of building/house = 4/5 and R03- Roof = in 3:9 and R04 - Wall = 2:99

cv_r01vsr03vsr04  <- section_r %>% 
  select(case_id, pilot_area, R1, R3,R4) %>% 
  filter((R1 %in% c(4:5)),(R3 %in% c(3:9)),(R4 %in% c(2:99)))

# ====
cv_r01_other <- hpq_data$SECTION_R %>% 
  filter(R1 == 9, !is.na(R1_SPECIFY), HSN < 7777, pilot_area == eval_area) %>%
  select(case_id, R1, R1_SPECIFY) %>% 
  collect()
# 
# cv_r02_more_than_5 <- hpq_data$SECTION_R %>% 
#   filter(R2 >= 5, HSN < 7777, pilot_area == eval_area) %>% 
#   select(case_id, R2) %>% 
#   collect()

cv_r03_other <- hpq_data$SECTION_R %>% 
  filter(R3 == 9, !is.na(R3_SPECIFY), HSN < 7777, pilot_area == eval_area) %>%
  select(case_id, R3, R3_SPECIFY) %>% 
  collect()

cv_r03_1_other <- hpq_data$SECTION_R %>% 
  filter(R3_1 == 9, !is.na(R3_1_SPECIFY), HSN < 7777, pilot_area == eval_area) %>%
  select(case_id, R3_1, R3_1_SPECIFY) %>% 
  collect()

cv_r04_other <- hpq_data$SECTION_R %>% 
  filter(R4 == 99, !is.na(R4_SPECIFY), HSN < 7777, pilot_area == eval_area) %>%
  select(case_id, R4, R4_SPECIFY) %>% 
  collect()

cv_r05_other <- hpq_data$SECTION_R %>% 
  filter(R5 == 9, !is.na(R5_SPECIFY), HSN < 7777, pilot_area == eval_area) %>%
  select(case_id, R5, R5_SPECIFY) %>% 
  collect()

cv_r06_other <- hpq_data$SECTION_R %>% 
  filter(R6 == 9, !is.na(R6_SPECIFY), HSN < 7777, pilot_area == eval_area) %>%
  select(case_id, R6, R6_SPECIFY) %>% 
  collect()

cv_r08_other <- hpq_data$SECTION_R %>% 
  filter(R8 == 99, !is.na(R8_SPECIFY), HSN < 7777, pilot_area == eval_area) %>%
  select(case_id, R8, R8_SPECIFY) %>% 
  collect()

cv_r15_other <- hpq_data$SECTION_R %>% 
  filter(R15 == 9, !is.na(R15_SPECIFY), HSN < 7777, pilot_area == eval_area) %>%
  select(case_id, R15, R15_SPECIFY) %>% 
  collect()

#R02 - < 1 or >= 4 number of floors
cv_r02_number_of_floors  <- section_r %>% 
  select(case_id, pilot_area, R2) %>% 
  filter(R2 < 1, R2 >= 4)

#R07 - too small floor area
cv_r07_too_small_floor_area  <- section_r %>% 
  select(case_id, pilot_area, R7) %>% 
  filter(R7 <= 10)

#R07 - too big floor area
cv_r07_too_big_floor_area  <- section_r %>% 
  select(case_id, pilot_area, R7) %>% 
  filter(R7 >= 300)

#R09 - number of bedrooms >= 7
cv_r09_no_of_bedrooms  <- section_r %>% 
  select(case_id, pilot_area, R9) %>% 
  filter(R9 >= 7)

#R10.1 - construction year built 1945 or older
cv_r10_1_construction_year  <- section_r %>% 
  select(case_id, pilot_area, R10_1) %>% 
  filter(pilot_area == "City of Baguio", R10_1 <= 1945)

#R16 - HHs with motorized banca in Baguio City
cv_r16_motorized_banca  <- section_r %>% 
  select(case_id, pilot_area, R16_R) %>% 
  filter(pilot_area == "City of Baguio", R16_R > 0)

#If same BSN should be same type of building=====
rm(section_r)

# 
# print('Section R complete!')