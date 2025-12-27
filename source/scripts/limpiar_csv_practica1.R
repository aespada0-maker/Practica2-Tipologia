# cargar csv
df_raw <- read.table(
  "source/dataset/practica1/productos.csv",
  sep = ";",
  header = FALSE,
  fill = TRUE,
  quote = "",
  stringsAsFactors = FALSE
)

# quitar primera fila, la que tiene la cabecera
df_raw <- df_raw[-1, ]

# nombres de columna (en el csv tiene tilde y estan mal)
colnames(df_raw) <- c(
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
df_raw <- df_raw %>%
  mutate(
    precio = str_replace_all(precio, ",", "."),
    precio = str_replace_all(precio, "[^0-9\\.]", ""),
    precio = as.numeric(precio)
  )

# limpiar valoracion media
df_raw <- df_raw %>%
  mutate(
    valoracion_media = str_extract(valoracion_media, "[0-9\\.]+"),
    valoracion_media = as.numeric(valoracion_media)
  )

# mutar a numericos
df_raw <- df_raw %>%
  mutate(
    val_5 = as.numeric(val_5),
    val_4 = as.numeric(val_4),
    val_3 = as.numeric(val_3),
    val_2 = as.numeric(val_2),
    val_1 = as.numeric(val_1)
  )

str(df_raw$precio)

# mirar si hay NAs
print("NAs:")
print(colSums(is.na(df_raw)))
# no tenemos NAs

# guardamos csv
write.csv(
  df_raw,
  "source/dataset_final/practica1/productos.csv",
  row.names = FALSE
)
