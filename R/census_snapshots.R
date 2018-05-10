census_snapshots <- function(){
  f_list <- list.files('~/Dropbox/pkg.data/puerto_rico/Snapshots/')
  panos_extract <- unique(stringr::str_extract(f_list, '(?<=panoId\\:).+(?= bearing)'))
  dt_panoids <- readRDS('~/Dropbox/pkg.data/puerto_rico/Raw/dt_panoids.rds')
  dt_panoids_done <- dt_panoids[pano_id %in% panos_extract]
  write.csv(dt_panoids_done[, .(location.lat, location.lng)], '~/Dropbox/pkg.data/puerto_rico/Raw/street.points.csv')
  # Dates so far
  dates_extract <- stringr::str_extract(f_list, '(?<=bearing\\:0 date\\:).+(?=.jpg)')
  table(dates_extract)
  
  f_list[which(dates_extract=='2018-03')]
  dt_panoids[pano_id=='CAoSK0FGMVFpcE9LUzhBQ2JxdGF2cE84dlRMOC1oSkU0ajBvYnNZRHd2SUoxa28.']
}