#libraries
library(readr)
library(purrr)
library(dplyr)
library(tidyr)
#data
ec_fl.lst <- list.files("data/8. Rutas por GPS (Visita Terreno)/DSAL/", 
                        full.names = T) %>%
  set_names()
# ec <- read_delim(ec_fl.lst[1], delim = ",", skip = 15)

ec <- ec_fl.lst %>% map_dfr(~read_delim(.,skip = 15, delim = ","), 
                                .id="filename") %>% 
  mutate(filename=basename(filename)) %>%
  separate(col = "filename", sep = "_", into = letters[1:8]) %>%
  select(c(1, 9:16))

library(sf)
library(lubridate)

dist <- st_as_sf(ec, coords = c("Longitude", "Latitude"), crs = 4326) %>%
  group_by(a) %>%
  summarise(do_union = F) %>%
  st_cast("LINESTRING") %>%
  mutate(dist_l = units::set_units(st_length(.), km)) %>%
  # st_write("output/elsalvador.gpkg")
  st_drop_geometry()

time <- ec %>%
  group_by(a) %>%
  summarise(min = min(CreatedAt),
            max = max(CreatedAt)) %>%
  mutate(t = units::set_units(as.numeric(as.duration(max - min))/3600, hr)) %>%
  select(-c("min", "max"))

dt <- left_join(dist, time) %>%
  mutate(vel = dist_l/t) %>%
  readr::write_delim("output/velDSAL.csv", delim = ";")
