# UNIVARIADO
# marcas
g <- ggplot(dataset_final_raw, aes(x = fct_infreq(marca))) +
  geom_bar(fill = "blue") +
  coord_flip() +
  labs(title = "Distribución de marcas", x = "Marca", y = "Cantidad de dispositivos")
ggsave("source/graficos/EDA/1-marca.png", g, width = 7, height = 5)

# precio
g <- ggplot(dataset_final_raw, aes(x = precio)) +
  geom_histogram(bins = 30, fill = "blue", color = "black") +
  scale_x_continuous(labels = dollar_format(prefix = "€")) +
  labs(title = "Distribución de precios", x = "Precio (€)", y = "Cantidad")
ggsave("source/graficos/EDA/2-precio.png", g, width = 7, height = 5)


# boxplot de precios (para detectar outliers)
g <- ggplot(dataset_final_raw, aes(y = precio, x = "")) +
  geom_boxplot(fill = "red") +
  scale_y_continuous(labels = dollar_format(prefix = "€")) +
  labs(title = "Boxplot de precios")
ggsave("source/graficos/EDA/3-precio-outliers.png", g, width = 7, height = 5)

# boxplot de precios (para detectar outliers)
g <- ggplot(dataset_final_raw, aes(y = precio, x = "")) +
  geom_boxplot(fill = "red") +
  scale_y_continuous(labels = dollar_format(prefix = "€")) +
  labs(title = "Boxplot de precios (log10)") +
  scale_y_log10()
ggsave("source/graficos/EDA/3-precio-outliers-log10.png", g, width = 7, height = 5)


# otras variables numéricas
sink("source/graficos/EDA/summary_numericas.txt")
dataset_final_raw %>%
  select(all_of(c("ram_gb", "battery_mah", "screen_size", "num_cores"))) %>%
  summary()
sink()

# BIVARIADO
# Precio por marca
g <- ggplot(dataset_final_raw, aes(x = marca, y = precio)) +
  geom_boxplot(fill = "blue") +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ".", decimal.mark = ",")
  ) +
  coord_flip() +
  labs(title = "Precio por marca", x = "Marca", y = "Precio (€)")
ggsave("source/graficos/EDA/4-precio-marca.png", g, width = 7, height = 5)

# Precio vs Batería
g <- ggplot(dataset_final_raw, aes(x = battery_mah, y = precio, color = marca)) +
  geom_point(alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ".", decimal.mark = ",")
  ) +
  labs(title = "Relación Precio vs Batería", x = "Batería (mAh)", y = "Precio (€)")
ggsave("source/graficos/EDA/5-precio-bateria.png", g, width = 7, height = 5)


# Precio vs Tamaño de pantalla
g <- ggplot(dataset_final_raw, aes(x = screen_size, y = precio, color = marca)) +
  geom_point(alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ".", decimal.mark = ",")
  ) +
  labs(title = "Relación Precio vs Tamaño de Pantalla", x = "Pantalla (pulgadas)", y = "Precio (€)")
ggsave("source/graficos/EDA/6-precio-pantalla.png", g, width = 7, height = 5)

# ==========================
# 5️⃣ Variables categóricas adicionales
# ==========================

# Sistema operativo
g <- ggplot(dataset_final_raw, aes(x = os)) +
  geom_bar(fill = "blue") +
  labs(title = "Distribución de Sistema Operativo", x = "OS", y = "Cantidad de dispositivos")
ggsave("source/graficos/EDA/7-OS.png", g, width = 7, height = 5)

# Año de lanzamiento
g <- ggplot(dataset_final_raw, aes(x = factor(year))) +
  geom_bar(fill = "blue") +
  labs(title = "Cantidad de dispositivos por año", x = "Año", y = "Cantidad")
ggsave("source/graficos/EDA/8-ANIO.png", g, width = 7, height = 5)

# ==========================
# 6️⃣ Resumen automático (opcional)
# ==========================

create_report(dataset_final_raw, 
              output_dir = "source/graficos/EDA", 
              output_file = "EDA.html")

rm(g)