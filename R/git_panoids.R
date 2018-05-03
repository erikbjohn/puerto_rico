git_panoids <- function(){
  library(data.table)
  source('R/git_roads.R')
  source('R/sample.line.R')
  source('R/git_road_panoid.R')
  pano_id <- NULL
  # Initialize api and paths
  load('~/Dropbox/pkg.data/api.keys/raw/l.pkg.rdata')
  api_key <- l.pkg$google
  # Subset on roads that have an actual panoid
  roads_pano <- git_road_panoid()
  roads_pano <- roads_pano[!is.na(pano_id)]
  roads_pano <- roads_pano[, n_osm:=.N, by=osm_id]
  # For each osm that has an actual pano_id, find more locations of pictures
  roads <- git_roads()
  roads <- roads[which((roads@data$osm_id %in% roads_pano$osm_id)), ]
  # writeOGR(roads, dsn='/home/ebjohnson5/Dropbox/pkg.data/puerto_rico/Raw/maps', 'roads_panos', driver='ESRI Shapefile')
  dt_panoids_raw_path <- '~/Dropbox/pkg.data/puerto_rico/Raw/dt_panoids.rds'
  
  # Break up each of the roads into much smaller points
  if(!(file.exists(dt_panoids_raw_path))){
    dt_panoids <- data.table()
  } else {
    dt_panoids <- readRDS(dt_panoids_raw_path)
    roads <- roads[which(!(roads@data$osm_id %in% unique(dt_panoids$osm_id))), ]
  }
 
  for(i_road in 1:length(roads)){
    dt_road <- data.table()
    if((i_road %% 10)==0){
      cat(i_road, 'of', length(roads),'\n')
      saveRDS(dt_panoids, dt_panoids_raw_path)
    }
    road <- roads[i_road, ]
    l_sample <- tryCatch(sample.line(road, sdist = 0.005))
    if(!is.na(l_sample[1][1])){
      x_road <- l_sample[, 1]
      y_road <- l_sample[, 2]
      dt_sample <- data.table(query_lon = x_road, query_lat = y_road)
    } else {
      dt_sample <- data.table(query_lon = NA, query_lat = NA)
    }
    dt_sample$query_sample_id <- 1:nrow(dt_sample)
    dt_sample$osm_id <- as.character(road$osm_id)
    dt_sample <- dt_sample[!(is.na(query_lon))]
    # Query google for pano_ids
    for(i_sample in 1:nrow(dt_sample)){
      sampleId <- dt_sample[i_sample]$query_sample_id
      osmId <- dt_sample[i_sample]$osm_id
      lat <- dt_sample[i_sample]$query_lat
      lon <- dt_sample[i_sample]$query_lon
      api <- list()
      api[[1]] <- 'https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300&location='
      api[[2]] <- paste0(lat, ',', lon, '&')
      api[[3]] <- paste0('key=', api_key)
      api.url <- paste0(unlist(api), collapse = '')
      panorama <- try(unlist(rjson::fromJSON(file=api.url)))
      dt_panoid <- try(data.table::data.table(roads_point_id = sampleId,
                                              osm_id = osmId,
                                              t(panorama)))
      dt_road <- rbindlist(list(dt_road, dt_panoid), use.names = TRUE, fill=TRUE)
    }
    dt_road <- dt_road[!is.na(pano_id)]
    if(nrow(dt_road)>0){
      dt_road <- unique(dt_road[, .(osm_id, copyright, date, location.lat, location.lng, pano_id)])
      dt_panoids <- rbindlist(list(dt_panoids, dt_road), use.names=TRUE, fill=TRUE)
    }
  }
}
  
  
 # Take pictures