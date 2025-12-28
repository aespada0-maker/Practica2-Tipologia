# cargar csv
df_raw_ext <- read.table(
  "source/dataset/practica1/productos.csv",
  sep = ";",
  header = FALSE,
  fill = TRUE,
  quote = "",
  stringsAsFactors = FALSE
)

# quitar primera fila, la que tiene la cabecera
df_raw_ext <- df_raw_ext[-1, ]

# nombres de columna (en el csv tiene tilde y estan mal)
colnames(df_raw_ext) <- c(
  "marca",
  "modelo",
  "precio",
  "pn",
  "valoracion_media",
  "val_5",
  "val_4",
  "val_3",
  "val_2",
  "val_1"
)

# limpiar precio
df_raw_ext <- df_raw_ext %>%
  mutate(
    precio = str_replace_all(precio, ",", "."),
    precio = str_replace_all(precio, "[^0-9\\.]", ""),
    precio = as.numeric(precio)
  )

# limpiar valoracion media
df_raw_ext <- df_raw_ext %>%
  mutate(
    valoracion_media = str_extract(valoracion_media, "[0-9\\.]+"),
    valoracion_media = as.numeric(valoracion_media)
  )

# mutar a numericos
df_raw_ext <- df_raw_ext %>%
  mutate(
    val_5 = as.numeric(val_5),
    val_4 = as.numeric(val_4),
    val_3 = as.numeric(val_3),
    val_2 = as.numeric(val_2),
    val_1 = as.numeric(val_1)
  )

str(df_raw_ext$precio)

# mirar si hay NAs
print("NAs:")
print(colSums(is.na(df_raw_ext)))
# no tenemos NAs

# guardamos csv
write.csv(
  df_raw_ext,
  "source/dataset_final/practica1/productos.csv",
  row.names = FALSE
)
