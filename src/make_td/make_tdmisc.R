###########################
# Make miscelaneous tabulation datasets
# Input from raw: ae meddra
# Input from td:  
# Output: tdae
##########################


library(tidyverse)
library(lubridate)
library(glue)

source("src/external/functions.R")


raw <- readr::read_rds("data/raw/raw.rds")

items <- raw %>% pick("items")


###################################################
# Make tdae
###################################################


tdae <- raw %>% pick("ae") %>% 
  left_join(pick(raw,"meddra")) %>% 
  select(-(eventid:designversion), -(siteseq:subjectseq)) %>% 
  labeliser() %>% 
  arrange(subjectid, aespid) 
write_rds(tdae, "data/td/tdae.rds")


