Groundwater Pollution DK Metadata
================
Emil Trenckner Jessen & Johan Kresten Horsmans
10/06/2021

The following markdown contains metadata descriptions of the data used
for the `groundwater_pollution_dk.Rmd`-script (i.e. our Spatial
Analytics Exam 2021). For a detailed guide on how to download the data,
please see the repository
[README](https://github.com/emiltj/groundwater_pollution_dk/blob/master/README.md#prerequisites). For elaborate descriptions of how the data has been retrieved, please refer to <a href="Groundwater_Pollution_in_Denmark.pdf">```Groundwater_Pollution_in_Denmark.pdf```</a>, Section 2,2 (_"data acquisition"_)

**Spatial Polygon Data**

  - `denmark_administrative_outline_boundary` A shapefile containing a
    polygon in the shape of Denmark, courtesy of the software company
    IGIS MAP. Default CRS: __EPSG:4326__

  - `Markblok` A shapefile containing 476,657 polygons with all current
    agricultural fields in Denmark as of April 2021. This dataset is
    provided by the Ministry of Food, Agriculture and Fisheries of
    Denmark (Danish Agricultural Agency). AS:the access in 2023 is via Forside>Landbrug>Kort og markblokke>Hvordan får du adgang til data?> Download af data > Ga til landbrugsGIS > which should land in a repositoy of shapefiles: https://landbrugsgeodata.fvm.dk/  Default CRS: __EPSG:25832__

  - `Oekologiske_arealer_{2012 - 2020}` Shapefiles containing polygons
    of all organic agricultural fields in Denmark, registered each year
    between the period of 2012 to 2020. This dataset is provided by the
    Danish Agricultural Agency. Default CRS: __EPSG:25832__
      - `Oekologiske_arealer_2012` Shapefile containg 2,181 spatial polygons with all the new organic fields registered in 2012.
      - `Oekologiske_arealer_2013` Shapefile containg 2,614 spatial polygons with all the new organic fields registered in 2013.
      - `Oekologiske_arealer_2014` Shapefile containg 2,655 spatial polygons with all the new organic fields registered in 2014.
      - `Oekologiske_arealer_2015` Shapefile containg 1,349 spatial polygons with all the new organic fields registered in 2015.
      - `Oekologiske_arealer_2016` Shapefile containg 1,915 spatial polygons with all the new organic fields registered in 2016.
      - `Oekologiske_arealer_2017` Shapefile containg 287 spatial polygons with all the new organic fields registered in 2017.
      - `Oekologiske_arealer_2018` Shapefile containg 369 spatial polygons with all the new organic fields registered in 2018.
      - `Oekologiske_arealer_2019` Shapefile containg 886 spatial polygons with all the new organic fields registered in 2019.
      - `Oekologiske_arealer_2020` Shapefile containg 304 spatial polygons with all the new organic fields registered in 2020.

**Agricultural Measurement Data**

  - `nitrate.csv` A csv-file containing point data with samples of
    nitrate levels in Denmark. This dataset contains 14,350 measurements
    of nitrate concentrations at different geographic locations in
    Denmark from 1900 to March 2021. The dataset was provided by
    courtesy of De Nationale Geologiske Undersøgelser for Danmark og
    Grønland (GEUS). The included variables used in our analysis are:
    *__‘WKT’__ (coordinates)*, *__‘Seneste’__ (measurement date)*, *__‘Seneste
    mg/l’__ (nitrate concentration (milligram/liter))* and *__‘Indtag
    topdybde’__ (measurement depth (metres))*. Default CRS: __EPSG:25832__
