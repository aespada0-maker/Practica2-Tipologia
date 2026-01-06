# 1 prediccion: variable objetivo -> precio

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

# revisamos datos
colSums(is.na(dataset_final_raw))
# no usamos valoracion_media, muchos NAsW

# modelo supervisado - regresión lineal
m_supervisado_lm <- lm(
  precio ~ ram_gb + battery_mah + screen_size + num_cores + marca + os + year,
  data = m_supervisado_train
)

# sacamos los datos del modelo
summary(m_supervisado_lm)

# empezamos con la prediccion
m_supervisado_pred <- predict(m_supervisado_lm, newdata = m_supervisado_test)
m_supervisado_rmse <- RMSE(m_supervisado_pred, m_supervisado_test$precio)
m_supervisado_mae <- MAE(m_supervisado_pred, m_supervisado_test$precio)

cat("RMSE:", m_supervisado_rmse, "\nMAE:", m_supervisado_mae, "\n")

# 2. graficos
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

# precio por OS
g <- ggplot(ds_m_supervisado, aes(x = os, y = precio)) +
  geom_boxplot(fill = "blue", outlier.color = "red", alpha = 0.7) +
  labs(
    title = "Precio por sistema operativo",
    x = "Sistema operativo",
    y = "Precio (€)"
  ) +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ".", decimal.mark = ",")
  )

ggsave("source/graficos/supervisado/2-precio_por_os.png", g, width = 7, height = 5)

# relacion entre precio y ram
g <- ggplot(ds_m_supervisado, aes(x = ram_gb, y = precio)) +
  geom_point(alpha = 0.4, color = "blue") +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(
    title = "Relación entre RAM y precio",
    x = "Memoria RAM (GB)",
    y = "Precio (€)"
  ) +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ".", decimal.mark = ",")
  )

ggsave("source/graficos/supervisado/3-rel_precio_Ram.png", g, width = 7, height = 5)

# relacion entre precio real y predicho
df_pred <- data.frame(
  precio_real = m_supervisado_test$precio,
  precio_predicho = m_supervisado_pred
)

g <- ggplot(df_pred, aes(x = precio_real, y = precio_predicho)) +
  geom_point(alpha = 0.5, color = "blue") +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(
    title = "Precio real vs precio predicho",
    x = "Precio real (€)",
    y = "Precio predicho (€)"
  ) +
  scale_x_continuous(
    labels = scales::label_number(big.mark = ".", decimal.mark = ",")
  ) +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ".", decimal.mark = ",")
  ) 

ggsave("source/graficos/supervisado/4-rel_precio_real_predicho.png", g, width = 7, height = 5)

# 3. hipótesis
# quitamos los SO que no sean android o ios

# t-test para comparar los precios de ios y android
m_supervisado_train_h <- m_supervisado_train[m_supervisado_train$os == "android" | m_supervisado_train$os == "ios", ]
m_supervisado_ttest <- t.test(precio ~ os, data = m_supervisado_train_h)
capture.output(m_supervisado_ttest, file = "source/graficos/supervisado/t_test_result.txt")

rm(df_pred)
rm(g)
rm(ds_m_supervisado)
rm(m_supervisado_test)
rm(m_supervisado_train)
rm(m_supervisado_idx)
rm(m_supervisado_lm)
rm(m_supervisado_pred)
rm(m_supervisado_rmse)
rm(m_supervisado_mae)
rm(m_supervisado_ttest)