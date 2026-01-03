# variable objetivo -> precio

# tenemos muchos os vacios y es una variable categorica
ds_m_supervisado <- dataset_final_raw[dataset_final_raw$os != "" & !is.na(dataset_final_raw$os), ]

# hemos quitado "" y vacía, quitamos los niveles del factor, no son corectos
ds_m_supervisado$os <- droplevels(ds_m_supervisado$os)
ds_m_supervisado$marca <- droplevels(ds_m_supervisado$marca)

# añadimos seed
set.seed(42)

# sacamos los indices y separamos los grupos en 80%-20% para entrenar y supervisar
m_supervisado_idx <- createDataPartition(ds_m_supervisado$precio, p = 0.8, list = FALSE)
m_supervisado_train <- ds_m_supervisado[m_supervisado_idx, ]
m_supervisado_test  <- ds_m_supervisado[-m_supervisado_idx, ]

# Eliminamos marcas poco frecuentes (sino da error si no esta en ambos grupos)
marcas_conservar <- m_supervisado_train %>%
  count(marca) %>%
  filter(n >= 5) %>%
  pull(marca)

m_supervisado_train <- m_supervisado_train %>%
  filter(marca %in% marcas_conservar)

m_supervisado_test <- m_supervisado_test %>%
  filter(marca %in% marcas_conservar)

rm(marcas_conservar)

# Eliminamos niveles sobrantes
m_supervisado_train$marca <- droplevels(m_supervisado_train$marca)
m_supervisado_test$marca  <- droplevels(m_supervisado_test$marca)

# alineamos niveles de los factor categoricos
m_supervisado_test$os <- factor(
  m_supervisado_test$os,
  levels = levels(m_supervisado_train$os)
)
m_supervisado_test$marca <- factor(
  m_supervisado_test$marca,
  levels = levels(m_supervisado_train$marca)
)

# modelo supervisado - regresión lineal
m_supervisado_lm <- lm(
  precio ~ ram_gb + battery_mah + screen_size + num_cores + valoracion_media + marca + os + year,
  data = m_supervisado_train
)

# sacamos los datos del modelo
summary(m_supervisado_lm)

# empezamos con la prediccion
m_supervisado_pred <- predict(m_supervisado_lm, newdata = m_supervisado_test)
RMSE(m_supervisado_pred, m_supervisado_test$precio)
MAE(m_supervisado_pred, m_supervisado_test$precio)



# sacamos la distribución del precio
g <- ggplot(ds_m_supervisado, aes(x = precio)) +
  geom_histogram(bins = 30, fill="blue", color="white") +
  scale_x_log10() +
  labs(
    title = "Distribución por precio",
    x = "Precio (€)",
    y = "Cantidad de dispositivos"
  ) +
  scale_x_continuous(
    labels = label_number(big.mark = ".", decimal.mark = ",")
  )

ggsave("source/graficos/supervisado/1-dist_precio.png", g, width = 7, height = 5)
