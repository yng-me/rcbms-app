## ================== Mother's residence ==================
section_b <- hpq_individual %>% 
  filter(HSN < 7777, RESULT_OF_VISIT == 1) %>% 
  select(case_id, REGION:CITY, pilot_area, LINENO, A01HHMEM, A07AGE, age_computed, starts_with('B'))

### age is less than 5 but with response in mother's residence
cv_b01_notblank <- section_b %>% 
  filter(!is.na(B01), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01)

### age is 5 years and over but no response in mother's residence
cv_b01_blank <- section_b %>% 
  filter(is.na(B01), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01)

### response in mother's residence is not in the valueset
cv_b01_valueset <- section_b %>% 
  #filter(B01 != 1 & B01 != 2 & B01 != 3 & B01 != 4, !is.na(B01), age_computed >= 5) %>%
  filter(!(B01 %in% c(1:4, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01)


## ================== Province, City/Mun and country of Mother's residence at the time of visit ==================

### age is less than 5 but with answer in b01prov
cv_b01provage_notblank <- section_b %>% 
  filter(!is.na(B01PROV), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01PROV)

### age is less than 5 but with answer in b01mun
cv_b01munage_notblank <- section_b %>% 
  filter(!is.na(B01MUN), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01MUN)

### age is less than 5 but with answer in b01country
cv_b01countryage_notblank <- section_b %>% 
  filter(!is.na(B01COUNTRY), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01COUNTRY)

## no response in province of mother's residence but b01 = 2
 cv_b01prov_blank <- section_b %>% 
   filter(is.na(B01PROV), B01 == 2, age_computed >= 5) %>%
   select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01PROV)

## no response in city/mun of mother's residence but b01 = 2
cv_b01mun_blank <- section_b %>%
  filter(is.na(B01MUN), B01 == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01MUN)

### no response in country of mother's residence but b01 = 3
cv_b01country_blank <- section_b %>% 
  filter(is.na(B01COUNTRY), B01 == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01COUNTRY)

### with response in province of mother's residence but b01 = 3
cv_b01is3_provnotblank <- section_b %>% 
  filter(!is.na(B01PROV), B01 == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01PROV)

### with response in city/mun of mother's residence but b01 = 3
cv_b01is3_munnotblank <- section_b %>% 
  filter(!is.na(B01MUN), B01 == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01MUN)

### with response in country of mother's residence but b01 is not 3
cv_b01isnot3_countrynotblank <- section_b %>% 
  filter(!is.na(B01COUNTRY), B01 != 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01COUNTRY)

##need to verify if answer in b01=1, matic ba ma-call yung current prov, city/mun or blank na dapat
### b01 = 1 but prov <> province of mother's residence
# cv_b01prov_province <- section_b %>%
#   filter(B01 == 1, !is.na(B01PROV), age_computed >= 5) %>% 
#   select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01PROV)
# 
# cv_b01mun_city <- section_b %>%
#  filter(B01 == 1, !is.na(B01MUN), age_computed >= 5) %>% 
#  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01MUN)

### b01 = 2 but prov, city/mun = prov, city/mun of mother's residence
# cv_b01is2_provmuneq <- section_b %>%
#   filter(B01 == 2, B01MUN == CITY & B01PROV == PROVINCE, age_computed >= 5) %>% 
#   select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01PROV, PROVINCE, B01MUN, # CITY)


###valuesets
cv_b01prov_valueset <- section_b %>% 
  filter(!(B01PROV %in% c(1:99, NA)), B01 == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01PROV)

cv_b01mun_valueset <- section_b %>% 
  filter(!(B01MUN %in% c(1:99, NA)), B01 == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01PROV, B01MUN)

cv_b01country_valueset <- section_b %>% 
  filter(!(B01COUNTRY %in% c(9001:9256, 9997, NA)), B01 == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B01, B01COUNTRY)


####=================residence 5 years ago ====================================
### age is less than 5 but with response in residence five (5) years ago
cv_b02_notblank <- section_b %>% 
  filter(!is.na(B02), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02)

### age is 5 years and over but no response in residence five (5) years ago
cv_b02_blank <- section_b %>% 
  filter(is.na(B02), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02)

### response in residence five (5) years ago is not in the valueset
cv_b02_valueset <- section_b %>% 
  filter(!(B02 %in% c(1:4, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02)

## ==== Province, City/Mun and country of residence five (5) years ago ==================

### age is less than 5 but with answer in b02prov
cv_b02provage_notblank <- section_b %>% 
  filter(!is.na(B02PROV), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02PROV)

### age is less than 5 but with answer in b02mun
cv_b02munage_notblank <- section_b %>% 
  filter(!is.na(B02MUN), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02MUN)

### age is less than 5 but with answer in b02country
cv_b02countryage_notblank <- section_b %>% 
  filter(!is.na(B02COUNTRY), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02COUNTRY)

### no response in province of residence five (5) years ago but b02 = 2
cv_b02prov_blank <- section_b %>% 
  filter(is.na(B02PROV), B02 == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02PROV)

### no response in city/mun of residence five (5) years ago but b02 = 2
cv_b02mun_blank <- section_b %>%
  filter(is.na(B02MUN), B02 == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02MUN)

### no response in country of residence five (5) years ago but b02 = 3
cv_b02country_blank <- section_b %>% 
  filter(is.na(B02COUNTRY), B02 == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02COUNTRY)

### with response in province of residence five (5) years ago but b02 = 3
cv_b02is3_provnotblank <- section_b %>% 
  filter(!is.na(B02PROV), B02 == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02PROV)

### with response in city/mun of residence five (5) years ago but b02 = 3
cv_b02is3_munnotblank <- section_b %>% 
  filter(!is.na(B02MUN), B02 == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02MUN)

### with response in country of residence five (5) years ago but b02 is not 3
cv_b02isnot3_countrynotblank <- section_b %>% 
  filter(!is.na(B02COUNTRY), B02 != 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02COUNTRY)

# b02 = 1 but prov <> province of residence five (5) years ago
#cv_b02prov_province <- section_b %>%
#  filter(B02 == 1, !is.na(B02PROV), age_computed >= 5) %>% 
#  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02PROV)
#
## b02 = 1 but city/mun <> city/mun of residence five (5) years ago
#cv_b02mun_city <- section_b %>%
#  filter(B02 == 1, !is.na(B02MUN), age_computed >= 5) %>% 
#  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02MUN)

# b02 = 2 but prov, city/mun = prov, city/mun of residence five (5) years ago
#cv_b02is2_provmuneq <- section_b %>%
#  filter(B02 == 2, B02MUN == CITY & B02PROV == PROVINCE, age_computed >= 5) %>% 
#  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02PROV, PROVINCE, B02MUN, CITY)

###valuesets
cv_b02prov_valueset <- section_b %>% 
  filter(!(B02PROV %in% c(1:99, NA)), B02 == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02PROV)

cv_b02mun_valueset <- section_b %>% 
  filter(!(B02MUN %in% c(1:99, NA)), B02 == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02PROV, B02MUN)

cv_b02country_valueset <- section_b %>% 
  filter(!(B02COUNTRY %in% c(9001:9256, 9997, NA)), B02 == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B02COUNTRY)

##=================Reason for not moving five years ago================================##
### age is less than 5 but with response in reason for moving five years ago
cv_b03_notblank <- section_b %>% 
  filter(!is.na(B03REASON), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B03REASON)

### no response in reason for moving five years ago but b02 = 2,3
cv_b03_blank <- section_b %>% 
  filter(is.na(B03REASON), B02 %in% c(2,3), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B03REASON)

### with response in reason for moving five years ago but b02 <> 2
cv_b03notblank_b02is2or3 <- section_b %>% 
  filter(B02 %in% c(1, 4), !is.na(B03REASON), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B03REASON)

### b02 = 2,3 and response in reason for moving five years ago is not in the valueset 
cv_b03_valueset <- section_b %>% 
  filter(!(B03REASON %in% c(1:15, 99, NA)), B02 %in% c(2,3), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B02, B03REASON)

### with response in b03specify but b03reason <> 99
cv_b03specifynotblank <- section_b %>% 
  mutate(B03SPECIFY = str_trim(B03SPECIFY)) %>% 
  filter(B03REASON %in% c(1:15), B03SPECIFY != '', age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B03REASON, B03SPECIFY)

### no response in b03specify but b03reason = 99
cv_b03specifyblank <- section_b %>% 
  mutate(B03SPECIFY = str_trim(B03SPECIFY)) %>% 
  filter(B03REASON == 99, B03SPECIFY == '', age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B03REASON, B03SPECIFY)

####=================residence 6 months ago ====================================
### age is less than 5 but with response in residence six (6) months ago
cv_b04_notblank <- section_b %>% 
  filter(!is.na(B04RESIDE), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE)

# age is 5 years and over but no response in residence six (6) months ago
cv_b04_blank <- section_b %>% 
  filter(is.na(B04RESIDE), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE)

# response in residence six (6) months ago is not in the valueset
cv_b04_valueset <- section_b %>% 
  filter(!(B04RESIDE %in% c(1:4, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE)


# age is less than 5 but with answer in b04prov
cv_b04provage_notblank <- section_b %>% 
  filter(!is.na(B04PROV), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04PROV)

# age is less than 5 but with answer in b04mun
cv_b04munage_notblank <- section_b %>% 
  filter(!is.na(B04MUN), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04MUN)

# age is less than 5 but with answer in b04country
cv_b04countryage_notblank <- section_b %>% 
  filter(!is.na(B04COUNTRY), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04COUNTRY)

# no response in province of residence six (6) months ago but b04 = 2
 cv_b04prov_blank <- section_b %>% 
   filter(is.na(B04PROV), B04RESIDE == 2, age_computed >= 5) %>%
   select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04PROV)

# no response in city/mun of residence six (6) months ago but b04 = 2
 cv_b04mun_blank <- section_b %>%
   filter(is.na(B04MUN), B04RESIDE == 2, age_computed >= 5) %>%
   select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04MUN)

# no response in country of residence six (6) months ago but b04 = 3
cv_b04country_blank <- section_b %>% 
  filter(is.na(B04COUNTRY), B04RESIDE == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04COUNTRY)

# with response in province of residence six (6) months ago but b04 = 3
cv_b04is3_provnotblank <- section_b %>% 
  filter(!is.na(B04PROV), B04RESIDE == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04PROV)

# with response in city/mun of residence six (6) months ago but b04 = 3
cv_b04is3_munnotblank <- section_b %>% 
  filter(!is.na(B04MUN), B04RESIDE == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04MUN)

# with response in country of residence six (6) months ago but b04 is not 3
cv_b04isnot3_countrynotblank <- section_b %>% 
  filter(!is.na(B04COUNTRY), B04RESIDE != 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04COUNTRY)

# b04 = 1 but prov <> province of residence six (6) months ago
#cv_b04prov_province <- section_b %>%
#  filter(B04RESIDE == 1, !is.na(B04PROV), age_computed >= 5) %>% 
#  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04PROV)
#
## b02 = 1 but city/mun <> city/mun of residence five (5) years ago
#cv_b04mun_city <- section_b %>%
#  filter(B04RESIDE == 1, !is.na(B04MUN), age_computed >= 5) %>% 
#  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04MUN)
#
## b02 = 2 but prov, city/mun = prov, city/mun of residence five (5) years ago
#cv_b04is2_provmuneq <- section_b %>%
#  filter(B04RESIDE == 2, B04MUN == CITY & B04PROV == PROVINCE, age_computed >= 5) %>% 
#  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04PROV, PROVINCE, #B04MUN, CITY)

# valuesets
cv_b04prov_valueset <- section_b %>% 
  filter(!(B04PROV %in% c(1:99, NA)), B04RESIDE == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04PROV)

cv_b04mun_valueset <- section_b %>% 
  filter(!(B04MUN %in% c(1:99, NA)), B04RESIDE == 2, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04PROV, B04MUN)

cv_b04country_valueset <- section_b %>% 
  filter(!(B04COUNTRY %in% c(9001:9256, 9997, NA)), B04RESIDE == 3, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B04COUNTRY)

##=================Reason for not moving 6 months ago================================##
### age is less than 5 but with response in reason for moving 6 months ago
cv_b05_notblank <- section_b %>% 
  filter(!is.na(B05REASON), age_computed < 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B05REASON)

### no response in reason for moving 6 months ago but b04 = 2,3
cv_b05_blank <- section_b %>% 
  filter(is.na(B05REASON), B04RESIDE %in% c(2,3), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B05REASON)

### with response in reason for moving 6 months ago but b04 <> 2, 3
cv_b05notblank_b04is2or3 <- section_b %>% 
  filter(B04RESIDE %in% c(1, 4), !is.na(B05REASON), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B05REASON)

### b04 = 2,3 and response in reason for moving 6 months ago is not in the valueset 
cv_b05_valueset <- section_b %>% 
  filter(!(B05REASON %in% c(1:15, 99, NA)), B04RESIDE %in% c(2,3), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B04RESIDE, B05REASON)

### with response in b05specify but b05reason <> 99
cv_b05specifynotblank <- section_b %>% 
  mutate(B05SPECIFY = str_trim(B05SPECIFY)) %>% 
  filter(B05REASON %in% c(1:15), B05SPECIFY != '', age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B05REASON, B05SPECIFY)

### no response in b05specify but b05reason = 99
cv_b05specifyblank <- section_b %>% 
  mutate(B05SPECIFY = str_trim(B05SPECIFY)) %>% 
  filter(B05REASON == 99, B05SPECIFY == '', age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B05REASON, B05SPECIFY)

### ============================ OFW ========================================== ###
# age is less than 15 years old but with response in b06
cv_b06_age_notblank <- section_b %>% 
  filter(!is.na(B06OFW), age_computed < 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW)

# age is 15 years old and above but no response in b06
cv_b06_age_blank <- section_b %>% 
  filter(is.na(B06OFW), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW)

### response in b06ofw is not in the valueset
cv_b06_valueset <- section_b %>% 
  filter(!(B06OFW %in% c(1:7, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW)

### ========================== b07 ========================================= ###
# age is less than 15 years old but with response in b07
cv_b07_age_notblank <- section_b %>% 
  mutate(B07DATE = str_trim(B07DATE)) %>% 
  filter(B07DATE != '', age_computed < 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B07DATE)

# age is 15 years old and above, b06 = (1,2) but no response in b07
cv_b07_age_blank <- section_b %>% 
  mutate(B07DATE = str_trim(B07DATE)) %>% 
  filter(B07DATE == '', B06OFW %in% c(1, 2), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B07DATE)

# age is 15 years old and above, b06 <> (1,2) but with response in b07
cv_b07notblank_b06 <- section_b %>% 
  mutate(B07DATE = str_trim(B07DATE)) %>% 
  filter(B07DATE != '', !(B06OFW %in% c(1, 2)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B07DATE)

## response in B07DATE is not in the valueset
cv_b07_valueset <- suppressWarnings(section_b %>%
  filter(!is.na(B07DATE)) %>% 
  mutate(B07DATE = str_trim(B07DATE)) %>%
  mutate(
    b07datemonth = if_else(
      nchar(B07DATE) == 6,
      as.integer(substr(B07DATE, 1, 2)),
      as.integer(substr(B07DATE, 1, 1)))
  ) %>% 
  mutate(
    b07dateyear = if_else(
      nchar(B07DATE) == 6,
      as.integer(substr(B07DATE, 3, 6)),
      as.integer(substr(B07DATE, 2, 5)))
  ) %>% 
  filter(
    B07DATE != '',
    !(b07datemonth %in% c(1:12, 98)) | !(b07dateyear %in% c(1897:2022, 9998)),
    B06OFW %in% c(1, 2),
    age_computed >= 15
  ) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B07DATE, b07datemonth, b07dateyear)
)

## ============================== B08STAY ======================================= ##
# age is less than 15 years old but with response in b08
cv_b08_age_notblank <- section_b %>% 
  filter(!is.na(B08MONTHS), age_computed < 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B08MONTHS)

# age is 15 years old and above, b06 = (1,2) but no response in b08
cv_b08_age_blank <- section_b %>% 
  filter(is.na(B08MONTHS), B06OFW %in% c(1, 2), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B08MONTHS)

# age is 15 years old and above, b06 <> (1,2) but with response in b08
cv_b08notblank_b06 <- section_b %>% 
  filter(!is.na(B08MONTHS), !(B06OFW %in% c(1,2)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B08MONTHS)

### response in b08 not in the valueset
#c_b08_valueset <- section_b %>% 
  #filter(!is.integer(B08MONTHS), age_computed >= 5) %>%
  #select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B08MONTHS)

## =============== B09location ============================================ ##
# age is less than 15 years old but with response in b09
cv_b09_age_notblank <- section_b %>% 
  filter(!is.na(B09PLACE), age_computed < 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B09PLACE)


# age is 15 years old and above, b06 = (1:6) but no response in b09
cv_b09_age_blank <- section_b %>% 
  filter(is.na(B09PLACE), B06OFW %in% c(1:6), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B09PLACE)


# age is 15 years old and above, b06 <> (1:6) but with response in b09
cv_b09notblank_b06 <- section_b %>% 
  filter(!is.na(B09PLACE), !(B06OFW %in% c(1:6)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B09PLACE)


### response in b09 not in the valueset
cv_b09_valueset <- section_b %>% 
  filter(!(B09PLACE %in% c(9001:9256, 9998, NA)), age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B09PLACE)

## ======================== b10 how many times ============================ ##
# age is less than 15 years old but with response in b10
cv_b10_age_notblank <- section_b %>% 
  filter(!is.na(B10TIMES), age_computed < 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B10TIMES)

# age is 15 years old and above, b06 = (1:6) but no response in b10
cv_b10_age_blank <- section_b %>% 
  filter(is.na(B10TIMES), B06OFW %in% c(1:6), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B10TIMES)

# age is 15 years old and above, b06 <> (1:6) but with response in b10
cv_b10notblank_b06 <- section_b %>% 
  filter(!is.na(B10TIMES), !(B06OFW %in% c(1:6)), age_computed >= 15) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B06OFW, B10TIMES)

### response in b10 not in the valueset
cv_b10_valueset <- section_b %>% 
  filter(!is.na(B10TIMES), B10TIMES < 0, age_computed >= 5) %>%
  select(case_id, pilot_area, LINENO, A01HHMEM, age_computed, B10TIMES)

rm(section_b)

print('Section B complete!')