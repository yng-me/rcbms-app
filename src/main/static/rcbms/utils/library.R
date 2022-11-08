
print('Loading packages...')

list_of_packages <- c(
  'tidyverse',
  'yaml',
  'stringi',
  'quarto',
  'janitor',
  'arrow',
  'readxl',
  'openxlsx',
  'lubridate',
  'jsonlite',
  'reactable'
)

installed <- installed.packages()[,'Package']

new_packages <- list_of_packages[!(list_of_packages %in% installed)]

if(!('rmarkdown' %in% installed)) {
  print('Installing RMarkdown...')
  install.packages('rmarkdown', repos = 'https://cloud.r-project.org/',  dep = TRUE)
}

if(length(new_packages)) {
  print('Installing other packages...')
  # print('Installing packages.')
  install.packages(new_packages, repos = 'https://cloud.r-project.org/')
  # print('Installation completed!')
}


options(
  defaultPackages = c(
    'datasets',
    'utils', 
    'grDevices', 
    'graphics', 
    'stats', 
    'methods', 
    'rmarkdown', 
    'tidyverse'
  )
)