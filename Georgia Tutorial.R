library(ggplot2)
library(rgdal)
library(rgeos)
library(scales)
library(ggmap)
library(dplyr)
library(Cairo)
library(maptools)
library(scales)

tract <- readOGR(dsn = "./tract", layer = "gz_2010_13_140_00_500k")
tract <- fortify(tract, region="GEO_ID")

county <- readOGR(dsn = "./county", layer = "gz_2010_13_060_00_500k")  # load the shape file
county <- fortify(county, region = "COUNTY")  # turn into data frame

data <- read.csv("./Georgia Data/ACS_12_5YR_S2701.csv", stringsAsFactors = FALSE)  
data <- data[,c("GEO.id2", "HC03_EST_VC08")]  # take location and health insurance percentage
colnames(data) <- c("id", "percent")
data <- data[-1,]
data$id <- as.character(data$id)
data$percent <- as.numeric(data$percent)
data$percent <- data$percent/100
data$id <- paste("1400000US", data$id, sep="")  # unify data format

plotData <- left_join(tract, data)
p <- ggplot() +
  geom_polygon(data = plotData, aes(x = long, y = lat, group = group,
                                    fill = percent)) +
  geom_polygon(data = county, aes(x = long, y = lat, group = group),
               fill = NA, color = "black", size = 0.25) +
  coord_map() +
  scale_fill_distiller(palette = "Spectral", direction = 1,  labels = comma,
                       breaks = pretty_breaks(n = 10)) +
  guides(fill = guide_legend(reverse = TRUE)) + 
  theme_nothing(legend = TRUE) + 
  labs(title = "Percentage of Population Without\nHealth Insurance", fill = "")
p
