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
  "Launched.Price..EURO." = "precio"
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

# limpiar dataset final
# demasiados valores vacios en val_1-val_5 -> el 96% los borramos, mantenemos solo la valoración media
dataset_final_raw <- dataset_final_raw %>%
  dplyr::select(-val_1, -val_2, -val_3, -val_4, -val_5)

# variables técnicas. No eliminamos filas, hacemos una imputación simple con la mediana por ser variables numéricas con posibles asimetrias
# xiaomi != apple, tendría sentido una imputación por marca, pero sin datos suficientes podríamos crear una dependencia de las variables. HAcemos una global.
dataset_final_raw$ram_gb[is.na(dataset_final_raw$ram_gb)] <- median(dataset_final_raw$ram_gb, na.rm = TRUE)
dataset_final_raw$battery_mah[is.na(dataset_final_raw$battery_mah)] <- median(dataset_final_raw$battery_mah, na.rm = TRUE)
dataset_final_raw$screen_size[is.na(dataset_final_raw$screen_size)] <- median(dataset_final_raw$screen_size, na.rm = TRUE)
dataset_final_raw$num_cores[is.na(dataset_final_raw$num_cores)] <- median(dataset_final_raw$num_cores, na.rm = TRUE)
dataset_final_raw$year[is.na(dataset_final_raw$year)] <- median(dataset_final_raw$year, na.rm = TRUE)

# hacemos una imputación de el OS por marca
dataset_final_raw <- dataset_final_raw %>%
  mutate(os = ifelse(os == "" | is.na(os), NA, os))
# calculamos el OS más frecuente por marca
os_por_marca <- dataset_final_raw %>%
  filter(!is.na(os)) %>%
  count(marca, os) %>%
  group_by(marca) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(marca, os_moda = os)
# hacemos la imputación
dataset_final_raw <- dataset_final_raw %>%
  left_join(os_por_marca, by = "marca") %>%
  mutate(os = ifelse(is.na(os), os_moda, os)) %>%
  mutate(os = ifelse(is.na(os), "other", os)) %>%
  select(-os_moda)

# variables categoricas, podemos normalizar el texto
# ya está en minúscula, pero algunos los tenémos entre ""
dataset_final_raw$modelo <- gsub('^"|"$', '', dataset_final_raw$modelo)
dataset_final_raw$marca <- as.factor(dataset_final_raw$marca)
dataset_final_raw$os <- as.factor(dataset_final_raw$os)

# escribimos el CSV
write.csv(dataset_final_raw, "source/dataset_final/dataset_completo.csv", row.names = FALSE)

# eliminamos variables de memoria
rm(os_por_marca)
rm(columnas_finales)
rm(mapeo_pract1)
rm(mapeo_oppendatabay)
rm(mapeo_raw)
rm(df_oppendatabay)
rm(df_pract1)
rm(df_raw)
rm(oppendatabay_h)
rm(prac1_h)
rm(raw_h)