# Section B {.unnumbered}

section_b <- hpq$section_b %>% collect()

ph_residence_codes <- c(101:127, 199, 201:212, 299, 301:314, 399, 401:417, 499, 501:518, 599, 601:618, 699, 702:713, 799, 801:812, 899, 901:906, 999, 1001:1034, 1099, 1101:1114, 1199, 1201:1248, 1299, 1301:1322, 1399, 1401:1424, 1499, 1501:1529, 1599, 1601:1612, 1699, 1701:1737, 1799, 1801:1805, 1899, 1901:1917, 1999, 2001:2011, 2099, 2101:2123, 2199, 2201:2253, 2299, 2301, 2303, 2305, 2314, 2315, 2317:2319, 2322:2324, 2399, 2401:2404, 2406:2408, 2410:2412,2414, 2499, 2501:2511, 2599, 2601:2623, 2699, 2701:2711, 2799, 2801:2823, 2899, 2901:2934, 2999, 3001:3010, 3012:3023, 3025:3032, 3034:3047, 3099, 3101:3137, 3199, 3201, 3206, 3208, 3209, 3211, 3213:3215, 3299, 3301:3320, 3399, 3401:3430, 3499, 3501:3523, 3599, 3601:3607, 3609:3641, 3699, 3701:3703, 3705:3708, 3710, 3713:3715, 3717:3736, 3738:3751, 3799, 3801:3803, 3805:3837, 3899, 3901:3914, 3999, 4001:4006, 4099, 4101:4121, 4199, 4201:4217, 4299, 4301:4326, 4399, 4401:4410, 4499, 4501:4599, 4601:4625, 4699, 4701:4718, 4799, 4801:4824, 4899, 4901:4932, 4999, 5001:5015, 5099, 5101:5111, 5199, 5201:5215, 5299, 5301:5324, 5399, 5401:5422, 5499, 5501:5548, 5599, 5601:5603, 5605:5608, 5610, 5615:5625, 5627:5642, 5644:5649, 5699, 5701:5706, 5799, 5801:5814, 5899, 5901:5917, 5999, 6001:6026, 6099, 6101:6106, 6199, 6202:6216, 6299, 6302, 6303, 6306, 6311:6319, 6399, 6401:6419, 6499, 6501:6512, 6599, 6601:6619, 6699, 6701, 6702, 6704, 6706:6708, 6710, 6711, 6714:6725, 6727, 6799, 6801:6819, 6899, 6901:6918, 6999, 7001:7011, 7099, 7101:7114, 7199, 7201:7227, 7299, 7302, 7303, 7305:7308, 7311:7313, 7315, 7317:7319, 7322:7325, 7327, 7328, 7330, 7332, 7333, 7337:7338, 7340:7341, 7343:7344, 7399, 7401:7405, 7499, 7501:7504, 7599, 7601:7607, 7699, 7701:7708, 7799, 7801:7808, 7899, 7901:7905, 7999, 8001:8007, 8099, 8101:8107, 8199, 8201:8211, 8299, 8301:8316, 8399, 8501:8507, 8599, 8601:8605, 8699, 9701, 9804, 9999)


### B01 - Age \< 5 years old, but with response in B01 to B05

## Age less than 5 years old should NOT have responses in B01 to B05. Either verify the age or delete the entries in B01 to B05.
(
  cv_b01_migration_age_less_5 <- section_b %>% 
    filter(age < 5) %>% 
    filter_at(vars(matches('^b0[1-5]_.*'), -matches("fct$")), any_vars(!is.na(.))) %>% 
    select_cv(matches('^b0[1-5]_.*'))
)[[1]]

### B01 - Missing/invalid (mother's residence at the time of birth)

## Mother's residence at the time of birth should be within the value set in B01 for household members aged at least 5 years old.
(
  cv_b01_migration_invalid <- section_b %>% 
    filter(age >= 5, !(b01_mig %in% c(1:4))) %>% 
    select_cv(b01_mig, h = 'b01_mig')
)[[1]]


### B01 - Mother's residence at the time of birth

## If the mother's residence at the time of birth is same as current city/municipality, code for the specific city/municipality should be 0 or not missing. Otherwise, verify the mother's residence at the time of birth of the household member.
(
  cv_b01_migration_b01_1 <- section_b %>% 
    filter(age >= 5, b01_mig == 1, !(b01_philippines1 %in% c(0, NA))) %>% 
    select_cv(b01_mig, b01_philippines1, h = 'b01_philippines1')
)[[1]]


### B01 - Missing/invalid (mother's residence at the time of birth is in another city/municipality)

## If the mother's residence at the time of birth is in another city/municipality within the Philippines, code for the specific city/municipality should be within the PSGC codes or not missing. Otherwise, verify the mother's residence at the time of birth of the household member.
(
  cv_b01_migration_b01_2 <- section_b %>% 
    filter(age >= 5, b01_mig == 2, !(b01_philippines1 %in% ph_residence_codes)) %>% 
    select_cv(b01_mig, b01_philippines1, h = 'b01_philippines1')
)[[1]]


### B01 - Missing/invalid (mother's residence at the time of birth is in another country)

## If the mother's residence at the time of birth is in another country, the specific country code should be within the value set or not missing. Otherwise, verify the mother's residence at the time of birth of the household member.
(
  cv_b01_migration_b01_3 <- section_b %>% 
    filter(age >= 5, b01_mig == 3, !(b01_country1 %in% c(9001:9256, 9997))) %>% 
    select_cv(b01_mig, b01_country1, h = 'b01_country1')
)[[1]]


### B01 - Mother's residence at the time of birth is unknown

## If the mother's residence at the time of birth is 4 (unknown), code for the specific city/municipality should be blank. Otherwise, verify the mother's residence at the time of birth of the household member.
(
  cv_b01_migration_b01_4 <- section_b %>% 
    filter(age >= 5, b01_mig == 4, (b01_philippines1 %in% ph_residence_codes) | !is.na(b01_country1)) %>% 
    select_cv(
      b01_mig, 
      b01_philippines1, 
      b01_country1, h = c('b01_philippines1', 'b01_country1'))
)[[1]]


### B02 - Missing/invalid residence five (5) years ago

## Residence five (5) years ago should be in value set for household members aged at least 5 years old.
(
  cv_b02_fyrsreside_NOT_value_set <- section_b %>% 
    filter(age >= 5, !(b02_fyrsreside %in% c(1:4))) %>% 
    select_cv(b02_fyrsreside, h = 'b02_fyrsreside')
)[[1]]


### B02 - Missing/invalid residence five (5) years ago is same as current city/municipality

## If the residence five (5) years ago is same as current city/municipality, code for the specific city/municipality should be 0 or not missing. Otherwise, verify the residence five (5) years ago of the household member.
(
  cv_b02_fyrsreside_b02_1 <- section_b %>% 
    filter(age >= 5, b02_fyrsreside == 1, !(b01_philippines2 %in% c(0, NA))) %>% 
    select_cv(b02_fyrsreside, b01_philippines2, h = 'b01_philippines2')
)[[1]]


### B02 - Residence five (5) years ago is in another city/municipality within the Philippines

## If the residence five (5) years ago is in another city/municipality within the Philippines, code for the specific city/municipality should be within the PSGC codes or not missing. Otherwise, verify the residence five (5) years ago of the household member.
(
  cv_b02_fyrsreside_b02_2 <- section_b %>% 
    filter(age >= 5, b02_fyrsreside == 2, !(b01_philippines2 %in% ph_residence_codes)) %>% 
    select_cv(b02_fyrsreside, b01_philippines2, h = 'b01_philippines2')
)[[1]]


### B02 - Residence five (5) years ago is in another country, but country code is NOT in value set or missing

## If the residence five (5) years ago is in another country, the specific country code should be within the value set or not missing. Otherwise, verify the residence five (5) years ago of the household member.
(
  cv_b02_fyrsreside_b02_3 <- section_b %>% 
    filter(age >= 5, b02_fyrsreside == 3, !(b01_country2 %in% c(9001:9256, 9997))) %>% 
    select_cv(b02_fyrsreside, b01_country2)
)[[1]]


### B02 - Residence five (5) years ago is unknown, but code is NOT in value set or missing

## If the residence five (5) years ago is unknown, code for the specific city/municipality should be blank. Otherwise, verify the residence five (5) years ago of the household member.
(
  cv_b02_fyrsreside_b02_4 <- section_b %>% 
    filter(age >= 5, b02_fyrsreside == 4, (b01_philippines2 %in% ph_residence_codes) | !is.na(b01_country2)) %>% 
    select_cv(b02_fyrsreside, b01_philippines2, b01_country2)
)[[1]]


### B03 - Missing/invalid reason for moving/staying

## The reason for moving/staying should NOT be in value set or missing if the residence five (5) years ago is in another city/municipality within the Philippines or in another or unknown country. Otherwise, verify the residence five (5) years ago of the household member, or modify the entry in B03.
(
  cv_b03_reasonfyrs_NOT_value_set <- section_b %>% 
    filter(age >= 5, b02_fyrsreside %in% c(2, 3), !(b03_reasonfyrs %in% c(1:18, 99))) %>% 
    select_cv(b02_fyrsreside, b01_philippines2, b01_country2, b03_reasonfyrs)
)[[1]]


### B03 - Answer is 99 (other) but not specified

#### Cases with inconsistency

## If responded 99 (other) to B03 (reason for moving/staying), answer must be specified.
(
  cv_b03_other_missing <- section_b %>% 
    filter(age >= 5, b03_reasonfyrs == 99, is.na(b03a_reasonfyrsos)) %>% 
    select_cv(b02_fyrsreside_fct, b03a_reasonfyrsos)
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_b03_other <- section_b %>% 
    filter(b03_reasonfyrs == 99, !is.na(b03a_reasonfyrsos)) %>% 
    select_cv(b03_reasonfyrs_fct, b03a_reasonfyrsos)
)[[1]]

### B04 - Residence six (6) months ago is NOT in value set

## Residence six (6) months ago should be within value set for household members aged at least 5 years old.
(
  cv_b04_smosreside_NOT_value_set <- section_b %>% 
    filter(age >= 5, !(b04_smosreside %in% c(1:4))) %>% 
    select_cv(b04_smosreside)
)[[1]]


### B04 - Residence six (6) months ago is same as current city/municipality

## If the residence six (6) months ago is same as current city/municipality, code for the specific city/municipality should be 0 or not missing. Otherwise, verify the residence six (6) months ago of the household member.
(
  cv_b04_smosreside_b04_1 <- section_b %>% 
    filter(age >= 5, b04_smosreside == 1, !(b01_philippines4 %in% c(0, NA))) %>% 
    select_cv(b04_smosreside, b01_philippines4)
)[[1]]


### B04 - Residence six (6) months ago is in another city/municipality within the Philippines

## If the residence six (6) months ago is in another city/municipality within the Philippines, code for the specific city/municipality should be within the PSGC codes or not missing. Otherwise, verify the residence six (6) months ago of the household member.
(
  cv_b04_smosreside_b04_2 <- section_b %>% 
    filter(age >= 5, b04_smosreside == 2, !(b01_philippines4 %in% ph_residence_codes)) %>% 
    select_cv(b04_smosreside, b01_philippines4)
)[[1]]


### B04 - Residence six (6) months ago is in another country

## If the residence six (6) months ago is in another country, the specific country code should be within the value set or not missing. Otherwise, verify the residence six (6) months ago of the household member.
(
  cv_b04_smosreside_b04_3 <- section_b %>% 
    filter(age >= 5, b04_smosreside == 3, !(b01_country4 %in% c(9001:9256, 9997))) %>% 
    select_cv(b04_smosreside, b01_country4)
)[[1]]


### B04 - Residence six (6) months ago is unknown

## If the residence six (6) months ago is unknown, code for the specific city/municipality should be blank. Otherwise, verify the residence six (6) months ago of the household member.
(
  cv_b02_fyrsreside_b04_4 <- section_b %>% 
    filter(age >= 5, b04_smosreside == 4, (b01_philippines4 %in% ph_residence_codes) | !is.na(b01_country4)) %>% 
    select_cv(b04_smosreside, b01_philippines4, b01_country4)
)[[1]]


### B05 - Missing/invalid reason for moving/staying

## The reason for moving/staying should NOT be in value set or missing if the residence six (6) months ago is in another city/municipality within the Philippines or in another or unknown country. Otherwise, verify the residence six (6) months ago of the household member, or modify the entry in B05.
(
  cv_b05_reasonsmos_NOT_value_set <- section_b %>% 
    filter(age >= 5, b04_smosreside %in% c(2, 3), !(b05_reasonsmos %in% c(1:18, 99))) %>% 
    select_cv(b04_smosreside, b01_philippines4, b01_country4, b05_reasonsmos)
)[[1]]


### B05 - Answer is 99 (other) but not specified


#### Cases with inconsistency

## If responded 99 (other) to B05 (reason for moving/staying), answer must be specified.
(
  cv_b05_other_missing <- section_b %>% 
    filter(age >= 5, b05_reasonsmos == 99, is.na(b05a_reasonfyrsos)) %>% 
    select_cv(b05_reasonsmos_fct, b05a_reasonfyrsos, h = 'b05a_reasonfyrsos')
)[[1]]


#### Other responses

## Recode answer for 'Others, specify' if necessary.
(
  cv_b05_other <- section_b %>% 
    filter(b05_reasonsmos == 99, !is.na(b05a_reasonfyrsos)) %>% 
    select_cv(b05_reasonsmos_fct, b05a_reasonfyrsos)
)[[1]]



### B06 - Age \< 15 years old, but with response in B06 to B10

## Age less than 15 years old should NOT have responses in B06 to B10. Either verify the age or delete the entries in B06 to B10.
(
  cv_b06_ofi_age_less_15 <- section_b %>% 
    filter(age < 15) %>% 
    filter_at(vars(matches('^b(0[6-9]|10)_.*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(matches('^b(0[6-9]|10)_.*'), -b06_ofi)
)[[1]]


### B06 - OF Indicator is NOT in value set or missing

## OF indicator should be within value set for household members aged at least 15 years old. You may check entries in B07 to B10.
(
  cv_b06_ofi_NOT_value_set <- section_b %>% 
    filter(age >= 15, !(b06_ofi %in% c(1:7))) %>% 
    select_cv(b06_ofi)
)[[1]]


### B06 - OFI codes 3 to 6, but B07 and B08 have answers

## Household member who is an employee in PH Embassy, consulates, and other missions, a student abroad, a tourist, or other Overseas Filipino not elsewhere classified should NOT have response in B07 and B08. Otherwise, verify the OF indicator in B06.
(
  cv_b06_ofi_b06_3456_b07_b08 <- section_b %>% 
    filter(age >= 15, b06_ofi %in% c(3:6), !is.na(b07_leave_month) | !is.na(b07_leave_yr) | !is.na(b08_stay)) %>%
    select_cv(b06_ofi, b07_leave_month, b07_leave_yr, b08_stay)
)[[1]]


### B07 - OFI codes 1 or 2, but B07 is missing/invalid

## OFW with or without contract should have responses in B07. Otherwise, verify OF indicator in B06.
(
  cv_b06_ofi_b06_1_2 <- section_b %>% 
    filter(age >= 15, b06_ofi %in% c(1, 2), b07_leave_month %in% c(1:12, 98) | b07_leave_yr %in% c(2015:2022, 9998)) %>%
    select_cv(b06_ofi, b07_leave_month, b07_leave_yr)
)[[1]]


### B08 - OFI codes 1 or 2, but B08 is missing/invalid

## OFW with or without contract should have responses in B08. Otherwise, verify OF indicator in B06.
(
  cv_b06_ofi_b06_1_2 <- section_b %>% 
    filter(age >= 15, b06_ofi %in% c(1, 2), !(b08_stay %in% c(1:300))) %>%
    select_cv(b06_ofi, b08_stay)
)[[1]]


### B09 - OFI codes 1 to 6, but B09 is missing/invalid

## Household member who is an employee in PH Embassy, consulates, and other missions, a student abroad, tourist abroad, or other Overseas Filipino not elsewhere classified should have answers in B09 and B10 within the value set. Otherwise, verify the OF indicator in B06.
(
  cv_b09_invalid <- section_b %>% 
    filter(age >= 15, b06_ofi %in% c(1:6), !(b09_country %in% c(9001:9256, 9997))) %>%
    select_cv(b06_ofi, b09_country)
)[[1]]


### B09 - OFI codes 1 to 4, 6, but B09 is missing/invalid

## Household member who is an employee in PH Embassy, consulates, and other missions, a student abroad, or other Overseas Filipino not elsewhere classified should have answers in B09 and B10 within the value set. Otherwise, verify the OF indicator in B06.
(
  cv_b06_ofi_b06_346_NOT_value_set <- section_b %>% 
    filter(age >= 15, b06_ofi %in% c(1:4, 6), !(b10_ptsendmny %in% c(0:48, 98))) %>%
    select_cv(b06_ofi, b10_ptsendmny)
)[[1]]


### B07-10 - OFI code 7 but B07 to B10 have answers

## Household members who are not Overseas Filipinos should NOT have responses in B07 to B10. Either verify the OF indicator in B06, or delete the entries in B07 to B10.
(
  cv_b06_ofi_b06_7 <- section_b %>% 
    filter(age >= 15, b06_ofi == 7) %>% 
    filter_at(vars(matches('^b(0[7-9]|10).*'), -matches('_fct$')), any_vars(!is.na(.))) %>% 
    select_cv(b06_ofi, matches('^b(0[7-9]|10).*'))
)[[1]]