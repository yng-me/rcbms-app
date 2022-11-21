
print('Processing Section L...')

gather_section_l <- function(data, var, length, ...) {
  
  df_list <- list()
  
  for(i in 1:length) {
    p <- i
    if(length > 9) p <- sprintf('%02d', i)
    v <- paste0('^L', var, '_', p, '$')
    a <- paste0('^L', var + 1, '_OWNED_', p, '$')
    b <- paste0('^L', var + 1, '_RENTED_', p, '$')
    c <- paste0('^L', var + 1, '_RENT_FREE_', p, '$')
    t <- paste0('^L', var + 1, '_TOTAL_', p, '$')
    
    
    df_list[[i]] <- data %>% 
      mutate(type = LETTERS[i]) %>% 
      select(case_id, type, matches(v), matches(a), matches(b), matches(c), matches(t), ...) %>% 
      rename(
        (!!as.name(paste0('L', var))) := 3,
        (!!as.name(paste0('L', var + 1, '_OWNED'))) := 4,
        (!!as.name(paste0('L', var + 1, '_RENTED'))) := 5,
        (!!as.name(paste0('L', var + 1, '_RENT_FREE'))) := 6,
        (!!as.name(paste0('L', var + 1, '_TOTAL'))) := 7
      )
  }
  do.call('rbind', df_list)
}


gather_l <- function(data, filter, var, letters = NULL, ln = NULL) {
  l <- list()
  for(i in 1:15) {
    p <- sprintf('%02d', i)
    lno <- paste0('^L', var, '_LNO_', p, '$') 
    if(!is.null(lno)) {
      lno <- paste0('^L', ln, '_LNO_', p, '$')
    } 
    s <- paste0('^L', var, '_', p, '$')
    w <- paste0('^', filter, '_', p, '$')
    
    if(!is.null(letters)) {
      v <- paste0('^L', var, '_[', letters, ']_', p, '$')
      l[[i]] <- data %>% 
        select(case_id, L3, matches(lno), matches(s), matches(w), matches(v)) %>% 
        rename(line_number = 3) %>% 
        rename_at(vars(matches(v)), ~ str_remove(., '_\\d{2}$')) %>% 
        rename_at(vars(matches(s)), ~ str_remove(., '_\\d{2}$')) %>% 
        rename_at(vars(matches(w)), ~ str_remove(., '_\\d{2}$'))
    } else {
      l[[i]] <- data %>% 
        select(case_id, L3, matches(lno), matches(s), matches(w)) %>% 
        rename(line_number = 3) %>% 
        rename_at(vars(matches(s)), ~ str_remove(., '_\\d{2}$')) %>% 
        rename_at(vars(matches(w)), ~ str_remove(., '_\\d{2}$'))
    }
  }
  do.call('rbind', l)
}

gather_parcel <- function(data) {
  
  l <- list()
  
  for(i in 1:15) {
    p <- sprintf('%02d', i)
    c <- paste0('^L(2[6-9]|3[0-6])[A-C]_', p, '$')
    l[[i]] <- data %>% 
      select(case_id, matches(paste0('^L25_', p, '$')), matches(c), L37) %>% 
      rename(L25 = 2) %>% 
      rename_at(vars(matches(c)), ~ str_remove(., '_\\d{2}$'))
    
  }
  do.call('rbind', l) %>% 
    filter(L25 > 0) 

}


gather_aqua <- function(data) {
  
  l <- list()
  
  for(i in 1:15) {
    p <- sprintf('%02d', i)
    c <- paste0('^L((39|4[0-3])[A-C]|41)_', p, '$')
    l[[i]] <- data %>% 
      select(case_id, matches(paste0('^L38_', p, '$')), matches(c)) %>% 
      rename(L38 = 2) %>% 
      rename_at(vars(matches(c)), ~ str_remove(., '_\\d{2}$'))
    
  }
  do.call('rbind', l) %>% 
    filter(L38 > 0) 
  
}

gather_boat <- function(data) {
  
  l <- list()
  
  for(i in 1:15) {
    p <- sprintf('%02d', i)
    c <- paste0('^L5[2-4].*', p, '$')
    l[[i]] <- data %>% 
      select(case_id, L50, matches(paste0('^L51_', p, '$')), matches(c)) %>% 
      rename(L51 = 3) %>% 
      rename_at(vars(matches(c)), ~ str_remove(., '_\\d{2}$'))
    
    
  }
  do.call('rbind', l) %>% 
    filter(L51 > 0, L50 == 1)
}


get_occ <- function(data, var, set, c_var = NULL, c_set = NULL, d = L25) {
  a <- paste0(var, 'A')
  b <- paste0(var, 'B')
  c <- paste0(var, 'C')
  
  if(is.null(c_var) && is.null(c_set)) {
    data %>% 
      filter(
        {{d}} == 1 & !(!!as.name(a) %in% set) |
          {{d}} == 2 & !(!!as.name(a) %in% set) & !(!!as.name(b) %in% set) |
          {{d}} > 2 & !(!!as.name(a) %in% set) & !(!!as.name(b) %in% set) & !(!!as.name(c) %in% set)
      ) %>% 
      select(case_id, {{d}}, !!as.name(a), !!as.name(b), !!as.name(c))
  } else {
    
    f_a <- paste0(c_var, 'A')
    f_b <- paste0(c_var, 'B')
    f_c <- paste0(c_var, 'C')
    
    data %>% 
      filter(
        {{d}} == 1 & !(!!as.name(a) %in% set) & !!as.name(f_a) == c_set |
          {{d}} == 2 & !(!!as.name(a) %in% set) & !(!!as.name(b) %in% set) & !!as.name(f_a) == c_set & !!as.name(f_b) == c_set |
          {{d}} > 2 & !(!!as.name(a) %in% set) & !(!!as.name(b) %in% set) & !(!!as.name(c) %in% set) & !!as.name(f_a) == c_set & !!as.name(f_b) == c_set & !!as.name(f_c) == c_set
      ) %>% 
      select(case_id, {{d}}, !!as.name(a), !!as.name(b), !!as.name(c))
  }
}


# ---------------------------------------------------------------

section_l <- suppressWarnings(
  hpq_data$SECTION_L %>% 
    mutate(L2TLNO = str_trim(L2TLNO)) %>% 
    left_join(rov, by = 'case_id') %>% 
    filter(HSN < 7777, RESULT_OF_VISIT == 1, pilot_area == eval_area) %>% 
    select(case_id, pilot_area, starts_with('L'), -contains(c('SPECIFY', 'LAST'))) %>% 
    collect() %>% 
    mutate_at(vars(matches('L[246]_\\d{2}')), as.integer) %>% 
    rename_at(vars(matches('^L(20|45|56)_RENTFREE_\\d+$')), ~ str_replace(., 'RENTFREE', 'RENT_FREE'))
)

hpq_individual_age <- hpq_individual %>% 
  select(case_id_m, age_computed, LINENO)

hpq_individual_count <- hpq_individual %>% 
  count(case_id)

# L01 Missing and not in the value set
cv_l01_not_in_vs_and_missing <- section_l %>% 
  select(case_id, pilot_area, L1) %>% 
  filter(!(L1 %in% c(1, 2)))

cv_l02_missing_but_l01_is_yes <- section_l %>% 
  select(case_id, pilot_area, L1, L2TLNO) %>% 
  left_join(hpq_individual_count, by = 'case_id') %>% 
  filter(L1 == 1, !grepl('[A-Z]', L2TLNO)) %>% 
  select(case_id, L1, L2TLNO)

cv_l02_with_ans_but_l01_is_no <- section_l %>% 
  select(case_id, pilot_area, L1, L2TLNO, contains('L2_')) %>% 
  filter(L1 == 2, !is.na(L2TLNO)) %>% 
  select(case_id, L1, L2TLNO)

cv_l03_not_in_vs_and_missing <- section_l %>% 
  select(case_id, pilot_area, L3) %>% 
  filter(!(L3 %in% c(1, 2))) %>% 
  select(case_id, L3)

# ===============================================
section_l4_d <- hpq_data$SECTION_L4 %>% 
  filter(HSN < 7777, pilot_area == eval_area, !is.na(L4)) %>% 
  collect() %>% 
  mutate(case_id_m = paste0(case_id, sprintf('%02d', as.integer(L4)))) %>% 
  left_join(hpq_individual_age, by = 'case_id_m') 

section_l4 <- section_l4_d %>% 
  filter(age_computed >= 10) 

cv_l05_na <- section_l4_d %>% 
  filter(age_computed < 10)

cv_l05_missing <- section_l4 %>%  
  filter_at(vars(matches('^L5_[A-FZ]$')), any_vars(is.na(.))) %>% 
  select(case_id, LINENO, age_computed, matches('^L5_[A-FZ]$'))

cv_l05_all_no <- section_l4 %>% 
  filter_at(vars(matches('^L5_[A-FZ]$')), all_vars(. == 2)) %>% 
  select(case_id, LINENO, age_computed, matches('^L5_[A-FZ]$'))

cv_l06_invalid <- section_l4 %>% 
  filter(!(L6 %in% c(1:6, 9))) %>% 
  select(case_id, L4, L6)

cv_l06_a_inconsistent <- section_l4 %>% 
  filter(L6 == 1, L5_A != 1) %>% 
  select(case_id, L6, L5_A)

cv_l06_b_inconsistent <- section_l4 %>% 
  filter(L6 == 2, L5_B != 1) %>% 
  select(case_id, L6, L5_B)

cv_l06_c_inconsistent <- section_l4 %>% 
  filter(L6 == 3, L5_C != 1) %>% 
  select(case_id, L6, L5_C)

cv_l06_d_inconsistent <- section_l4 %>% 
  filter(L6 == 4, L5_D != 1) %>% 
  select(case_id, L6, L5_D)

cv_l06_e_inconsistent <- section_l4 %>% 
  filter(L6 == 5, L5_E != 1) %>% 
  select(case_id, L6, L5_E)

cv_l06_f_inconsistent <- section_l4 %>% 
  filter(L6 == 6, L5_F != 1) %>% 
  select(case_id, L6, L5_F)

cv_l06_other <- section_l4 %>% 
  filter(L6 == 9, is.na(L6_SPECIFY)) %>% 
  select(case_id, L6, L6_SPECIFY) 

cv_l07_a_invalid <- section_l4 %>% 
  filter(L6 == 1, !(L7_A %in% c(1:4))) %>% 
  select(case_id, L6, L7_A)

cv_l07_b_invalid <- section_l4 %>% 
  filter(L6 == 2, !(L7_B %in% c(1:4))) %>% 
  select(case_id, L6, L5_B)

cv_l07_c_invalid <- section_l4 %>% 
  filter(L6 == 3, !(L7_C %in% c(1:4))) %>% 
  select(case_id, L6, L5_C)

cv_l07_d_invalid <- section_l4 %>% 
  filter(L6 == 4, !(L7_D %in% c(1:4))) %>% 
  select(case_id, L6, L5_D)

cv_l07_e_invalid <- section_l4 %>% 
  filter(L6 == 5, !(L7_E %in% c(1:4))) %>% 
  select(case_id, L6, L5_E)

cv_l07_f_invalid <- section_l4 %>% 
  filter(L6 == 6, !(L7_F %in% c(1:4))) %>% 
  select(case_id, L6, L5_F)

cv_l08_invalid <- section_l4 %>% 
  filter_at(vars(matches('^L7_[A-FZ]$')), any_vars(. == 4)) %>% 
  filter(!grepl('[A-DZ]+', L8)) %>% 
  select(case_id, matches('^L7_[A-FZ]$'), L8)

cv_l09_invalid <- section_l4 %>% 
  filter(!(L9 %in% c(1, 2))) %>% 
  select(case_id, L9) 

cv_l10_invalid <- section_l4 %>% 
  filter(L9 == 1, is.na(L10A), is.na(L10B), is.na(L10C)) %>% 
  select(case_id, L9, L10A, L10B, L10C)
 
# ============================================================
cv_l11_lno <- section_l %>% 
  gather_l('(L5_A|L6|L7_A)', 11, 'A-KZ', ln = 11) %>% 
  filter(L3 == 1, L5_A == 1 | L6 == 1, L7_A == 1, is.na(line_number)) 

cv_l11_invalid <- section_l %>% 
  gather_l('(L5_A|L6|L7_A)', 11, 'A-KZ', ln = 11) %>% 
  filter(L3 == 1, L5_A == 1 | L6 == 1, L7_A == 1) %>% 
  filter_at(vars(matches('^L11_*')), any_vars(!(. %in% c(1, 2))))

cv_l11_all_no <- section_l %>% 
  gather_l('(L5_A|L6|L7_A)', 11, 'A-KZ', ln = 11) %>% 
  filter(L3 == 1, L5_A == 1 | L6 == 1, L7_A == 1) %>% 
  filter_at(vars(matches('^L11_*')), all_vars(. == 2))

# ============================================================

cv_l12 <- section_l %>%
  gather_section_l(12, 15) %>% 
  filter(L12 == 1, is.na(L13_OWNED) | is.na(L13_RENT_FREE) | is.na(L13_RENTED), is.na(L13_TOTAL)) 

cv_l13_total <- section_l %>%
  gather_section_l(12, 15) %>% 
  filter(L12 == 1, L13_OWNED + L13_RENT_FREE + L13_RENTED != L13_TOTAL) 

cv_l14_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_A|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_A_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, !(L14 %in% c(1, 2))) %>% 
  select(case_id, L3, L4TLNO, matches('^L(5_A|6|7_A)_\\d{2}$*'), L14)

cv_l15_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_A|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_A_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L14 == 1, !(L15 %in% c(1:3))) %>% 
  select(case_id, L4TLNO, L3, L14, L15, matches('^L(5_A|6|7_A)_\\d{2}$*'))

cv_l16_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_A|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_A_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L14 == 1, L15 == 1, !(L16 %in% c(1:9, 99))) %>% 
  select(case_id, L4TLNO, L3, L14, L15, L16, matches('^L(5_A|6|7_A)_\\d{2}$*'))

cv_l17_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_A|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_A_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L14 == 1, L15 == 1, L16 %in% c(1:5), L17 == 0 | is.na(L17)) %>% 
  select(case_id, L4TLNO, L3, L14, L15, L16, L17, matches('^L(5_A|6|7_A)_\\d{2}$*'))

cv_l16_L17_na <- section_l %>% 
  filter_at(vars(matches('^L(5_A|6)_\\d{2}$')), any_vars(. == 1)) %>%
  filter_at(vars(matches('^L7_A_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L14 == 1, L15 == 2, !is.na(L16) | !is.na(L17)) %>% 
  select(case_id, L4TLNO, L3, L14, L15, L16, L17, matches('^L(5_A|6|7_A)_\\d{2}$*'))

# ----------------------------------------------------------------------------------
cv_l18_lno <- section_l %>% 
  gather_l('(L5_B|L6|L7_B)', 18, 'A-FZ', 18) %>% 
  select(case_id, L3, everything()) %>% 
  filter(L3 == 1, L5_B == 1 | L6 == 1, L7_B == 1, is.na(line_number)) 

cv_l18_invalid <- section_l %>% 
  gather_l('(L5_B|L6|L7_B)', 18, 'A-FZ', 18) %>% 
  select(case_id, L3, everything()) %>% 
  filter(L3 == 1, L5_B == 1 | L6 == 1, L7_B == 1) %>% 
  filter_at(vars(matches('^L18_*')), any_vars(!(. %in% c(1, 2))))

cv_l18_all_no <- section_l %>% 
  gather_l('(L5_B|L6|L7_B)', 18, 'A-FZ', 18) %>% 
  select(case_id, L3, everything()) %>% 
  filter(L3 == 1, L5_B == 1 | L6 == 1, L7_B == 1) %>% 
  filter_at(vars(matches('^L18_*')), all_vars(. == 2))

# ============================================================
cv_l19 <- section_l %>% 
  gather_section_l(19, 9) %>% 
  filter(L19 == 1, is.na(L20_OWNED) | is.na(L20_RENT_FREE) | is.na(L20_RENTED), is.na(L20_TOTAL))

cv_l20_total <- section_l %>% 
  gather_section_l(19, 9) %>% 
  filter(L19 == 1, L20_OWNED + L20_RENT_FREE + L20_RENTED != L20_TOTAL)

cv_l21_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_B|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_B_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, !(L21 %in% c(1, 2))) %>% 
  select(case_id, L3, L21, matches('^L(5_B|6|7_B)_\\d{2}$'))

cv_l22_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_B|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_B_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L21 == 1, !(L22 %in% c(1:3))) %>% 
  select(case_id, L3, L21, matches('^L(5_B|6|7_B)_\\d{2}$'))

cv_l23_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_B|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_B_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L21 == 1, L22 == 1, !(L23 %in% c(1:6, 9))) %>% 
  select(case_id, L3, L21, L22, L23, matches('^L(5_B|6|7_B)_\\d{2}$'))

cv_l24_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_B|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_B_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L21 == 1, L22 == 1, L23 %in% c(1:4), is.na(L24) | L24 == 0) %>% 
  select(case_id, L3, L21, L22, L23, L24, matches('^L(5_B|6|7_B)_\\d{2}$'))

cv_l23_L24_na <- section_l %>% 
  filter_at(vars(matches('^L(5_B|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_B_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L21 == 1, L22 == 2, !is.na(L23) | !is.na(L24)) %>% 
  select(case_id, L3, L21, L22, L23, L24, matches('^L(5_B|6|7_B)_\\d{2}$'))

# ----------------------------------------------------------------------------------
cv_l25_lno <- section_l %>% 
  gather_l('(L5_[AB]|L6|L7_[AB])', 25) %>% 
  filter(L3 == 1, L5_A == 1 | L5_B == 1 | L6 == 1, L7_A == 1 | L7_B == 1, is.na(line_number))

# ----------------------------------------------------------------------------------

cv_l26_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L26', c(1, 2))

cv_l27_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L27', c(1, 2, 8))

cv_l28_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L28', c(1, 2, 8))

cv_l29_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L29', c(1:8, 98, 99))

cv_l30_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L30', c(1, 2, 8))

cv_l31_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L31', c(1, 2, 8))

cv_l32_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L32', c(1, 2, 8))

cv_l33_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L33', c(1, 2))

cv_l34_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L34', c(1, 2), c_var = 'L33', c_set = 1)

cv_l35_invalid <- section_l %>% 
  gather_parcel %>% 
  get_occ('L35', c(1, 2), c_var = 'L33', c_set = 2)

cv_l36_invalid <- section_l %>% 
  gather_parcel %>% 
  filter(
    L25 == 1 & L33A == 1 & (L36A == 0 | is.na(L36A)) |
      L25 == 2 & L33A == 1 & L33B == 1 & (L36A == 0 | is.na(L36A)) & (L36B == 0 | is.na(L36B)) |
      L25 > 2 & L33A == 1 & L33B == 1 & L33C == 1 & (L36A == 0 | is.na(L36A)) & (L36B == 0 | is.na(L36B)) &  (L36C == 0 | is.na(L36C))
  ) %>% 
  select(case_id, L25, matches('^L3[36]'))

cv_l37_invalid <- section_l %>% 
  gather_parcel %>% 
  filter(L25 == 1, is.na(L37) | L37 == 0) %>% 
  select(case_id, L25, L37)

# ----------------------------------------------------------------------------------

cv_l38_lno <- section_l %>% 
  gather_l('(L5_C|L6|L7_C)', 38) %>% 
  filter(L3 == 1, L5_C == 1 | L6 == 1, L7_C == 1, is.na(line_number)) 

cv_l39_invalid <- section_l %>% 
  gather_aqua %>% 
  get_occ('L39', c(1, 2), d = L38)

cv_l40_invalid <- section_l %>% 
  gather_aqua %>% 
  get_occ('L40', c(1:9), d = L38)

cv_l42_invalid <- section_l %>% 
  gather_aqua %>% 
  get_occ('L42', c(1:3), d = L38)

cv_l43_invalid <- section_l %>% 
  gather_aqua %>% 
  get_occ('L43', c(1:10, 99), d = L38)


# ----------------------------------------------------------------------------------

cv_l44 <- section_l %>%
  gather_section_l(44, 25) %>% 
  filter(L44 == 1, is.na(L45_OWNED) | is.na(L45_RENT_FREE) | is.na(L45_RENTED), is.na(L45_TOTAL))

cv_l45_total <-  section_l %>%
  gather_section_l(44, 25) %>% 
  filter(L44 == 1, L45_OWNED + L45_RENT_FREE + L45_RENTED != L45_TOTAL)

cv_l46_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_C|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_C_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, !(L46 %in% c(1, 2))) %>% 
  select(case_id, L3, L46, matches('^L(5_C|6|7_C)_\\d{2}$'))

cv_l47_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_C|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_C_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L46 == 1, !(L47 %in% c(1:3))) %>% 
  select(case_id, L3, L46, L47, matches('^L(5_C|6|7_C)_\\d{2}$'))

cv_l48_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_C|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_C_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L46 == 1, L47 == 1, !(L48 %in% c(1:6, 9))) %>% 
  select(case_id, L3, L46, L47, L48, matches('^L(5_C|6|7_C)_\\d{2}$'))

cv_l49_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_C|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_C_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L46 == 1, L47 == 1, L48 %in% c(1:4), is.na(L49) | L49 == 0) %>% 
  select(case_id, L3, L46, L47, L48, L49, matches('^L(5_C|6|7_C)_\\d{2}$'))

cv_l48_49_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_C|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_C_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L46 == 1, L47 == 2, !is.na(L48) | !is.na(L49)) %>% 
  select(case_id, L3, L46, L47, L48, L49, matches('^L(5_C|6|7_C)_\\d{2}$'))

# ----------------------------------------------------------------------------------

cv_l50_lno <- section_l %>% 
  gather_l('(L5_D|L6|L7_D)', 50, ln = '51') %>% 
  filter(L3 == 1, L5_D == 1 | L6 == 1, L7_D == 1, is.na(line_number)) 

cv_l52_invalid <- section_l %>% 
  gather_boat() %>% 
  get_occ('L52', c(1:3), d = L51)

cv_l53_invalid <- section_l %>% 
  gather_boat() %>% 
  get_occ('L53', c(1:4), d = L51)

cv_l54_invalid <- section_l %>% 
  gather_boat() %>% 
  get_occ('L54', c(1, 2), d = L51)

cv_l55 <- section_l %>%
  gather_section_l(55, 17) %>% 
  filter(L55 == 1, is.na(L56_OWNED) | is.na(L56_RENT_FREE) | is.na(L56_RENTED), is.na(L56_TOTAL)) %>% 
  select(case_id,  L56_OWNED, L56_RENT_FREE, L56_RENTED, L56_TOTAL)

cv_l56_total <-  section_l %>%
  gather_section_l(55, 17) %>% 
  filter(L55 == 1, L56_OWNED + L56_RENT_FREE + L56_RENTED != L56_TOTAL) %>% 
  select(case_id,  L56_OWNED, L56_RENT_FREE, L56_RENTED, L56_TOTAL)

cv_l57_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_D|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_D_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, !(L57 %in% c(1, 2))) %>% 
  select(case_id, L3, L57, matches('^(L[57]_D|L6)_\\d{2}$')) 

cv_l58_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_D|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_D_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L57 == 1, !(L58 %in% c(1:3))) %>% 
  select(case_id, L3, L57, L58, matches('^(L[57]_D|L6)_\\d{2}$')) 

cv_l59_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_D|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_D_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L57 == 1, L58 == 1, !(L59 %in% c(1:10, 99))) %>% 
  select(case_id, L3, L57, L58, L59, matches('^(L[57]_D|L6)_\\d{2}$')) 

cv_l60_invalid <- section_l %>% 
  filter_at(vars(matches('^L(5_D|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_D_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L57 == 1, L58 == 1, !(L59 %in% c(1:7)), is.na(L60) | L60 == 0) %>% 
  select(case_id, L3, L57, L58, L59, L60, matches('^(L[57]_D|L6)_\\d{2}$')) 

cv_l59_l60_na <- section_l %>% 
  filter_at(vars(matches('^L(5_D|6)_\\d{2}$')), any_vars(. == 1)) %>% 
  filter_at(vars(matches('^L7_D_\\d{2}$')), any_vars(. %in% c(1, 2))) %>% 
  filter(L3 == 1, L57 == 1, L58 == 2, !is.na(L59) | !is.na(L59)) %>% 
  select(case_id, L3, L57, L58, L59, L60, matches('^(L[57]_D|L6)_\\d{2}$')) 

rm(section_l, d_h03, l_list)
