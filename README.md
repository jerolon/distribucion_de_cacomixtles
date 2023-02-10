# distribucion_de_cacomixtles
An example of mining, cleaning and visualization of species distribution data

- Used the library [rgbif](https://github.com/ropensci/rgbif) for getting GBIF data into R. I downloaded the distribution data of *Bassariscus astutus*, a cute nocturnal mammal common throughout Central Mexico, the Californias and the US southwest. In Mexico it is known as Cacomixtle and has recently started being spotted more often in urban areas for unknown (to me) reasons.

- Data cleaning courtesy of dplyr and [Coordinate cleaner](https://github.com/ropensci/CoordinateCleaner)

- I got the Shapefiles for Mexico City Geographical Data from [INEGI](https://www.inegi.org.mx/temas/mg/#Descargas), the mexican Institute for Statistics and Geography

![Filtered Bassariscus astutus distribution in North America](./im/filtered.png)

To do:
With more time and a good GPU it would be fun to do this maps in 3D using ray shader to visualize oroggraphy and/or population density ![3D Population density of Mexico ](https://www.google.com/url?sa=i&url=https%3A%2F%2Ftwitter.com%2Fresearchremora%2Fstatus%2F1611563743862837248&psig=AOvVaw1e-dr-lNT97Ncc64n9kP6s&ust=1676152001511000&source=images&cd=vfe&ved=0CBEQjhxqFwoTCJCX7_b2i_0CFQAAAAAdAAAAABAE)
