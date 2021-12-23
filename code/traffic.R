library(hereR)
library(sf)
set_key("xyz")

opmina1 <- st_read("data/OpMinaRT2.gpkg") %>%
  st_buffer(dist = 50000)

flows <- flow(
  aoi = opmina1
)

plot(flows)

flows %>%
  st_write("output/flowsopmin2.gpkg")
