Habitat sensitivity R-scripting: Follow the data
========================================================
author: Philip Haupt
date: 2019-04-29
autosize: true
#width: 1440
#height: 900

Overview Slide
========================================================
left: 30%

<div class="header" style="margin-top:-100px;"align="right">
<img src="ne_logo.png" width=150 height=150 style="background-color:transparent; border:0px; box-shadow:none;"></img>
</div>


- Main script overview
        - Libraries
        - Functions (helper files)
        - User input section
- Stepwise process of following the data
        - GI Geoprocessing of habitat and boundaries and sub-biogeoregions
        - R Reading and processing
- Output
        - Written in R
        - Investigate outputs GIS

<div class="footer" style="margin-top:50px;">
<img src="ne_marine_footer_template.png" style="background-color:transparent; border:0px; box-shadow:none;"></img>
</div>

        
Main script
========================================================
- A single main script is used to call a list of functions to execute in  a stepwise manner
- Readme at top provides some objective and basic instructions and infomration, like system requirements, for the user
- All neccesary R libraries are specified
- User input section is included at the top where universal variables are specified.

![ms_readme](main_script_read_me.png)

R Libraries used
========================================================
left: 50%
- First two are to read and connect to the database using ODBC connections.
- Tidyverse to stringr are to shape data and work with text data columns
- Rgdal and sf are to deal with GI data.



```
library(RODBC)
library(DBI)
library(tidyverse)
library(plyr)
library(reshape2)
library(magrittr)
library(stringr)
library(rgdal)
library(sf)
```
***
![r_logo](R_logo.svg.png)

***
![rstudio](rstudio_logo.png)


User input
========================================================
![user_input](user_input.png)


Choose operations
========================================================
![operations](operations.png)


Functions (helper files)
========================================================
<div align="left">
<img src="functions_pic.png" width=350 height=500>
</div>

Each of these files contain commands to read, clean, shape, recombine the database data with the GIS data. They are called in a particular sequence from the Main script. Their outputs are passed into the R environemnt, where the next function picks up the output from the previous and and does the next step.

GI file preparation
========================================================
left: 60%

![habitat_map](habitat_map_200NM.png)
Fig. Habitat map

NE's *Benthic habitat* is **intersected** with *sub-bioregions* and *inshore/offshore boundaries*.
The benthic habitat layer is similar to the open source available on EMODnet, but includes a few classifications which NE have internally approved and have not ben accepted externally yet. This process developed is in clse collaboration with JNCC.

***
![sbgr](subbiogeoregions_20190418.png)
Fig. Sub-biogeoregions (inshore)

![uk_boundaries](official_waters.png)
Fig. UK marine boundaries

R data processing steps: overview
========================================================
<table class="table" style="">
<caption>Table. The 11 steps in the R code used to assign sensitivity levels to habitats in relation to the 39 standardised pressures.</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> Step </th>
   <th style="text-align:left;"> Objective </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> Read sensitivity data </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Obtain a list of distinct EUNIS codes with their sensitivity assessments (ranked) </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> Read GIS habitat map file </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> Clean geodata file; done from attribute table – optional stored table </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> Assign EUNIS levels based on number of characters in EUNISCode </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> Match biotopes between assessed and matched within each sbgr and within level of mapped EUNIS </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> Populate the sbgr biotope codes and replacing NA values with eunis codes in a sequential order, starting at eunis level 6, then 5 then 4, leaving the rest as NA. </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> Loads and runs script to join pressures to sbgr generated above. </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Compare and keep only maximum values for each biotope-pressure-activity-sub-biogeographic region combination. </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> Associate maximum sensitivity with GIS polygon Ids (and the habitat type assessed and the confidence of the assessments). </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> Save single GIS file as final output. </td>
  </tr>
</tbody>
</table>


R data processing steps: step 1
========================================================

```
Column names:
```

```
[1] "ActivityCode" "ActivityName" "PressureCode" "PressureName"
[5] "EUNISCode"    "EUNISName"    "ActSensRank" 
```

```
Example of the data:
```

```
    ActivityCode   ActivityName PressureCode
27         Z10.6 Demersal trawl           D6
262        Z10.6 Demersal trawl           D6
149        Z10.6 Demersal trawl           D6
308        Z10.6 Demersal trawl           D6
43         Z10.6 Demersal trawl           D6
                                                          PressureName
27  Abrasion/disturbance of the substrate on the surface of the seabed
262 Abrasion/disturbance of the substrate on the surface of the seabed
149 Abrasion/disturbance of the substrate on the surface of the seabed
308 Abrasion/disturbance of the substrate on the surface of the seabed
43  Abrasion/disturbance of the substrate on the surface of the seabed
    EUNISCode ActSensRank
27     A1.223      Medium
262    A5.244         Low
149    A3.312      Medium
308    A5.433         Low
43     A1.324        High
```


