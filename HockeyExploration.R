library(tidyverse)
library(lubridate)
library(magrittr)

events <- read.csv("/Users/liammcfall/HockeyExperimentation/nhl_events.csv")

# Event cleaning

events <- subset(events, select = - c(X, VAR1))
events$season <- factor(events$season)
events$game_id <- factor(events$game_id)
events$event_description <- as.character(events$event_description)
events$event_detail <- as.character(events$event_detail)
events$players_on <- as.character(events$players_on)
events$players_off <- as.character(events$players_off)
events$game_date <- date(events$game_date)

