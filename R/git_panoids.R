git_panoids <- function(){
  source('R/create_road_sample_points.R')
  pano_id <- NULL
  # Initialize api and paths
  load('~/Dropbox/pkg.data/api.keys/raw/l.pkg.rdata')
  api_key <- l.pkg$google
  # Load package data from dropbox
  panoids_raw_path <- '~/Dropbox/pkg.data/puerto_rico/Raw/panoids.rds'
  panoids_clean_path <- '~/Dropbox/pkg.data/puerto_rico/Clean/panoids.rds'
  if (file.exists(panoids_clean_path)){
    dt <- readRDS(panoids_clean_path)
  } else {
    # Load parcel data to build address list
    if(file.exists(panoids_raw_path)){
      dt <- readRDS(panoids_raw_path)
      samples_done <- unique(dt$osm_id)
    } else {
      dt <- data.table(roads_point_id = as.integer(),
                       copyright = as.character(),
                       date = as.character(),
                       location.lat = as.numeric(), 
                       location.lng = as.numeric(),
                       pano_id = as.character(),
                       status = as.character())
      samples_done <- NA
    }
    dt_sample_points <- create_road_sample_points()
    dt_sample_points <- dt_sample_points[!(osm_id %in% samples_done)]
    cat('Processing', nrow(dt_sample_points), 'points')
    tic <- Sys.time()
    n.echo <- 100
    n_points <- nrow(dt_sample_points)
    for (i_sample in 1:n_points){
      if((i_sample %% 100) == 0){
        cat(i_sample, '\n')
        saveRDS(dt, panoids_raw_path)
      }
      sampleId <- dt_sample_points[i_sample]$sample_id
      osmId <- dt_sample_points[i_sample]$osm_id
      lat <- dt_sample_points[i_sample]$lat
      lon <- dt_sample_points[i_sample]$lon
      api <- list()
      api[[1]] <- 'https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300&location='
      api[[2]] <- paste0(lat, ',', lon, '&')
      api[[3]] <- paste0('key=', api_key)
      api.url <- paste0(unlist(api), collapse = '')
      panorama <- try(unlist(rjson::fromJSON(file=api.url)))
      dt_panoid <- try(data.table::data.table(roads_point_id = sampleId,
                                              osm_id = osmId,
                                              t(panorama)))
      # Save the road pano match
      dt <- rbindlist(list(dt, dt_panoid), use.names = TRUE, fill = TRUE)
    }
    saveRDS(dt, panoids_clean_path)
  }
  return(dt)
}
  
   