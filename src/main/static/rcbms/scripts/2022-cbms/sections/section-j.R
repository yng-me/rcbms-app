
# Section J {.unnumbered}

section_j <- hpq$section_j %>% collect()

### J01 - Worried about not having enough food to eat during the past 12 months is blank or invalid

## Worried about not having enough food to eat during the past 12 months should not be blank and answer should be in the value set.
(
  cv_j01_worried_vlst <- section_j %>% 
    filter(!(j01_worriedy %in% c(1 , 2, 8, 9))) %>% 
    select_cv(j01_worriedy, h = 'j01_worriedy')
)[[1]]


### J02 - Unable to eat healthy and nutritious food during the past 12 months is blank or invalid

## Unable to eat healthy and nutritious food during the past 12 months should not be blank and answer should be in the value set.
(
  cv_j02_unable_vlst <- section_j %>% 
    filter(!(j02_unable %in% c(1, 2, 8, 9))) %>% 
    select_cv(j02_unable, h = 'j02_unable')
)[[1]]



### J03 - Ate only a few kinds of food during the past 12 months is blank or invalid

## Ate only a few kinds of food during the past 12 months should not be blank and answer should be in the value set.
(
  cv_j03_atefew_vlst <- section_j %>% 
    filter(!(j03_atefew %in% c(1, 2, 8, 9))) %>% 
    select_cv(j03_atefew, h = 'j03_atefew')
)[[1]]


### J04 - Had to skip a meal during the past 12 months is blank or invalid

## Had to skip a meal during the past 12 months should not be blank and answer should be in the value set.
(
  cv_j04_skipmeal_vlst <- section_j %>% 
    filter(!(j04_skipmeal %in% c(1, 2, 8, 9))) %>% 
    select_cv(j04_skipmeal, h = 'j04_skipmeal')
)[[1]]


### J05 - Ate less during the past 12 months is blank or invalid

## Ate less during the past 12 months should not be blank and answer should be in the value set.
(
  cv_j05_ateless_vlst <- section_j %>% 
    filter(!(j05_ateless %in% c(1, 2, 8, 9))) %>% 
    select_cv(j05_ateless, h = 'j05_ateless')
)[[1]]


### J06 - Ran out of food during the past 12 months is blank or invalide

## Ran out of food during the past 12 months should not be blank and answer should be in the value set.
(
  cv_j06_ranout_vlst <- section_j %>% 
    filter(!(j06_runout %in% c(1, 2, 8, 9))) %>% 
    select_cv(j06_runout, h = 'j06_runout')
)[[1]]


### J07 - Were hungry but did not eat during the past 12 months is blank or invalid

## Were hungry but did not eat during the past 12 months should not be blank and answer should be in the value set.
(
  cv_j07_hungrybutdidnoteat_vlst <- section_j %>% 
    filter(!(j07_didnoteat %in% c(1, 2, 8, 9))) %>% 
    select_cv(j07_didnoteat, h = 'j07_didnoteat')
)[[1]]


### J08 - Went without eating for a whole day during the past 12 months is blank or invalid

## Went without eating for a whole day during the past 12 months should not be blank and answer should be in the value set.
(
  cv_j08_wholeday_pst12mnths_blnk <- section_j %>% 
    filter(!(j08_wentwithout %in% c(1, 2, 8, 9))) %>% 
    select_cv(j08_wentwithout, h = 'j08_wentwithout')
)[[1]]


### J09 - Went without eating for a whole day from april to june 2022 is blank or invalid

## If J08 = 1, J09 (Went without eating for a whole day from April to June 2022) should not be blank and answer must be in the value set.
(
  cv_j09_wholeday_aprjun2022_vlst <- section_j %>% 
    filter(j08_wentwithout == 1, !(j09_worriedm %in% c(1, 2, 8, 9))) %>% 
    select_cv(j08_wentwithout, j09_worriedm, h = 'j09_worriedm')
)[[1]]


### J09 - Went without eating for a whole day from April to June 2022 is not blank

## If J08 = 2, 8 or 9, J09 (Went without eating for a whole day from April to June 2022) should be blank.
(
   cv_j09_wholeday_aprjun2022_notblnk <- section_j %>% 
     filter(j08_wentwithout %in% c(2 ,8, 9), !is.na(j09_worriedm)) %>% 
     select_cv(j08_wentwithout, j09_worriedm, h = 'j09_worriedm') 
)[[1]]