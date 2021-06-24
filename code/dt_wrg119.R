#libraries
library(readr)
library(purrr)
library(dplyr)
library(tidyr)
library(sf)
library(tmap)
library(rosm)
#data
#bus service starting position
sp_119 <- st_read("data/cab_119.gpkg")
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

bg = osm.raster(as_Spatial(med_119[[1]]))
bg[bg[]>255]=255
bg[bg[]<0]=0

tm_119 <- tm_shape(bg) +
  tm_rgb() +
tm_shape(med_119[[1]]) +
  tm_dots("red") +
  tm_shape(sp_119) +
  tm_dots(col = "black", shape = 8, size = .5, )

tmap_save(tm_119, "output/test.png")
tm_lst <- lapply(X = med_119, FUN = function(x) tm_shape(bg) +
         tm_rgb() +
         tm_shape(x) +
         tm_dots("red") +
         tm_shape(sp_119) +
         tm_dots(col = "black", shape = 8, size = .5, ))
names(tm_lst) <- seq(1:length(tm_lst))
lapply(X = tm_lst, function(x) tmap_save(x, paste0("output/", x, ".png")))

