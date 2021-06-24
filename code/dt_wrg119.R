#libraries
library(readr)
library(purrr)
library(dplyr)
library(tidyr)
library(sf)
library(tmap)
library(rosm)
library(stplanr)

#data
#bus service starting position
sp_119 <- st_read("data/cab_119.gpkg") %>%
  mutate(Name = c("Sur", "Norte"))
##field data
med_119_fl.lst <- list.files("data/4. Mediciones Velocidades/2. Mediciones 119/", 
                        full.names = T) %>%
  set_names()
# ec <- read_delim(ec_fl.lst[1], delim = ",", skip = 15)

med_119 <- med_119_fl.lst %>% map_dfr(~read_delim(.,skip = 15, delim = ","), 
                            .id="filename") %>% 
  mutate(filename=basename(filename)) %>%
  separate(col = "filename", sep = "_", into = letters[1:8]) %>%
  select(c(1, 9:16)) %>%
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>%
  group_split(a)

names(med_119) <- seq(1:length(med_119))
bg = osm.raster(as_Spatial(med_119[[1]]))
bg[bg[]>255]=255
bg[bg[]<0]=0

# tm_119 <- tm_shape(bg) +
#   tm_rgb() +
# tm_shape(med_119[[1]]) +
#   tm_dots("red") +
#   tm_shape(sp_119) +
#   tm_dots(col = "black", shape = 8, size = .5, )

# tmap_save(tm_119, "output/test.png")


tm_lst <- lapply(X = 1:8, FUN = function(x) tmap_save(tm_shape(bg) +
         tm_rgb() +
         tm_shape(med_119[[x]]) +
         tm_dots("red") +
         tm_shape(sp_119) +
         tm_dots(col = "black", shape = 8, size = .5, ),
         paste0("output/", names(med_119)[x], ".png")))

med_119_cln <- med_119[c(1:4, 6, 8)]
rm(med_119, bg)

lst_119_dist <- lapply(1:6, 
                       function(x) bind_cols(st_drop_geometry(med_119_cln[[x]]), 
                                             lst_dist[[x]])
                       )          
          
dat_119_dist <- bind_rows(lst_119_dist)
dat_119_dist_S <- select(dat_119_dist, -Norte) %>%
  rename(Dist = Sur) %>%
  group_by(a) %>%
  slice_min(Dist)
dat_119_dist_N <- select(dat_119_dist, -Sur) %>%
  rename(Dist = Norte) %>%
  group_by(a) %>%
  slice_min(Dist)
dat_119_dist <- bind_rows(dat_119_dist_S, dat_119_dist_N) %>%
  arrange(a, CreatedAt)
