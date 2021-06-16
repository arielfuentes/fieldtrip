#libraries
library(readr)
library(purrr)
library(dplyr)
library(tidyr)
#data
ec_fl.lst <- list.files("data/4. Mediciones Velocidades/1. Mediciones recorrido electro corredor/", 
                        full.names = T) %>%
  set_names()
# ec <- read_delim(ec_fl.lst[1], delim = ",", skip = 15)

ec <- ec_fl.lst %>% map_dfr(~read_delim(.,skip = 15, delim = ","), 
                                .id="filename") %>% 
  mutate(filename=basename(filename)) %>%
  separate(col = "filename", sep = "_", into = letters[1:8]) %>%
  select(c(1, 9:16))
