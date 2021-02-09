##-----------------------------------------------##
##    Author: Adela Sobotkova                    ##
##    Institute of Culture and Society           ##
##    Aarhus University, Aarhus, Denmark         ##
##    adela@cas.au.dk                             ##
##-----------------------------------------------##

#### Goals ####

# - Learn about Classification methods

#### Required R libraries ####

# We will use the sf, raster, and tmap packages.
# Additionally, we will use the spData and spDataLarge packages that provide new datasets.
# These packages have been preloaded to the worker2 workspace.

library(sf)
library(raster)
library(tmap)
library(spData)
library(spDataLarge)

#### Data sets #### 

# We will use a single data set:  `nz`. It is contained by the libraries
# It is an sf object with polygons representing the 16 regions of New Zealand.

#### Existing code ####

# Here are some examples of plotting population in  New Zealand.
# Your role is to create a map based on the suggestions below, 
# selecting the most meaningful classification style.

# Look at NZ population distribution
hist(nz$Population)

# This line of code applies the 'pretty' style rounding legend numbers. Try different numbers of classes.
tm_shape(nz) + tm_polygons(col = "Population", style = "pretty", n = 4)

# "Jenks" style further smooths over the gaps
tm_shape(nz) + tm_polygons(col = "Population", style = "jenks", n = 5)

# quantile style divides into 5 even groups
tm_shape(nz) + tm_polygons(col = "Population", style = "quantile", n=5)

# Equal interval style divides the distribution into even groups
tm_shape(nz) + tm_polygons(col = "Population", style = "equal", n = 5)

# Write maps above to objects and plot them side by side 
# with tmap_arrange() for better comparison
tmap_arrange(___,___,___,____)


#### Exercise I ####

# 1. What are the advantages and disadvantages of each classification method?
# 2. Choose the best classification and create a map with easily legible legend and all other essentials.
# (Select a suitable color palette from http://colorbrewer2.org/, north arrow, scale, map title, 
# legend title, reasonable number of breaks in the classification )
# 3. Which method and how many classes did you end up using to display
# your data? Why did you select that method?
# 4. What principles did you use in arranging the parts of your map layout the way you
# did and how did you apply these principles?

# Your solution

# /Start Code/ #


# /End Code/ #