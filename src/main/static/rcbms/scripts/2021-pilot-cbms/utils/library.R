list_of_packages <- c(
  'arrow',
  'tidyverse',
  'janitor', 
  'readxl',
  'openxlsx',
  'lubridate',
  'parallel',
  'yaml',
  #'glue',
  'RM.weights'
)

new_packages <- list_of_packages[
  !(list_of_packages %in% installed.packages()[,'Package'])
]

if(length(new_packages)) install.packages(new_packages)

library(arrow)
library(tidyverse)
library(janitor)
library(readxl)
library(yaml)
library(openxlsx)
library(lubridate)
#library(glue)
library(parallel)
library(RM.weights)

config <- read_yaml('config.yml')
#d <- config$disaggregation

helpers <- paste0('./utils/helpers/', list.files('./utils/helpers/'))
lapply(helpers, source)

# Generate current date and transform into human readable format
formatted_date <- paste0(
  sprintf('%02d', day(today())), ' ', 
  month(today(), label = TRUE, abbr = FALSE), ' ',
  year(today())
)

excluded_from_export <- NULL

rm(new_packages, list_of_packages, helpers)