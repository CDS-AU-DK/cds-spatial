##########################################

# Library
library(sf)
library(tidyverse)
library(spatstat)


# Data
mounds <- st_read("../data/KAZ_mounds.shp")
boundary <- st_read("../data/KAZ_surveyarea.shp")

plot(mounds$geometry); plot(boundary$geometry, add =T)

box <- st_make_grid(mounds, n=1) 
hull <- st_convex_hull(st_union(mounds$geometry))
plot(mounds$geometry);plot(hull, add=TRUE)
plot(mounds$geometry);plot(box, add=TRUE)
plot(mounds$geometry);plot(boundary$geometry, add=TRUE)
# ok so we have a number of options for study area


################ CREATING A PPP

## Let's make ppp with a default boundary

# Make mounds into a ppp object
?as.ppp()
?as.owin()
box <- as.owin(box)
moundpt <- ppp(st_coordinates(mounds)[,1],
               st_coordinates(mounds)[,2], 
                window = box)
moundpt
plot(moundpt)


################ CLUSTERING OR DISPERSAL?

# Test clustering in a couple ways

testnnd <- nndist(moundpt)
hist(testnnd)

testG <- Gest(moundpt)
plot(testG)

testK <- Kest(moundpt, correction = 'border')
plot(testK)
plot(testK, . / pi * r ^ 2 ~ r )
plot(testK , . - pi * r ^ 2 ~ r )

############### HOW DO TRENDS CHANGE IF WE CHANGE THE WINDOW?

## Attempt 1: Eliminate outliers and use convex hull for a window

# First, simplify boundary and buffer it to find outliers

?st_simplify()
b <- st_simplify(boundary, dTolerance = 100)
b <- st_union(bound)
b_buff <- st_buffer(b, dist= 500)
plot(mounds$geometry);plot(b_buff, add=TRUE)

# Remove outliers and create a small convex hull

mounds_int <- st_intersection(mounds, b_buff)
hull_sm <- st_convex_hull(st_union(mounds_int))

plot(mounds_int$geometry);plot(hull_sm, add=TRUE)

# Create a window
library(maptools)
?owin()
?as.owin()
mw <- owin(as(hull_sm, "Spatial"))
mw <- as.owin(as(hull_sm, "Spatial"))

# Erroring out? No worries! Check out this vignette:
# https://rdrr.io/cran/spatstat/man/convexhull.xy.html
x <- runif(30)
y <- runif(30)
w <- convexhull.xy(x,y)
plot(owin(), main="convexhull.xy(x,y)", lty=2)
plot(w, add=TRUE)
points(x,y)

# How do we pull out the coordinates?
x <- st_coordinates(mounds_int)[,1]
y <- st_coordinates(mounds_int)[,2]
w <- convexhull.xy(x,y)
plot(owin(), main="convexhull.xy(x,y)", lty=2)
plot(w)
points(x,y, add=TRUE)

###################

# Finally, create the ppp
?ppp
?as.ppp()

# two equivalent approaches
mounds_ppp <- ppp(x,y, window = w) 
m_ppp <- as.ppp(st_coordinates(mounds_int), W=w)

plot(m_ppp)


# Test clustering in a couple ways
library(spatstat)

testnnd2 <- nndist(m_ppp)
hist(testnnd2)

testG2 <- Gest(m_ppp)
plot(testG2)

testK2 <- Kest(m_ppp, correction = 'border')
plot(testK2, . - pi * r ^ 2 ~ r)
plot(testK, . - pi * r ^ 2 ~ r)

## Look at everything
par(mfrow=c(1,2))
hist(testnnd)
hist(testnnd2)

plot(testG)
plot(testG2)

plot(testK, main = "Ripley's K in Bounding Box")
plot(testK2, main ="Ripley's K in Convex Hull")

plot(moundpt)
plot(mounds_ppp)

plot(testK,  . - pi * r ^ 2 ~ r, main = "Ripley's K in Bounding Box")
plot(testK2,  . - pi * r ^ 2 ~ r, main ="Ripley's K in Convex Hull")

par(mfrow=c(1,1))

## Attempt 2: We create a window on the basis of survey coverage
# If some mounds stay outside that is ok, we help combat edge effects.


# Simplify boundary and buffer it
?st_simplify()
b <- st_simplify(boundary, dTolerance = 100)
b <- st_union(b)
plot(b)
plot(mounds$geometry);plot(b, add=TRUE)

b_buff <- st_buffer(b, dist=250)
plot(mounds$geometry);plot(b_buff, add=TRUE)

##################################### MARKED PPP
?inner_join
?split.ppp()
?marks()

head(mounds)
data <- read_csv("../data/KAZ_mdata.csv")
head(data)
tail(data)
missing <- data[is.na(data$Robbed), "MoundID"]

levels(factor(data$LandUse))
data$LandUse <- factor(data$LandUse)
levels(factor(data$Robbed))

data <- data %>% 
  filter(!is.na(Robbed)) %>% 
  mutate(TRAP_Code=MoundID,
         Robbed2 = factor(case_when(Robbed == 0 ~ "Not robbed",
                            Robbed == 1 ~ "Robbed")),
         ConditionBin = factor(case_when(Condition < 3 ~ "Good",
                                  Condition >=3 ~ "Damaged")))

which(is.na(data$Robbed2))

m_marks <- mounds_int %>% 
  inner_join(data[,2:8], by="TRAP_Code")
dim(m_marks)

m_marks
names(m_marks)


mounds_mpp <- as.ppp(st_coordinates(m_marks), W=w)
plot(mounds_mpp)
mounds_mpp

marks(mounds_mpp) <- m_marks$ConditionBin # assigning marks by vector
mpp <- mounds_mpp
marks(mpp)<- m_marks$Robbed2

# works better than by dataframe, or perhaps it is happy with a single mark at a time

##################################### Spatial Segregation

mounds_robbed <- split(mounds_mpp, "ConditionBin")
plot(split(mounds_mpp))
mounds_condition <- split(m_ppp, "ConditionBin")

plot(density(mounds_robbed))
plot(density(mounds_condition))

robbed_density <- density(mounds_robbed)
condition_density <- density(mounds_condition)


# Calculate the fraction of unrobbed mounds
frac_m_notrobbed <- robbed_density[[2]]/  #not robbed divided by sum
  (robbed_density[[1]] + robbed_density[[2]])
plot(frac_m_notrobbed)

frac_good <- condition_density[[2]]/  #not robbed divided by sum
  (condition_density[[1]] + condition_density[[2]])
plot(frac_good)

################################ Bandwidth and simulation

bw_choice <- spseg(mounds_ppp, 
  h = seq(100,1000, by = 50),
  opt = 1)

bw_choice$cv
plotcv(bw_choice); abline(v = bw_choice$hcv, lty = 2, col = "red")

bw_choice$hcv  # best bandwidth for a ConditionBin kernel appears to be 600m
# best kernel bandwidth for moundpt is 900

seg10 <- spseg(
  pts = mounds_ppp, 
  h = 600,
  opt = 3,
  ntest = 1000, 
  proc = FALSE)

plotmc(seg10, "Damaged") # not very meaningful because of mixed mounds and mixed effects
plotmc(seg10, "Good")
################################### Map  ########

# Get the number of columns in the data so we can 
# rearrange to a grid
ncol <- length(seg10$gridy)

# Rearrange the probability column into a grid
prob_damage<- list(x = seg10$gridx,
                     y = seg10$gridy,
                     z = matrix(seg10$p[, "Damaged"],
                                ncol = ncol))
image(prob_damage) # this georeferences the image within original coordinates!!! IMPORTANT


# Rearrange the p-values, but choose a p-value threshold
p_value <- list(x = seg10$gridx,
                y = seg10$gridy,
                z = matrix(seg10$stpvalue[, "Damaged"] < 0.05,
                           ncol = ncol))
contour(p_value)

image(prob_damage);contour(p_value, add = TRUE)

############################### NOT NECESSARY

# Create a mapping function
library(tmaptools)
install.packages("OpenStreetMap")
library(OpenStreetMap)
library(raster)
segmap <- function(prob_list, pv_list, low, high){
  
  # background map
  library(raster)
  kaz_osm <- read_osm(mounds, zoom = 10)
  image(kaz_osm)
  
  # p-value areas
  image(pv_list, 
        col = c("#00000000", "#FF808080"), add = TRUE) 
  
  # probability contours
  contour(prob_list,
          levels = c(low, high),
          col = c("#206020", "red"),
          labels = c("Low", "High"),
          add = TRUE)
  
  # boundary window
  plot(w, add = TRUE)
}

# Map the probability and p-value
segmap(prob_damage, p_value, 0.05, 0.15)
