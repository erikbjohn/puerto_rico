git_roads <- function(){
  if(!(file.exists('~/Dropbox/pkg.data/puerto_rico/Clean/roads.rds'))){
    library(data.table)
    library(sp)
    library(rgdal)
    library(raster)
    library(sf)
    roads <- rgdal::readOGR(path.expand('~/Dropbox/pkg.data/puerto_rico/Raw/streetview_roads.shp'))
    saveRDS(roads, file='~/Dropbox/pkg.data/puerto_rico/Clean/roads.rds')
  } else {
    roads <- readRDS('~/Dropbox/pkg.data/puerto_rico/Clean/roads.rds')
  }
  return(roads)
}