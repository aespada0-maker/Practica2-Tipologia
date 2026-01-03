# cargar csv
df_raw <- read.csv(
  "source/dataset/otros/Mobiles Dataset (2025).csv",
  stringsAsFactors = FALSE
)
#Primero vamos a limpiar el nombre separando la capacidad de almacenamiento del nombre, creando una nueva columna y eliminando esta del nombre
#También por si acaso vamos a transformar los TB a GB.
df_raw <- df_raw %>%
  mutate(
    # Extraemos la capacidad y la unidad (GB o TB)
    Capacity_num = as.numeric(str_extract(Model.Name, "(?i)\\b(\\d+)\\s*(?=GB|TB)")),
    Capacity_unit = str_extract(Model.Name, "(?i)(GB|TB)"),
    
    # Convertimos todo a GB
    Capacity = case_when(
      Capacity_unit == "TB" ~ Capacity_num * 1024,
      TRUE ~ Capacity_num
    ),
    # Eliminamos la capacidad del nombre
    Model.Name = str_replace(Model.Name, "(?i)\\b\\d+\\s*(GB|TB)\\b", "")
  ) %>%
  select(-Capacity_num, -Capacity_unit)  # eliminamos columnas intermedias


#Limpieza de la columna peso,ram,camaras y tamaño de pantalla
df_raw <- df_raw %>%
  mutate(
    Mobile.Weight = as.numeric(str_extract(Mobile.Weight,"(?i)\\b\\d+(?=G)")),
    RAM = as.numeric(str_extract(RAM,"(?i)\\b\\d+(?=GB)")),
    Front.Camera = as.numeric(str_extract(Front.Camera,"(?i)\\b\\d+(?=MP)")),
    Back.Camera = as.numeric(str_extract(Back.Camera,"(?i)\\b\\d+(?=MP)")),
    Screen.Size = as.numeric(str_extract(Screen.Size, "(?i)\\d+\\.?\\d*(?=\\s*inches)"))
    )
#Limpieza de la capacidad de la bateria
df_raw <- df_raw %>%
  mutate(
    # Limpiar la capacidad de batería
    Battery.Capacity = str_replace_all(Battery.Capacity, "[,\\.]", ""),  # quitar comas y puntos
    Battery.Capacity = str_replace(Battery.Capacity, "(?i)mAh", ""),    # quitar "mAh"
    Battery.Capacity = as.numeric(Battery.Capacity)                     # convertir a número
  )


#limpieza de precios en los diferentes paises
price_cols <- c("Launched.Price..Pakistan.","Launched.Price..India.","Launched.Price..China.","Launched.Price..USA.","Launched.Price..Dubai.")
for(col in price_cols) {
  df_raw[[col]] <- as.numeric(
    # 1. Extraer el número decimal después del código del país
    # 2. Quitar comas de miles
    gsub(",", "", str_extract(df_raw[[col]], "\\d+[\\d,]*\\.?\\d*"))
  )
}

# añadimos en euro el precio. 1 USD = 0.92 EUR
df_raw$Launched.Price..EURO. <- round(df_raw$Launched.Price..USA. * 0.92, 2)
  
# mirar si hay NAs
print("NAs:")
print(colSums(is.na(df_raw)))

# Crear carpeta si no existe
if(!dir.exists("source/dataset_final/productos_externos")){
  dir.create("source/dataset_final/productos_externos")
}

# Guardar CSV
write.csv(df_raw, "source/dataset_final/productos_externos/productos_externos.csv", row.names = FALSE)


rm(col)
rm(price_cols)