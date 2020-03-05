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
unblocked_shots <- read.csv("/Users/liammcfall/HockeyExperimentation/unblocked_shots.csv")

unblocked_shots <- unblocked_shots %>%
  mutate(shot_distance = sqrt((89 - abs(coords_x))^2 + coords_y^2),
         shot_angle = abs(atan(coords_y / (89 - abs(coords_x))) * (180 / pi)),
         is_goal = ifelse(event_type == 'GOAL', 1, 0))
        # is_rebound = )

# Unblocked exploratory

test <- unblocked_shots %>%
  drop_na(is_goal) %>%
  drop_na(shot_distance) %>%
  drop_na(shot_angle)

test_model <- glm(is_goal ~ shot_distance + shot_angle, data = test)
summary(test_model)
test_model.probs <- predict(test_model, type = "response" )

test_wProbs <- test %>%
  mutate(prob = test_model.probs)

testQuery <- test_wProbs %>%
  group_by(event_team, season) %>%
  summarise(xG = sum(prob))

xG_cleaned <- test_wProbs %>% select(c(-num_on, -num_off, -players_on, -players_off))
xG_cleaned$defending_team <- NA
xG_cleaned$defending_team <- ifelse(xG_cleaned$event_team == xG_cleaned$home_team, xG_cleaned$away_team, xG_cleaned$home_team)
xG_cleaned$defending_team <- factor(xG_cleaned$defending_team, levels = c(1:31), labels = levels(xG_cleaned$event_team))

testQuery2 <- xG_cleaned %>%
  group_by(event_team = defending_team, season) %>%
  summarise(xG_against = sum(prob))

write.csv(xG_cleaned, "/Users/liammcfall/HockeyExperimentation/xG_cleaned.csv")

xG_cleaned <- read.csv("/Users/liammcfall/HockeyExperimentation/xG_cleaned.csv")

xG_agg1 <- xG_cleaned %>%
  group_by(event_team, season) %>%
  summarise(xG_for = sum(prob))

xG_agg2 <- xG_cleaned %>%
  group_by(event_team = defending_team, season) %>%
  summarise(xG_against = sum(prob))

xG_agg <- xG_agg1 %>%
  left_join(xG_agg2, by = c("event_team", "season"))

xG_agg <- xG_agg %>%
  mutate(xG_diff = (xG_for - xG_against))

write.csv(xG_agg, "/Users/liammcfall/HockeyExperimentation/xG_agg.csv")


