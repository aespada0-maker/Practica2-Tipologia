#Función base para homogeneizar todos los DF

homogeneizar <- function(df,mapeo,columnas_finales){
  
  for (i in seq_along(mapeo)){
    if(names(mapeo)[i] %in% names(df)){
      names(df)[names(df) == names(mapeo)[i]] <- mapeo[i]
    }
  }
  #Creamos columnas faltantes
  faltantes <- setdiff(columnas_finales,names(df))
  for (col in faltantes) {
    df[[col]] <- NA
  }
  
  #Nos quedamos con el esquema final
  df <- df[,columnas_finales]
  return(df)
}

columnas_finales <- c(
  "marca", "modelo", "precio",
  "valoracion_media",
  "val_1", "val_2", "val_3", "val_4", "val_5",
  "ram_gb", "battery_mah", "screen_size",
  "num_cores", "os", "year"
)

mapeo_pract1 <- c(
  "marca" = "marca",
  "modelo" = "modelo",
  "precio" = "precio",
  "valoracion_media" = "valoracion_media",
  "val_1" = "val_1",
  "val_2" = "val_2",
  "val_3" = "val_3",
  "val_4" = "val_4",
  "val_5" = "val_5"
)

mapeo_oppendatabay <- c(
    "brand_name" = "marca",
    "model" = "modelo",
    "price" = "precio",
    "avg_rating" = "valoracion_media",
    "ram_capacity" = "ram_gb",
    "battery_capacity" = "battery_mah",
    "screen_size" = "screen_size",
    "num_cores" = "num_cores",
    "os" = "os"
  )

mapeo_raw <- c(
  "Company.Name" = "marca",
  "Model.Name" = "modelo",
  "RAM" = "ram_gb",
  "Battery.Capacity" = "battery_mah",
  "Screen.Size" = "screen_size",
  "Launched.Year" = "year",
  "Launched.Price..USA." = "precio"
)

normalizar_texto <- function(x){
  tolower(trimws(x))
}
#Homogeneizamos los dataFrames
prac1_h <- homogeneizar(df_pract1,mapeo_pract1,columnas_finales)
oppendatabay_h <- homogeneizar(df_oppendatabay,mapeo_oppendatabay,columnas_finales)
raw_h <- homogeneizar(df_raw,mapeo_raw,columnas_finales)

#Aplicamos normalización del texto
prac1_h$marca <- normalizar_texto(prac1_h$marca)
prac1_h$modelo <- normalizar_texto(prac1_h$modelo)

oppendatabay_h$marca <- normalizar_texto(oppendatabay_h$marca)
oppendatabay_h$modelo <- normalizar_texto(oppendatabay_h$modelo)

raw_h$marca <- normalizar_texto(raw_h$marca)
raw_h$modelo <- normalizar_texto(raw_h$modelo)

dataset_final_raw <- rbind(
  prac1_h,
  oppendatabay_h,
  raw_h
)

write.csv(dataset_final_raw, "source/dataset_final/dataset_completo.csv", row.names = FALSE)
