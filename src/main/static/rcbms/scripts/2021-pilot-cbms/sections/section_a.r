# SECTION A

print('Processing Section A...')

section_a_reg <- hpq_individual %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1) %>% 
  mutate(A01HHMEM = str_trim(A01HHMEM)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, starts_with('A'))

# 1. ================================================================
# With household member but no info (NA) on A02 (relationship to the household head), 
# A05 (Sex), A07 (Age), and A09 (marital status)
cv_member_no_info <- section_a_reg %>%
  filter(
    is.na(LINENO),
    !(is.na(A01HHMEM) | A01HHMEM == ''), 
    is.na(A02RELHEAD) | is.na(A05SEX) | is.na(age_computed) | is.na(A09MARITALSTATUS)
  ) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD, A05SEX, age_computed, A06DATEBORN, A09MARITALSTATUS)

# 2. ================================================================
# Household head below 15 years old 
cv_hh_head_below_15 <- section_a_reg %>% 
  filter(A02RELHEAD == 1 & age_computed < 15) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD, age_computed)

# 3. =================================================================
# Household head with LINENO not equal to 1
cv_line_1_not_head <- section_a_reg %>% 
  filter(A02RELHEAD == 1 & LINENO > 1) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD, age_computed)

# 4. =====================================================================
# Special HSN with household members
cv_special_with_head <- hpq_individual %>%
  filter(HSN >= 7777, !is.na(LINENO), A01HHMEM != '') %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD, A05SEX)

# 5. =====================================================================
# Invalid name of household member
cv_invalid_name <- section_a_reg %>% 
  filter(
    A01HHMEM != '', 
    !grepl('[A-Z\u00d1 -]+\\,\\s?[A-Z\u00d1 -]+\\s?\\.?[A-Z0-9\u00d1 -]+', A01HHMEM)
  ) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM)

valid_name <- section_a_reg %>% 
  filter(
    A01HHMEM != '', 
    grepl('[A-Z\u00d1 -]+\\,\\s?[A-Z\u00d1 -]+\\s?\\.?[A-Z0-9\u00d1 -]+', A01HHMEM)
  ) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM)

# 6. =====================================================================
# Sex must not be blank
# cv_sex_blank <- section_a_reg %>% 
#   filter(is.na(A05SEX), A01HHMEM != '') %>% 
#   select(case_id, pilot_area, LINENO, A01HHMEM, A05SEX)
# 
# # Check consistency of sex count from household roster vs summary of visit


# 7. =============================================================
# Number of males from household roster vs summary of visit
# cv_male <- d_sex_pivot %>% 
#   filter(check_male == 0) %>% 
#   select(
#     case_id, 
#     pilot_area, 
#     'Male Count (From Summary of Visit)' = Male,
#     'Male Count (From Household Roster)' = NOMALES
#   )

# 8. =============================================================
# Number of females from household roster vs summary of visit
# cv_female <- d_sex_pivot %>% 
#   filter(check_female == 0) %>% 
#   select(
#     case_id, 
#     pilot_area, 
#     'Female Count (From Summary of Visit)' = Female,
#     'Female Count (From Household Roster)' = NOFEMALES
#   )


# ===========================================================================================
#Table 18
cv_a09_0to9_single <- hpq_individual %>% 
  filter(age_computed >= 0 & age_computed <= 9, A09MARITALSTATUS > 2 & A09MARITALSTATUS < 9) %>% 
  select(case_id, LINENO, A05SEX, age_computed, A09MARITALSTATUS)

cv_a09_10to14yo_divorced_annulled <- hpq_individual %>% 
  filter(age_computed >= 15 & age_computed <= 19, A09MARITALSTATUS > 4 & A09MARITALSTATUS < 8) %>% 
  select(case_id, LINENO, age_computed, A09MARITALSTATUS)

# ===========================================================================================
#HH member 100 years old and over
cv_age_100yo_and_over <- hpq_individual %>% 
  filter(age_computed >= 100) %>% 
  select(case_id, LINENO, age_computed, A05SEX)

# 9. =============================================================
# If relationship to the household head and male members is consistent
cv_relhead_sex_female <- section_a_reg %>% 
  filter(A02RELHEAD %in% c(4, 6, 8, 10, 12, 14, 16, 18, 20, 22), A05SEX == 1) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD, A05SEX)

# 10. =============================================================
# If relationship to the household head and female members is consistent
cv_relhead_sex_male <- section_a_reg %>% 
  filter(A02RELHEAD %in% c(3, 5, 7, 9, 11, 13, 15, 17, 19, 21), A05SEX == 2) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD, A05SEX)

# 11. =============================================================
# If relationship of head of nuclear family and male members is consistent
cv_relhnucfam_sex_female <- section_a_reg %>% 
  filter(A04RELHNUCFAM %in% c(5, 7, 9), A05SEX == 1) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A04RELHNUCFAM, A05SEX)

# 12. =============================================================
# If relationship of head of nuclear family and female members is consistent
cv_relhnucfam_sex_male <- section_a_reg %>% 
  filter(A04RELHNUCFAM %in% c(4, 6, 8), A05SEX == 2) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A04RELHNUCFAM, A05SEX)

# 13. =============================================================
# For ages 0-9 years, marital status should be single
cv_marital_status_below_10 <- section_a_reg %>% 
  filter(A09MARITALSTATUS %in% c(2, 3, 4, 5, 6, 7), age_computed < 10) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A09MARITALSTATUS)

# 14. =============================================================
# Spouse must not be single, widowed, divorced, separated, or annulled
cv_spouse_not_single <- section_a_reg %>% 
  filter(A09MARITALSTATUS %in% c(1, 4, 5, 6, 7), A02RELHEAD == 2, A04RELHNUCFAM == 2) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD, A04RELHNUCFAM, A09MARITALSTATUS)

# 15. =============================================================
# If relationship to the household head is spouse, the relationship to the nuclear family head must also be spouse
cv_relhead_vs_relhnucfam <- section_a_reg %>% 
  filter(A02RELHEAD == 2, !(A04RELHNUCFAM %in% c(2, 3))) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD, A04RELHNUCFAM)

# 16. =============================================================
# age_computed not in the value set
cv_age_not_in_valueset <- section_a_reg %>% 
  filter(!(age_computed %in% c(0:135, NA)), A01HHMEM != '') %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A06DATEBORN, age_computed)

# 17. =============================================================
# age_computed and birthday consistency
cv_age_vs_bday <- section_a_reg %>% 
  filter(!is.na(A06DATEBORN)) %>% 
  filter(age_computed != age_computed) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A06DATEBORN, age_computed, age_computed)


#Check consistency if  son-in-law, daughter-in-law, father, mother, father-in-law, mother-in-law should not be single
#c_not_single <- hpq_individual %>% 
#  filter(A09MARITALSTATUS %in% c(1), A02RELHEAD %in% c(7, 8, 11, 12, 13, 14)) %>% 
#  select(case_id, pilot_area, LINENO, A01HHMEM, A09MARITALSTATUS, A02RELHEAD)

# =============================================================
# Functional difficulties
d_func_diff_below_5 <- section_a_reg %>% 
  filter(age_computed < 5) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, starts_with('A17'))

# 18. =============================================================
# Check consistency if seeing below 5 years old 
cv_seeing_below_5 <- d_func_diff_below_5 %>% 
  filter(!is.na(A17ASEEING)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17ASEEING)

# 19. =============================================================
# Check consistency if hearing below 5 years old 
cv_hearing_below_5 <- d_func_diff_below_5 %>% 
  filter(!is.na(A17BHEARING)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17BHEARING)

# 20. =============================================================
# Check consistency if walking below 5 years old 
cv_walking_below_5 <- d_func_diff_below_5 %>% 
  filter(!is.na(A17CWALKING)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17CWALKING)

# 21. =============================================================
# Check consistency if remembering below 5 years old 
cv_remembering_below_5 <- d_func_diff_below_5 %>% 
  filter(!is.na(A17DREMEMBERING)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17DREMEMBERING)

# 22. =============================================================
# Check consistency if self-caring below 5 years old 
cv_selfcaring_below_5 <- d_func_diff_below_5 %>% 
  filter(!is.na(A17ESELFCARING)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17ESELFCARING)

# 23. =============================================================
# Check consistency if communicating below 5 years old 
cv_communicating_below_5 <- d_func_diff_below_5 %>% 
  filter(!is.na(A17FCOMMUNICATING)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17FCOMMUNICATING)

# ====================================================================
# Check if NA for household members 5 years old and over
d_func_diff_5_above_na <- section_a_reg %>% 
  filter(age_computed >= 5) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, starts_with('A17'))

# 24. =============================================================
# Check consistency if seeing 5 years old and over 
cv_seeing_5_above_na <- d_func_diff_5_above_na %>% 
  filter(is.na(A17ASEEING) | !(A17ASEEING %in% c(1:4))) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17ASEEING)

# 25. =============================================================
# Check consistency if hearing 5 years old and over 
cv_hearing_5_above_na <- d_func_diff_5_above_na %>% 
  filter(is.na(A17BHEARING) | !(A17BHEARING %in% c(1:4))) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17BHEARING)

# 26. =============================================================
# Check consistency if walking 5 years old and over 
cv_walking_5_above_na <- d_func_diff_5_above_na %>% 
  filter(is.na(A17CWALKING) | !(A17CWALKING %in% c(1:4))) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17CWALKING)

# 27. =============================================================
# Check consistency if remembering 5 years old and over 
cv_remembering_5_above_na <- d_func_diff_5_above_na %>% 
  filter(is.na(A17DREMEMBERING) | !(A17DREMEMBERING %in% c(1:4))) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17DREMEMBERING)

# 28. =============================================================
# Check consistency if self-caring 5 years old and over 
cv_selfcaring_5_above_na <- d_func_diff_5_above_na %>% 
  filter(is.na(A17ESELFCARING) | !(A17ESELFCARING %in% c(1:4))) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17ESELFCARING)

# 29. =============================================================
# Check consistency if communicating 5 years old and over 
cv_communicating_5_above_na <- d_func_diff_5_above_na %>% 
  filter(is.na(A17FCOMMUNICATING) | !(A17FCOMMUNICATING %in% c(1:4))) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A17FCOMMUNICATING)

rm(d_func_diff_below_5, d_func_diff_5_above_na)
# A-2 =================================================================
#check consistency if answers in Line no. is not in the value set or blank
cv_line_no <- section_a_reg %>% 
  filter(LINENO %in% c(1:35), A01HHMEM == '') %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM)

#check consistency if answers A01. is not in the value set or blank
cv_hh_mem <- section_a_reg %>% 
  filter(A01HHMEM == '') %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM)

# check consistency if answers in A02 is not in the value set or blank
cv_a02_relhead <- section_a_reg %>%
  filter(!(A02RELHEAD %in% c(1:26, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A02RELHEAD)

# Check consistency if Spouse should be married and common law
cv_spouse_ms_2_3 <- section_a_reg %>% 
  filter(A02RELHEAD == 2 & A04RELHNUCFAM == 2, !(A09MARITALSTATUS %in% c(2, 3))) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A09MARITALSTATUS, A02RELHEAD, A04RELHNUCFAM)

# Spouse below 10 years old
cv_spouse_below_10 <- section_a_reg %>% 
  filter(A02RELHEAD == 2 & age_computed < 10) %>% 
  select(case_id, pilot_area, LINENO, A02RELHEAD, age_computed)

# Son-in-law and daughter-in-law below 10
cv_sil_dil_below_10 <- section_a_reg %>% 
  filter(A02RELHEAD %in% c(7, 8), age_computed <10) %>% 
  select(case_id, pilot_area, LINENO, A02RELHEAD, age_computed)

# Grandson and granddaughter above 60
cv_grands_grandd_above_60 <- section_a_reg %>% 
  filter(A02RELHEAD %in% c(9, 10), age_computed > 60) %>% 
  select(case_id, pilot_area, LINENO, A02RELHEAD, age_computed)

# Father and mother below 30
cv_father_mother_below_30 <- section_a_reg %>% 
  filter(A02RELHEAD %in% c(11, 12), age_computed < 30) %>% 
  select(case_id, pilot_area, LINENO, A02RELHEAD, age_computed)

# Domestic helper below 10
cv_dh_below_10 <- section_a_reg %>% 
  filter(A02RELHEAD == 24 & age_computed < 10) %>% 
  select(case_id, pilot_area, LINENO, A02RELHEAD, age_computed)

# check consistency if answers in A03 is not in the value set or blank
cv_a03_nucfamily <- section_a_reg %>%
  filter(!(A03NUCFAMILY %in% c(1:10, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A03NUCFAMILY)

# check consistency if answers in A04 is not in the value set or blank
cv_A04_relhnucfam <- section_a_reg %>%
  filter(!(A04RELHNUCFAM %in% c(1:9, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A04RELHNUCFAM)

# check consistency if answers in A05 is not in the value set or blank
cv_a05_sex <- section_a_reg %>%
  filter(!(A05SEX %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A05SEX)

# check consistency if answers in A08 is not in the value set or blank
cv_a08_reglcr <- section_a_reg %>%
  filter(!(A08REGLCR %in% c(1, 2, 8, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A08REGLCR)

# modified =================================================
# check consistency if answers in A09 is not in the value set or blank
cv_a09_marital_status <- section_a_reg %>%
  filter(!(A09MARITALSTATUS %in% c(1:7, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A09MARITALSTATUS)

# check consistency if answers in A10 is not in the value set or blank
cv_a10_ethnicity_code <- section_a_reg %>%
  filter(!(A10ETHNICCODE %in% c(1:291, 998, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A10ETHNICCODE)

# check consistency if answers in A11 is not in the value set or blank
cv_a11_rel_aff_code <- section_a_reg %>%
  filter(!(A11CODE %in% c(0:127, 998, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A11CODE)

# Check these cases if those who answered no and don't know in A12.1 are without answers in A13.  
# Those who answered no and don't know in A12.1 should not have responses in A12.3.
cv_a12_skipping <- section_a_reg %>% 
  filter(A121ISSUEDNID %in% c(2, 8), str_trim(A123PSN) != 'DEFAULT' | str_trim(A123PSN) == '') %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A121ISSUEDNID, A123PSN)

# ===================================================
# Check these cases if those who answered yes in A12.1 are without answers in A12.2.  Those who answered yes in A12.1 should not have responses in A12.2.
cv_skipping_121_122 <- section_a_reg %>% 
  filter(A121ISSUEDNID == 2, is.na(A122REGNID)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A121ISSUEDNID, A122REGNID)
# ===================================================

# check consistency if answers in A12.1 is not in the value set or blank
cv_a12.1 <- section_a_reg %>%
  filter(!(A121ISSUEDNID %in% c(1, 2, 8, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A121ISSUEDNID)

# check consistency if answers in A12.2 is not in the value set or blank
cv_a12.2 <- section_a_reg %>%
  filter(!(A122REGNID %in% c(1, 2, 8, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A122REGNID)

# Check these cases if those who answered yes in A13.1 are without answers in A13.2.  Those who answered yes in A12.1 should not have responses in A13.2.
cv_A13.1_A13.2 <- section_a_reg %>% 
  filter(A131LGUID == 1, is.na(A132LGUIDNO)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A131LGUID, A132LGUIDNO)

# check consistency if answers in A13.1 is not in the value set or blank
cv_a13.1 <- section_a_reg %>%
  filter(!(A131LGUID %in% c(1, 2, 8, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A131LGUID)

# Solo parent below 10 with answer
cv_solo_parent_below_10 <- section_a_reg %>% 
  filter(A14SOLOPARENT == 1, age_computed < 10) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A14SOLOPARENT)

# check consistency if answers in A14 is not in the value set or blank
cv_a14 <- section_a_reg %>%
  filter(!(A14SOLOPARENT %in% c(1, 2, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A14SOLOPARENT)

# Check these cases if those who answered yes in A14 are without answers in A15.  Those who answered yes in A12.1 should have answers in A15.
cv_A14_A15 <- section_a_reg %>% 
  filter(A14SOLOPARENT == 1, A15SOLOPARENTID %in% c(1, 2, 8)) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, A14SOLOPARENT, A15SOLOPARENTID)

# Check these cases. Those aged below 10 years old should not have responses in A14-Solo Parent and A15-Solo Parent ID.
cv_A14_A15 <- section_a_reg %>% 
  filter(A14SOLOPARENT == 1, A15SOLOPARENTID %in% c(1, 2, 8), age_computed < 10) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A14SOLOPARENT, A15SOLOPARENTID)

#Check these cases if those 60 years old who answered no in A14 are with answers in A16.  Those 60 years old who answered no in A14 should have answers in A16.
cv_A14_A16 <- section_a_reg %>% 
  filter(A14SOLOPARENT == 2, !(A16SENIORID %in% c(1, 2, 8)), age_computed > 60) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A14SOLOPARENT, A16SENIORID)

#check consistency if answers in A15 is not in the value set or blank
cv_a15 <- section_a_reg %>%
  filter(!(A15SOLOPARENTID %in% c(1, 2, 8, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, A15SOLOPARENTID)

#Senior without answer in senior citizen ID 
cv_A16_wa_above_60 <- section_a_reg %>% 
  filter(is.na(A16SENIORID), age_computed >= 60) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A16SENIORID)

#Senior with answer in senior citizen ID 
cv_A16_below_60 <- section_a_reg %>% 
  filter(!is.na(A16SENIORID), age_computed < 60) %>% 
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A16SENIORID)

#check consistency if answers in A16 is not in the value set or blank
cv_a16 <- section_a_reg %>%
  filter(!(A16SENIORID %in% c(1, 2, 8, NA))) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, A16SENIORID)


# =========================================================
rm(section_a_reg)

# print('Section A complete!')