# marine_biotope_sensitivity
Sensitivity of marine benthic biotopes to pressures caused by activities which have been assessed in Natural England's conservation advice.


## Project aim:
This project aims to assign sensitivities of benthic biotopes to the habitat map. This is a sub-project within the larger project which considers the impacts on benthic habitat arising from a displacement in fishing pressure.

The purpose of the code is to develop spatial layers indicating the sensitivities of various fine-scale benthic biotopes to respective pressures resulting from a range of activities. The code, in essence, needs to join activity-pressure-sensitivity data to GIS map of benthic biotopes. The code will extract the GIS and Access database data from their sources, then associate finescale benthic habitat to broad-scale habitat (based on sub biogeoregional zones), and the rejoin the now wrangled-data (Sub-biogeoregional Biotope Activity Pressure Sensitivity) to the GIS data.

## Data sources:
GIS habitat map based on JNCC collaborative MESH which has been updated from a variety of sources. The EUNIS levels included in this map range from 1 to 6.

Natural England's conservation advice - sensitivity assessmetns. The benthic biotopes are EUNIS level 4 - 6.

## Crux of the methods
The mismatch between the EUNIS levels that have been assessed and those that appear on the map is addressed within the code. It uses probaboility of occurence (based on a biogeographical regioanl assessment by Keith Hiscock) of fine-scale EUNIS levels (4-6) within broadscale EUNIs levels (1 - 3). The code assigns the all matching fine-scale habitats to polygons tha tare mapped at broad-scale, then obtains their sensitivty scores. Each braodscale polygon will therefore have a number of sensitivty scores associated with it. The code tehn selects the maximum sensitivity wihtin each polygon, and drops the rest. This decision was based on a precautionary principle, given that spatially explicit consevation advice will be based on the outcome.
