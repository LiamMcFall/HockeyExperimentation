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

# Shot attempts

unblocked_shot_types <- c('GOAL', 'MISS', 'SHOT')

unblocked_shots <- events %>%
  filter(event_type %in% unblocked_shot_types)

#write.csv(unblocked_shots, "/Users/liammcfall/HockeyExperimentation/unblocked_shots.csv")

unblocked_shots <- unblocked_shots %>%
  mutate(shot_distance = sqrt((89 - abs(coords_x))^2 + coords_y^2),
         shot_angle = abs(atan(coords_y / (89 - abs(coords_x))) * (180 / pi)),
         is_goal = ifelse(event_type == 'GOAL', 1, 0))

# Unblocked exploratory

test_model <- glm(is_goal ~ shot_distance + shot_angle, data = unblocked_shots)
summary(test_model)
