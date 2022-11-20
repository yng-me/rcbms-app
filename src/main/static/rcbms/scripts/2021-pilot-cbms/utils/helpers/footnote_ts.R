footnote_placement <- function(placement) {
  
  number_to_letter <- function(letter) match(letter, LETTERS[1:26])
  
  suppressWarnings(
    str_split(placement, '')[[1]] %>% 
      tibble() %>% 
      rename(c = 1) %>% 
      mutate_all(toupper) %>% 
      mutate(c = if_else(
        c %in% LETTERS[1:26], 
        number_to_letter(c), 
        as.integer(c))
      ) %>% 
      pull(c)
  )
}

