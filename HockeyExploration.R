library(haven)
library(tidyverse)
library(lubridate)
library(magrittr)

events <- read.csv("/Users/liammcfall/HockeyExperimentation/nhl_events.csv")

# Event cleaning

events <- as.data.frame(events)
events <- subset(events, select = -VAR1)
events[events == "NA"] <- NA
events$game_date <- date(events$game_date)
