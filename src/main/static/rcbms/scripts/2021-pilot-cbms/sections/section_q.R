#CONSISTENCY CHECK
#HPQ. Q. WATER, SANITATION, AND HYGIENE
print('Processing Section Q...')

section_q <- hpq_data$SECTION_Q %>%
  left_join(rov, by = 'case_id') %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
  select(case_id, pilot_area, starts_with('Q'), -contains('SPECIFY')) %>% 
  collect()

cv_mws_p_b <- section_q %>% 
  select (case_id, pilot_area, Q1) %>% 
  filter(is.na(Q1) | grepl('\\s', Q1))

#MWS not in valueset (Q1) (n=0)
cv_mws_nvs <- section_q %>% 
  select (case_id, pilot_area, Q1) %>% 
  filter(!(Q1 %in% c(NA, 1:10, 99)))

#MWS skipping (Q1 v Q2), must be blank (n=0)
cv_mws_skp_nb <- section_q %>% 
  select(case_id, pilot_area, Q1, Q2) %>%
  filter(Q1 %in% c(1, 9, 10), !is.na(Q2))

#MWS conditional (Q1 v Q2), must not be blank and not zero (n=329)
cv_mws_c_b <- section_q %>% 
  select(case_id, pilot_area, Q1, Q2) %>% 
  filter(Q1 %in% c(2, 3, 5:8, 99), is.na(Q2))

#================================================================   
#B_drinking water source DWS (Q3,Q5:Q9)
#================================================================

#DWS primary (Q3), must not be blank 
cv_dws_p_b <- section_q %>% 
  select(case_id, pilot_area, Q3) %>% 
  filter(is.na(Q3) | grepl('\\s', Q3))

#DWS not in valueset (a: Q3)
cv_dws_nvs1 <-  section_q %>% 
  select(case_id, pilot_area, Q3) %>% 
  filter(!(Q3 %in% c(NA,11:14,21,31,32,41,42,51,61,71,72,81,91,92,99)))

#DWS not in valueset (b: Q4)
cv_dws_nvs2 <-  section_q %>% 
  select(case_id, pilot_area, Q4) %>% 
  filter(!(Q4 %in% c(NA,11:14,21,31,32,41,42,51,61,71,72,81,91,92,99)))

#DWS not in valueset (c: Q5)
cv_dws_nvs3 <-  section_q %>% 
  select(case_id, pilot_area, Q5) %>% 
  filter(!(Q5 %in% c(NA,1,2,3)))

#DWS not in valueset (d: Q6)
cv_dws_nvs4 <-  section_q %>% 
  select(case_id, pilot_area, Q5, Q6) %>% 
  filter(Q5 == 3, is.na(Q6))

#DWS not in valueset (e: Q7)
cv_dws_nvs5 <-  section_q %>% 
  select(case_id, pilot_area, Q7) %>% 
  filter(!is.na(Q7) & Q7 == 0 & (Q7 > 99999))

#preliminary for cv_dws6_nvs Q8 vs count LINENO	
lncount_from_hpq_indiv <- hpq_individual %>% 
  select(case_id, LINENO) %>%  
  group_by(case_id) %>% 
  nest() %>% 
  mutate(count = map_int(data, nrow)) %>% 
  select(-data)

#DWS not in valueset (f: Q8)
cv_dws_nvs6 <- section_q %>% 
  select(case_id, pilot_area, Q8) %>% 
  filter(!is.na(Q8) & Q8 != 96) %>% 
  full_join(lncount_from_hpq_indiv, by = 'case_id') %>% 
  filter(Q8 > count)

#DWS not in valueset (g: Q9)
cv_dws_nvs7 <-  section_q %>% 
  select(case_id, pilot_area, Q9) %>% 
  filter(Q9 > 98)

#DWS skipping (a: Q3, Q4), must be blank
cv_dws_skp1_nb <- section_q %>% 
  select(case_id, pilot_area, Q3, Q4) %>%
  filter(Q3 %in% c(13,14,21,31,32,41,42,51,61,71,81,99), !is.na(Q4))

#DWS skipping (b: Q3:Q9), must be blank
cv_dws_skp2_nb <- section_q %>% 
  select(case_id, pilot_area, Q3:Q9) %>%
  filter(Q3 %in% c(11,12), !is.na(Q4) | !is.na(Q5) |
           !is.na(Q6) | !is.na(Q7) | !is.na(Q8) | !is.na(Q9))

#DWS conditional (a: Q3 v Q5), must not be blank
cv_dws_c1_b <- section_q %>% 
  select(case_id, pilot_area, Q3, Q5) %>% 
  filter(is.na(Q3 %in% c(13,14,21,31,32,41,42,51,61,71,81,99)), is.na(Q5))

#DWS conditional (b: Q5 v Q6), must not be blank
cv_dws_c2_b <- section_q %>% 
  select(case_id, pilot_area, Q5, Q6) %>% 
  filter(Q5 == 3, is.na(Q6))

#DWS conditional (c: Q6 v Q7), must not be blank
cv_dws_c3_b <- section_q %>% 
  select(case_id, pilot_area, Q6, Q7) %>% 
  filter(Q6 != 000 & !is.na(Q6), is.na(Q7))

#DWS conditional (d: Q6 v Q8), must not be blank
cv_dws_c4_b <- section_q %>% 
  select(case_id, pilot_area, Q6, Q8) %>% 
  filter(Q6 != 000 & !is.na(Q6), is.na(Q8))

#DWS conditional (e: Q6 v Q9), must not be blank
cv_dws_c5_b <- section_q %>% 
  select(case_id, pilot_area, Q6, Q9) %>% 
  filter(Q6 != 000 & !is.na(Q6), is.na(Q9))   


#================================================================    
#C_cooking and handwashing water source CHWS (Q4)
#================================================================  

#CHWS conditional (Q3 v Q4), must not be blank
cv_chws_c_b <- section_q %>% 
  select(case_id, pilot_area, Q3, Q4) %>% 
  filter(is.na(Q3 %in% c(72,91,92)), is.na(Q4) | Q4 == 0)    


#================================================================
#D_drinking water insufficiency WINSUF(Q10,Q11)
#================================================================ 

#WINSUF primary (Q10), must not be blank
cv_winsuf_p_b <- section_q %>% 
  select(case_id, pilot_area, Q10) %>% 
  filter(is.na(Q10) | grepl('\\s', Q10))

#WINSUF not in valueset (a: Q10)
cv_winsuf_nvs1 <- section_q %>% 
  select (case_id, pilot_area, Q10) %>% 
  filter(!(Q10 %in% c(NA,1,2,8)))

#WINSUF not in valueset (b: Q11)
cv_winsuf_nvs2 <- section_q %>% 
  select (case_id, pilot_area, Q10, Q11) %>% 
  filter(!(Q11 %in% c(NA,1,2,3,8,9)))

#WINSUF skipping (Q10 v Q11), must be blank
cv_winsuf_skp_nb <- section_q %>% 
  select(case_id, pilot_area, Q10, Q11) %>% 
  filter((Q10 %in% c(2,8)), !is.na(Q11))

#WINSUF conditional (Q10 v Q11), must not be blank
cv_winsuf_c_b <- section_q %>% 
  select(case_id, pilot_area, Q10, Q11) %>% 
  filter(Q10 == 1, is.na(Q11))


#================================================================   
#E_drinking water treatment WTRT (Q12,Q13)
#================================================================     

#WTRT primary (Q12), must not be blank
cv_wtrt_p_b <- section_q %>% 
  select(case_id, pilot_area, Q12) %>% 
  filter(is.na(Q12) | grepl('\\s', Q12))

#WTRT not in valueset (a: Q12)
cv_wtrt_nvs1 <- section_q %>% 
  select (case_id, pilot_area, Q12) %>% 
  filter(!(Q12 %in% c(NA,1,2,8)))

#WTRT not in valueset (b: Q13)
cv_wtrt_nvs2 <- section_q %>% 
  select (case_id, pilot_area, Q12, Q13) %>% 
  filter(Q12 == 1, (!(grepl('[A-FXZ]+', str_trim(Q13)))) | str_trim(Q13) == '')

#WTRT skipping (Q12 v Q13), must be blank 
cv_wtrt_skp1_nb <- section_q %>% 
  select(case_id, pilot_area, Q12, Q13) %>%
  filter((Q12 == 2 | Q12 == 8), ((grepl('[ABCDEFXZ]', Q13))))

#WTRT conditional (Q12 v Q13), must not be blank
cv_wtrt_c_b <- section_q %>% 
  select(case_id, pilot_area, Q12, Q13) %>% 
  filter(Q12 == 1, is.na(Q13))


# ===================================================================================================

#TOILFAC primary (a: Q14), must not be blank
cv_toilfac_p1_b <- section_q %>% 
  select(case_id, pilot_area, Q14) %>% 
  filter(is.na(Q14) | grepl('\\s', Q14))

#TOILFAC primary (b: Q18), must not be blank
cv_toilfac_p2_b <- section_q %>% 
  select(case_id, pilot_area, Q14, Q18) %>% 
  filter(!(Q14 %in% c(71, 95)), is.na(Q18))

#TOILFAC not in valueset (a: Q14)
cv_toilfac_nvs1 <- section_q %>% 
  select(case_id, pilot_area, Q14) %>% 
  filter(!(Q14 %in% c(NA, 11:15, 21:23, 31, 41, 51, 71, 95, 99)))

#TOILFAC not in valueset (b: Q15)
cv_toilfac_nvs2 <- section_q %>% 
  select(case_id, pilot_area, Q15) %>% 
  filter(!(Q15 %in% c(NA, 1:5, 8, 9)))

#TOILFAC not in valueset (c: Q16)
cv_toilfac_nvs3 <- section_q %>% 
  select (case_id, pilot_area, Q16) %>% 
  filter (!(Q16 %in% c(NA, 1:6, 8)))

#TOILFAC not in valueset (d: Q17)
cv_toilfac_nvs4 <- section_q %>% 
  select (case_id, pilot_area, Q17) %>% 
  filter (!(Q17 %in% c(NA,1:5,8,9)))

#TOILFAC not in valueset (a: Q18)
cv_toilfac_nvs5 <- section_q %>% 
  select (case_id, pilot_area, Q18) %>% 
  filter (!(Q18 %in% c(NA,1,2,3)))

#TOILFAC skipping (a: Q14 v Q15), must be blank
cv_toilfac_skp1_nb <- section_q %>% 
  select(case_id, pilot_area, Q14, Q15) %>%
  filter((Q14 %in% c(13,21,22,23,31)), !is.na(Q15))

#TOILFAC skipping (b: Q14:Q17), must be blank
cv_toilfac_skp2_nb <- section_q %>% 
  select(case_id, pilot_area, Q14:Q17) %>%
  filter((Q14 %in% c(11,14,15,41,51,99)), 
         !is.na(Q15) | !is.na(Q16) | !is.na(Q17))

#TOILFAC skipping (c: Q14:Q21), must be blank
cv_toilfac_skp3_nb <- section_q %>% 
  select(case_id, pilot_area, Q14:Q21) %>%
  filter((Q14 %in% c(71,95)), !is.na(Q15) | !is.na(Q16) | !is.na(Q17) | !is.na(Q18) | !is.na(Q19) | !is.na(Q20) | !is.na(Q21))

#TOILFAC skipping (d: Q16 v Q17), must be blank
cv_toilfac_skp4_nb <- section_q %>% 
  select(case_id, pilot_area, Q16, Q17) %>%
  filter((Q16 %in% c(4,5,6,8)), !is.na(Q17)) 

#TOILFAC conditional (a: Q14 v Q15), must not be blank
cv_toilfac_c1_b <- section_q %>% 
  select(case_id, pilot_area, Q14, Q15) %>% 
  filter(Q14 == 12, is.na(Q15))

#TOILFAC conditional (a: Q16 v Q17), must not be blank
cv_toilfac_c2_b <- section_q %>% 
  select(case_id, pilot_area, Q16, Q17) %>% 
  filter((Q16 %in% c(1,2,3)), is.na(Q17))

#=================================================================  
#G_toilet facility usage TOILFACUSE (Q19:Q21)
#=================================================================      

# TOILFACUSE primary (Q19), must not be blank
cv_toilfacuse_p_b <- section_q %>% 
  select(case_id, pilot_area, Q14, Q18, Q19) %>% 
  filter(!(Q14 %in% c(71, 95)), Q18 != 3, is.na(Q19))

#TOILFACUSE not in value set (a: Q19)
cv_toilfacuse_nvs1 <- section_q %>% 
  select(case_id, pilot_area, Q19) %>% 
  filter(!(Q19 %in% c(NA,1,2)))

#TOILFACUSE not in value set (b: Q20)
#cv_toilfacuse_nvs2 <- section_q %>% 
 # select(case_id, pilot_area, Q20) %>% 
#  filter((!(Q20 %in% c(NA, 2:10))))

#TOILFACUSE not in value set (c: Q21)
cv_toilfacuse_nvs3 <- section_q %>% 
  select (case_id, pilot_area, Q21) %>% 
  filter (!(Q21 %in% c(NA, 1, 2)))

#TOILFACUSE skipping (Q19:Q21), must be blank
cv_toilfacuse_skp_nb <- section_q %>% 
  select(case_id, pilot_area, Q19:Q21) %>%
  filter(Q19 == 2, !is.na(Q20) | !is.na(Q21))

#TOILFACUSE conditional, must not be blank
cv_toilfacuse_c_b <- section_q %>% 
  select(case_id, pilot_area, Q19:Q21) %>%
  filter(Q19 == 1, is.na(Q20) & is.na(Q21))

#=================================================================  
#H_garbage disposal GARBDISP (Q22)
#================================================================= 

#GARBDISP primary, must not be blank
cv_garbdisp_p_b <- section_q %>% 
  select(case_id, starts_with('Q22_')) %>% 
  mutate(sum_Q22 = rowSums(select(.,Q22_A:Q22_Z))) %>% 
  filter(sum_Q22 < 20 & is.na(sum_Q22) & sum_Q22 != 0, grepl('\\s', sum_Q22))

#GARBDISP not in valueset (a: Q22_A)
cv_garbdisp_nvs1 <- section_q %>% 
  select (case_id, pilot_area, Q22_A) %>% 
  filter (!(Q22_A %in% c(NA,1,2)))

#GARBDISP not in valueset (b: Q22_B)
cv_garbdisp_nvs2 <- section_q %>% 
  select (case_id, pilot_area, Q22_B) %>% 
  filter (!(Q22_B %in% c(NA,1,2)))

#GARBDISP not in valueset (c: Q22_C)
cv_garbdisp_nvs3 <- section_q %>% 
  select (case_id, pilot_area, Q22_C) %>% 
  filter (!(Q22_C %in% c(NA,1,2)))

#GARBDISP not in valueset (d: Q22_D)
cv_garbdisp_nvs4 <- section_q %>% 
  select (case_id, pilot_area, Q22_D) %>% 
  filter (!(Q22_D %in% c(NA,1,2)))

#GARBDISP not in valueset (e: Q22_E)
cv_garbdisp_nvs5 <- section_q %>% 
  select (case_id, pilot_area, Q22_E) %>% 
  filter (!(Q22_E %in% c(NA,1,2)))

#GARBDISP not in valueset (f: Q22_F)
cv_garbdisp_nvs6 <- section_q %>% 
  select (case_id, pilot_area, Q22_F) %>% 
  filter (!(Q22_F %in% c(NA,1,2)))

#GARBDISP not in valueset (g: Q22_G)
cv_garbdisp_nvs7 <- section_q %>% 
  select (case_id, pilot_area, Q22_G) %>% 
  filter (!(Q22_G %in% c(NA,1,2)))

#GARBDISP not in valueset (h: Q22_H)
cv_garbdisp_nvs8 <- section_q %>% 
  select (case_id, pilot_area, Q22_H) %>% 
  filter (!(Q22_H %in% c(NA,1,2)))

#GARBDISP not in valueset (i: Q22_I)
cv_garbdisp_nvs9 <- section_q %>% 
  select (case_id, pilot_area, Q22_I) %>% 
  filter (!(Q22_I %in% c(NA,1,2)))

#GARBDISP not in valueset (j: Q22_Z)
cv_garbdisp_nvs10 <- section_q %>% 
  select (case_id, pilot_area, Q22_Z) %>% 
  filter (!(Q22_Z %in% c(NA,1,2)))

#=================================================================  
#I_handwashing area HWA (Q23:Q30)
#================================================================= 

#HWA primary (a: Q23), must not be blank
cv_hwa_p1_b <- section_q %>% 
  select(case_id, pilot_area, Q23) %>% 
  filter(is.na(Q23) | grepl('\\s', Q23))

#HWA primary (b: Q24), must not be blank
cv_hwa_p2_b <- section_q %>% 
  select(case_id, pilot_area, Q23, Q24) %>% 
  filter(Q23 %in% c(1, 2, 3), is.na(Q24) | grepl('\\s', Q24))

#HWA primary (c: Q25), must not be blank
cv_hwa_p3_b <- section_q %>% 
  select(case_id, pilot_area, Q23, Q25) %>% 
  filter(Q23 %in% c(1, 2, 3), is.na(Q25) | grepl('\\s', Q25))

#HWA not in valueset (a: Q23)
cv_hwa_nvs1 <- section_q %>% 
  select (case_id, pilot_area, Q23) %>% 
  filter (!(Q23 %in% c(NA,1:5,9)))

#HWA not in valueset (b: Q24)
cv_hwa_nvs2 <- section_q %>% 
  select (case_id, pilot_area, Q24) %>% 
  filter (!(Q24 %in% c(NA,1,2)))

#HWA not in valueset (c: Q25)
cv_hwa_nvs3 <- section_q %>% 
  select (case_id, pilot_area, Q25) %>% 
  filter (!(Q25 %in% c(NA,1,2)))

#HWA not in valueset (d: Q26)
cv_hwa_nvs4 <- section_q %>% 
  select (case_id, pilot_area, Q26) %>% 
  filter (!(Q26 %in% c(NA,1:4,9)))

#HWA not in valueset (e: Q27)
cv_hwa_nvs5 <- section_q %>% 
  select (case_id, pilot_area, Q27) %>% 
  filter (!(Q27 %in% c(NA,1,2)))

#HWA not in valueset (f: Q28)
cv_hwa_nvs6 <- section_q %>% 
  select (case_id, pilot_area, Q28) %>% 
  filter (!(Q28 %in% c(NA,1,2)))

#HWA not in valueset (g: Q29)
cv_hwa_nvs7 <- section_q %>% 
  select (case_id, pilot_area, Q29) %>% 
  filter (!(Q29 %in% c(NA,1,2)))

#HWA not in valueset (h: Q30)
cv_hwa_nvs8 <- section_q %>% 
  select(case_id, pilot_area, Q28, Q29, Q30) %>% 
  filter(Q28 == 1, Q29 == 1, !(grepl('[ABCDZ]', Q30)))

#HWA skipping (a: Q28:Q30), must be blank
cv_hwa_skp1_nb <- section_q %>%
  select(case_id, pilot_area, Q28:Q30) %>% 
  filter (Q28 == 2, !is.na(Q29) | !is.na(Q30))

#HWA skipping (b: Q29 v Q30), must be blank === false result
cv_hwa_skp2_nb <- section_q %>%
  select(case_id, pilot_area, Q29, Q30) %>% 
  filter (Q29 == 2, !is.na(Q30) | Q30 != "")

#HWA conditional (a: Q28 v Q29), must not be blank
cv_hwa_c1_b <- section_q %>%
  select(case_id, pilot_area, Q28, Q29) %>% 
  filter(Q28 == 1, is.na(Q29) | Q29 == "")

#HWA conditional (b: Q29 v Q30), must not be blank
cv_hwa_c2_b <- section_q %>%
  select(case_id, pilot_area, Q29, Q30) %>% 
  filter(Q29 == 1, is.na(Q30) | Q30 == "")

#=================================================================  
#End code for HPQ section Q
#=================================================================
rm(section_q)

