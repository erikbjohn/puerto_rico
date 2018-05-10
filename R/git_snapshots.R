funSnapshots <- function(){
  source('R/git_panoids.R')
  load('~/Dropbox/pkg.data/api.keys/raw/l.pkg.rdata')
  api_key <- l.pkg$google
  dt_panoids_clean_path <-'~/Dropbox/pkg.data/puerto_rico/Clean/dt_panoids.rds'
  snapshots_path <- '~/Dropbox/pkg.data/puerto_rico/Snapshots/'
  dt_panoids <- readRDS(dt_panoids_clean_path)
  pano_ids <- unique(dt_panoids$pano_id)
  pano_ids <- sample(pano_ids, size = length(pano_ids), replace = FALSE)
  bearings <- c(0, 90, 180, 270)
  # Make sure to run by date...
  max_date_queries <- 25000
  n_date_query <- 1
  quota_count <- 1
  while(quota_count < max_date_queries){
    pano_id <- pano_ids[n_date_query]
    cat(pano_id, sep='\n')
    # Get the current metadata for the panoid 
    api <- list()
    api[[1]] <- 'https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300&pano='
    api[[2]] <- paste0(pano_id , '&')
    api[[3]] <- paste0('key=', api_key)
    api.url <- paste0(unlist(api), collapse = '')
    panorama <- try(unlist(rjson::fromJSON(file=api.url)))
    dt_panoid <- try(data.table::data.table(t(panorama)))
    pano_date <- dt_panoid$date
    # Check and see if the snapshot exists
    f_name_panos <- paste0('panoId:', pano_id, ' ', 'bearing:0 ', 'date:', pano_date,'.jpg')
    snapshot_location <- paste0(snapshots_path, f_name_panos)
    if(!file.exists(snapshot_location)){
      for(bearing in bearings){
        n_date_query <- n_date_query+1
        quota_count <- quota_count+1
        f_name_panos <- paste0('panoId:', pano_id, ' ', 'bearing:', bearing,' date:', pano_date,'.jpg')
        snapshot_location <- paste0(snapshots_path, f_name_panos)
        shotLoc <- paste0('https://maps.googleapis.com/maps/api/streetview?size=1200x600&pano=',
                          pano_id,
                          '&heading=', bearing,
                          '&pitch=-0.76&fov=', 60,'&key=', api_key)
        streetShot <- try(download.file(shotLoc, snapshot_location))  
      }
    } else {
      cat(f_name_panos, ' already exists', sep='\n')
      n_date_query <- n_date_query+1
    }
    cat(n_date_query, sep='\n')
  }
}