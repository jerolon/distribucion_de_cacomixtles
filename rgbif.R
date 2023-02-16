library(rgbif)
library(dplyr)
library(CoordinateCleaner)
library(sf)
library(spData)
library(ggpointdensity)
library(ggplot2)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

##Marco Geoestadistico del INEGI (3.14 GB)
#Solo hace falta la carpeta 09_ciudaddemexico
#https://www.inegi.org.mx/contenidos/productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marcogeo/889463770541_s.zip

cacomixtle_ocurrencia <- occ_search(scientificName = "Bassariscus astutus", limit = 6000)
cacomixtle_df <- cacomixtle_ocurrencia$data
names(cacomixtle_df) %>% sort()


##Distribucion del cacomixtle en America
world_tbl = read_sf(system.file("shapes/world.shp", package = "spData"))
ggplot(cacomixtle_df) +  
  geom_sf(data = filter(world_tbl, region_un == "Americas"), color = "grey70") + 
  geom_point(aes(decimalLongitude, decimalLatitude)) + 
  ggpointdensity::geom_pointdensity(aes(decimalLongitude, decimalLatitude),
                                    size = 0.2)

#filtros con dplyr
cacomixtle_df <- cacomixtle_df %>% filter(occurrenceStatus  == "PRESENT") %>%
  filter(basisOfRecord != "PRESERVED_SPECIMEN") %>% 
  filter(!is.na(decimalLongitude) | !is.na(decimalLatitude)) %>% 
  filter(year >= 1900) %>% 
  filter(coordinateUncertaintyInMeters < 10000 | is.na(coordinateUncertaintyInMeters)) %>%
  filter(coordinatePrecision < 0.01 | is.na(coordinatePrecision))

 
#filtros con la funcion clean_coordinates
cacomixtle_df <- clean_coordinates(cacomixtle_df, species = "species", lon = "decimalLongitude", lat = "decimalLatitude", countries = "countryCode",
                                    tests = c("centroids", "institutions", "zeros", "equal"), value = "clean")

##Distribucion del cacomixtle en Norteamerica
ggplot(cacomixtle_df) +  
  geom_sf(data = filter(world_tbl, continent == "North America"), color = "grey70") + 
  geom_point(aes(decimalLongitude, decimalLatitude)) + 
  ggpointdensity::geom_pointdensity(aes(decimalLongitude, decimalLatitude),
                                    size = 0.2) + theme_bw()

##Mapa de las colonias de la ciudad de Mexico
#Por AGEB
cdmx_ageb <- read_sf("./09_ciudaddemexico/conjunto_de_datos/09a.shp")
##Darle el codigo EPSG de Mexico ITRF2008
st_crs(cdmx_ageb) <- "EPSG:6372"

cdmx <- read_sf("./09_ciudaddemexico/conjunto_de_datos/09mun.shp")

##filtrar los cacomixtles en las coordenadas de la ciudad de Mexico
filter(cacomixtle_df, between(decimalLatitude, 19,19.6) & between(decimalLongitude, -99.4, -98.8)) %>% 
  ggplot() + geom_sf(data = st_transform(cdmx, 4326)) +
  geom_point(aes(decimalLongitude, decimalLatitude)) + ggpointdensity::geom_pointdensity(aes(decimalLongitude, decimalLatitude)) + theme_bw()


##Encontrar una ageb por distancia minima a un punto
ageb_cercano <- function(lati, longi){
  punto <- st_as_sf(data.frame(lat = lati, long = longi), coords = c("long","lat"), crs = "4326")
  #saca los centroides de todas las agebs urbanas del df
  agebs_centroids <- mutate(st_transform(cdmx_ageb,4326), centr = st_centroid(geometry))
  st_crs(agebs_centroids) = "4326"
  #saca la distancia de todos los centroides a las coordenadas de CU definidas arriba y filtra el minimo
  agebs_centroids <- mutate(agebs_centroids, distancia = as.vector(st_distance(agebs_centroids, punto)))
  filter(agebs_centroids, distancia == min(distancia))
  
}
##Las coordenadas de ciudad_universitaria en google maps
ageb_cercano(19.321095, -99.183855)
##La AGEB correspondiente a CU es la 0770
ageb_cu <- "0770"

###Con CU
filter(cacomixtle_df, between(decimalLatitude, 19,19.6) & between(decimalLongitude, -99.4, -98.8)) %>% 
  ggplot() + geom_sf(data = st_transform(cdmx, 4326), fill = NA) + 
  geom_sf(data = st_transform(filter(cdmx_ageb, CVE_AGEB == ageb_cu), 4326), fill = "blue") + 
  ggpointdensity::geom_pointdensity(aes(decimalLongitude, decimalLatitude), size =1) +
  scale_color_gradient(low = "black", high = "red")+ theme_bw()

##Rios y canales
cdmx_serviciosl <- read_sf("./09_ciudaddemexico/conjunto_de_datos/09sil.shp")
st_crs(cdmx_serviciosl)  <- "EPSG:6372"

filter(cacomixtle_df, between(decimalLatitude, 19,19.6) & between(decimalLongitude, -99.4, -98.8)) %>% 
  ggplot() + geom_sf(data = st_transform(cdmx, 4326), color = "gray", linetype = 2, fill = NA) + 
  geom_sf(data = st_transform(filter(cdmx_serviciosl, GEOGRAFICO %in% c("Corriente de Agua", "Canal")), 4326), col = "blue") + 
  geom_point(aes(decimalLongitude, decimalLatitude)) + 
  ggpointdensity::geom_pointdensity(aes(decimalLongitude, decimalLatitude)) + scale_color_gradient(low = "black", high = "red")+ theme_bw()

##Servicios de Area
cdmx_serviciosA <- read_sf("./09_ciudaddemexico/conjunto_de_datos/09sia.shp")
st_crs(cdmx_serviciosA)  <- "EPSG:6372"

##Ejemplo: Con metrobus
filter(cacomixtle_df, between(decimalLatitude, 19,19.6) & between(decimalLongitude, -99.4, -98.8)) %>% 
  ggplot() + geom_sf(data = st_transform(cdmx, 4326), color = "gray", linetype = 2, fill = NA) + geom_sf(data = st_transform(filter(cdmx_serviciosA, GEOGRAFICO %in% c("Estación de Transporte Terrestre")), 4326), col = "blue", size = 2) + geom_point(aes(decimalLongitude, decimalLatitude)) + ggpointdensity::geom_pointdensity(aes(decimalLongitude, decimalLatitude)) + scale_color_gradient(low = "black", high = "red")+ theme_bw()


##Servicios Puntuales
cdmx_serviciosP <- read_sf("./09_ciudaddemexico/conjunto_de_datos/09sip.shp")
st_crs(cdmx_serviciosP)  <- "EPSG:6372"
###Ejemplo: Estaciones de metro
filter(cacomixtle_df, between(decimalLatitude, 19,19.6) & between(decimalLongitude, -99.4, -98.8)) %>% 
  ggplot() + geom_sf(data = st_transform(cdmx, 4326), color = "gray", linetype = 2, fill = NA) + 
  geom_sf(data = st_transform(filter(cdmx_serviciosP, TIPO %in% c("Estación de Tren Metropolitano (Metro)")), 4326), col = "blue") + 
  geom_point(aes(decimalLongitude, decimalLatitude)) + ggpointdensity::geom_pointdensity(aes(decimalLongitude, decimalLatitude)) + 
  scale_color_gradient(low = "black", high = "red")+ theme_bw()

### Ejes Viales
cdmx_ev <- read_sf("./09_ciudaddemexico/conjunto_de_datos/09e.shp")
st_crs(cdmx_ev)  <- "EPSG:6372"

###Ejemplo: Avenidas
filter(cacomixtle_df, between(decimalLatitude, 19,19.6) & between(decimalLongitude, -99.4, -98.8)) %>% 
  ggplot() + geom_sf(data = st_transform(cdmx, 4326), color = "gray", linetype = 2, fill = NA) + 
  geom_sf(data = st_transform(filter(cdmx_ev, TIPOVIAL %in% c("Avenida")), 4326), col = "blue") + geom_point(aes(decimalLongitude, decimalLatitude)) + ggpointdensity::geom_pointdensity(aes(decimalLongitude, decimalLatitude)) + scale_color_gradient(low = "black", high = "red")+ theme_bw()


####Encuentra los cacomixtles que tienen secuencias de DNA asociadas
cacomixtles_con_DNA <- filter(cacomixtle_df, !is.na(associatedSequences))

#Locaclizacion de los cacomixtles con DNA
ggplot(cacomixtles_con_DNA) +  
  geom_sf(data = filter(world_tbl, name_long == "Mexico"), color = "grey70") + 
  geom_point(aes(decimalLongitude, decimalLatitude)) + geom_text(hjust = 0, vjust =0, aes( y = decimalLatitude, x = decimalLongitude, label = stringr::str_remove(associatedSequences, "-SUPPRESSED"))) +
  theme_bw()

