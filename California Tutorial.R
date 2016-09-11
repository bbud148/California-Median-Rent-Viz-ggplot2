library(ggplot2)
library(rgdal)
library(rgeos)
library(scales)
library(ggmap)
library(dplyr)
library(Cairo)
library(maptools)
library(scales)

tract <- readOGR(dsn = "./California Tract", layer = "cb_2015_06_tract_500k")
tract <- fortify(tract, region="GEOID")

county <- readOGR(dsn = "./California County Subdivisions", layer = "cb_2015_06_cousub_500k")  # load the shape file
county <- fortify(county, region = "COUNTYFP")  # turn into data frame

data <- read.csv("./California Data/ACS_14_5YR_B25064.csv", stringsAsFactors = FALSE)  
data <- data[,c("GEO.id2", "HD01_VD01")]  # take location and health insurance percentage
colnames(data) <- c("id", "Rent")
data <- data[-1,]
data$Rent <- as.numeric(data$Rent)

plotData <- left_join(tract, data)

p <- ggplot() +
  geom_polygon(data = plotData, aes(x = long, y = lat, group = group,
                                    fill = Rent)) +
  geom_polygon(data = county, aes(x = long, y = lat, group = group),
               fill = NA, color = "black", size = 0.25) +
  coord_map() +
  scale_fill_distiller(palette = "Spectral", direction = -1, labels = dollar,
                       breaks = pretty_breaks(n = 10)) +
  guides(fill = guide_legend(reverse = TRUE)) + 
  theme_nothing(legend = TRUE) + 
  labs(title = "Median Rent in California\n by Voting Tract", fill = "")
p