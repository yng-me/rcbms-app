library(tidyverse)
library(yaml)
library(stringi)
library(arrow)
library(janitor)
library(readxl)
library(openxlsx)
library(lubridate)
library(jsonlite)
library(reactable)

wd_ref_path <- '..'

source(paste0(wd_ref_path, '/utils/references.R'))
fetch_parquet <- paste0(wd_ref_path, '/data/parquet/', fetch_records, '.parquet')

hpq <- setNames(
  lapply(fetch_parquet, open_dataset),
  fetch_records
)