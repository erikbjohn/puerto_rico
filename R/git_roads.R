git_roads <- function(){
  library(data.table)
  library(sp)
  library(rgdal)
  library(raster)
  library(sf)

  roads <- rgdal::readOGR(path.expand('~/Dropbox/pkg.data/puerto_rico/Raw/streetview_roads.shp'))
  sapply(roads, sample.line)
  
  
}