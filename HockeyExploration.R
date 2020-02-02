library(tidyverse)
library(lubridate)
library(magrittr)

'''
filenames <- list.files(full.names=TRUE)
All <- lapply(filenames,function(i){
  read.csv(i)
})
events <- do.call(rbind.data.frame, All)
write.csv("/Users/liammcfall/HockeyExperimentation/nhl_events.csv")
'''

events <- read.csv("/Users/liammcfall/HockeyExperimentation/nhl_events.csv")

# Event cleaning

events <- subset(events, select = -X)
events$season <- factor(events$season)
events$game_id <- factor(events$game_id)
events$event_description <- as.character(events$event_description)
events$event_detail <- as.character(events$event_detail)
events$players_on <- as.character(events$players_on)
events$players_off <- as.character(events$players_off)
events$game_date <- date(events$game_date)

