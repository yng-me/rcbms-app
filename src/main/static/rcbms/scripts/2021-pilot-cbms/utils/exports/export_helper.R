addSuperSubScriptToCell <- function(
    texto,
    size = '10',
    colour = '000000',
    font = 'Arial',
    family = '2',
    bold = FALSE,
    italic = FALSE,
    underlined = FALSE
  ) {
  

  #finds the string that you want to update
  stringToUpdate <- which(
    sapply(
      tb$sharedStrings, 
      function(x) { 
        grep(pattern = '~.*~', x)
      }
    ) == 1)
  
  
  #splits the text into normal text, superscript and subcript
  #normal_text <- str_split(texto, "\\[.*\\]|~.*~") %>% pluck(1) %>% purrr::discard(~ . == "")
  normal_text <- str_split(texto, "~.*~") %>% pluck(1) %>% purrr::discard(~ . == "")
  
  #sub_sup_text <- str_extract_all(texto, "\\[.*\\]|~.*~") %>% pluck(1)
  sub_sup_text <- str_extract_all(texto, "~.*~") %>% pluck(1)
  
  if (length(normal_text) > length(sub_sup_text)) {
    sub_sup_text <- c(sub_sup_text, "")
  } else if (length(sub_sup_text) > length(normal_text)) {
    normal_text <- c(normal_text, "")
  }
  # this is the separated text which will be used next
  texto_separado <- map2(normal_text, sub_sup_text, ~ c(.x, .y)) %>% 
    reduce(c) %>% 
    purrr::discard(~ . == "")
  
  #formatting instructions
  
  sz    <- paste('<sz val =\"',size,'\"/>', sep = '')
  color   <- paste('<color rgb =\"',colour,'\"/>', sep = '')
  rFont <- paste('<rFont val =\"',font,'\"/>', sep = '')
  fam   <- paste('<family val =\"',family,'\"/>', sep = '')
  
  #if its sub or sup adds the corresponding xml code
  sub_sup_no <- function(texto) {
    
    #if(str_detect(texto, "\\[.*\\]")){
    #  return('<vertAlign val=\"subscript\"/>')
    if (str_detect(texto, "~.*~")) {
      return('<vertAlign val=\"superscript\"/>')
    } else {
      return('')
    }
  }
  
  #get text from normal text, sub and sup
  get_text_sub_sup <- function(texto) {
    str_remove_all(texto, "~")
  }
  
  #formating
  if(bold){
    bld <- '<b/>'
  } else{bld <- ''}
  
  if(italic){
    itl <- '<i/>'
  } else{itl <- ''}
  
  if(underlined){
    uld <- '<u/>'
  } else{uld <- ''}
  
  #get all properties from one element of texto_separado
  
  get_all_properties <- function(texto) {
    
    paste0(
      '<r><rPr>',
      sub_sup_no(texto),
      '</rPr><t xml:space="preserve">',
      get_text_sub_sup(texto),
      '</t></r>'
    )
  }

  # use above function in texto_separado
  newString <- map(texto_separado, ~ get_all_properties(.)) %>% 
    reduce(paste, sep = "") %>% 
    {c("<si>", ., "</si>")} %>% 
    reduce(paste, sep = "")
  
  # replace initial text
  tb$sharedStrings[stringToUpdate] <- newString
}
