create_road_sample_points <- function(){
  source('R/git_roads.R')
  road_sample_points_location <- '~/Dropbox/pkg.data/puerto_rico/Clean/roads_sample_points.rds'
  road_sample_points_work_location <- '~/Dropbox/pkg.data/puerto_rico/Raw/roads_sample_points_work.rds'
  if(!(file.exists(road_sample_points_location))){
    roads <- git_roads()
    if(!(file.exists(road_sample_points_work_location))){
      dt_road_points <- data.table(lon = as.numeric(), lat=as.numeric(), sample_id=as.integer(), osm_id=as.integer())
    } else {
      dt_road_points <- readRDS(road_sample_points_work_location)
      roads_done <- dt_road_points$osm_id
      roads <- roads[!(roads@data$osm_id %in% roads_done), ]
    }
    t_end <- Sys.time()
    for(i_road in 1:length(roads)){
      if((i_road %% 100)==0){
        t_end <- Sys.time()
        cat(i_road, 'of', length(roads), '\n')
        saveRDS(dt_road_points, file=road_sample_points_work_location)
        t_start <- Sys.time()
        cat(t_start-t_end, '\n')
      }
      road <- roads[i_road, ]
      l_sample <- tryCatch(sample.line(road))
      if(!is.na(l_sample[1][1])){
        x_road <- l_sample[, 1]
        y_road <- l_sample[, 2]
        dt_sample <- data.table(lon = x_road, lat = y_road)
      } else {
        dt_sample <- data.table(lon = NA, lat = NA)
      }
      dt_sample$sample_id <- 1:nrow(dt_sample)
      dt_sample$osm_id <- as.character(road$osm_id)
      
      dt_road_points <- rbindlist(list(dt_road_points, dt_sample), use.names = TRUE, fill=TRUE)
      saveRDS(dt_road_points, file=road_sample_points_location)
    }
   saveRDS(dt_road_points, file=road_sample_points_location)
  } else {
    dt_road_points <- readRDS(road_sample_points_location)
  }
  return(dt_road_points)
}
