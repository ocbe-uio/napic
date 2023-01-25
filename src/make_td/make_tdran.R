library(tidyverse)
library(lubridate)
library(readxl)
source("src/external/functions.R")
###############
# Make tdran
# Input from raw: ran
# Input from the randomisation list
##############
# 
# args <- commandArgs(trailingOnly = TRUE)
# if (length(args)==0) {
#   randlist_name <- "Randlist_NAPiC_11Jan2018093156_total.xlsx" #standard dummy file
# } else if (length(args) != 0) {
#   randlist_name <- args[1]
# }

if (exists(params$randlist_name)){
  randlist_name <- params$randlist_name
} else {
  randlist_name <- "Randlist_NAPiC_11Jan2018093156_total.xlsx"
}


randlist <- read_excel(glue("data/raw/{randlist_name}")) %>% 
  rename(ranno = 'Randomisation No', arm = 'Allocation') %>% 
  select(ranno, arm) %>%
  mutate(arm = factor(arm, levels = c("Placebo", "Amoxicillin"), ordered = TRUE))
  

raw <- readr::read_rds("data/raw/raw.rds")
items <- raw %>% pick("items")

tdran <- pick(raw, "ran")

tdran <- tdran %>% left_join(randlist, by = "ranno") %>% 
  labeliser() %>% 
  labelled::set_variable_labels(arm = "Random allocation") 

write_rds(tdran, "data/td/tdran.rds")
