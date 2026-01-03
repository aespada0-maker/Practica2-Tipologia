output_dir <- "source/graficos/no_supervisado"

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}
set.seed(42)

#1. vamos a hacer una segunda limpieza de los datos así como quitar la variable modelo que no aporta nada al clustering que vamos a realziar

dataset_sel <- dataset_final_raw %>%
  select(
    marca,
    os,
    precio,
    valoracion_media,
    ram_gb,
    battery_mah,
    screen_size,
    num_cores,
    year
  )
#Realizaremos una imputación por medianas
num_vars <- c(
  "precio", "valoracion_media", "ram_gb",
  "battery_mah", "screen_size", "num_cores", "year"
)

dataset_sel[num_vars] <- dataset_sel[num_vars] %>%
  map(~ ifelse(is.na(.), median(., na.rm = TRUE), .))

#Cambiaremos los NA de las variables categóricas por Unknown

dataset_sel <- dataset_sel %>%
  mutate(
    marca = as.character(marca),
    os = as.character(os)
  ) %>%
  mutate(
    marca = replace_na(marca, "unknown"),
    os = replace_na(os, "unknown")
  )


#Para realizar K-Means vamos a codificar las variables categóricas
dataset_dummies <- dataset_sel %>%
  mutate(
    marca = as.factor(marca),
    os = as.factor(os)
  ) %>%
  model.matrix(~ . - 1, data = .) %>%
  as.data.frame()

dataset_scaled <- scale(dataset_dummies)


#2. Para ver cuantos clusters serían optimos realizaremos el método del codo y Silhouette score


wss <- sapply(2:10, function(k) {
  kmeans(dataset_scaled, centers = k, nstart = 25)$tot.withinss
})

png(
  filename = file.path(output_dir, "metodo_codo.png"),
  width = 800,
  height = 600
)

plot(
  2:10, wss,
  type = "b",
  xlab = "Número de clusters (k)",
  ylab = "Within-cluster sum of squares",
  main = "Método del codo"
)
dev.off()


sil <- sapply(2:10, function(k) {
  km <- kmeans(dataset_scaled, centers = k, nstart = 25)
  mean(silhouette(km$cluster, dist(dataset_scaled))[, 3])
})

png(
  filename = file.path(output_dir, "silhouette_score.png"),
  width = 800,
  height = 600
)

plot(
  2:10, sil,
  type = "b",
  xlab = "Número de clusters (k)",
  ylab = "Silhouette Score",
  main = "Evaluación mediante Silhouette"
)


dev.off()


#3. Mejor resultado de silhouette es para k = 8
k = 8 
  
kmeans_final <- kmeans(
  dataset_scaled,
  centers = k,
  nstart = 50
)

dataset_sel$cluster <- factor(kmeans_final$cluster)

#Vamos a realizar unos cálculos por clusters para su posterior representación
dataset_sel %>%
  group_by(cluster) %>%
  summarise(
    precio_med = mean(precio),
    ram_med = mean(ram_gb),
    bateria_med = mean(battery_mah),
    pantalla_med = mean(screen_size),
    nucleos_med = mean(num_cores),
    year_med = mean(year),
    valoracion_med = mean(valoracion_media),
    n = n()
  )
#Gráfico de distribución de marcas por cluster
marca_heatmap_df <- dataset_sel %>%
  count(cluster, marca) %>%
  group_by(cluster) %>%
  mutate(prop = n / sum(n))



marca_heatmap_plot <- ggplot(
  marca_heatmap_df,
  aes(x = cluster, y = marca, fill = prop)
) +
  geom_tile(color = "white") +
  scale_fill_gradient(
    low = "#f7fbff",
    high = "#08306b",
    labels = scales::percent_format()
  ) +
  labs(
    title = "Distribución de marcas por cluster",
    x = "Cluster",
    y = "Marca",
    fill = "Proporción"
  ) +
  theme_minimal()
ggsave(
  filename = file.path(output_dir, "heatmap_marcas_por_cluster.png"),
  plot = marca_heatmap_plot,
  width = 9,
  height = 6,
  dpi = 300
)



#Distribución de sistema operativos por clusters
os_cluster_df <- dataset_sel %>%
  filter(os != "unknown" & os != "") %>%
  count(cluster, os) %>%
  group_by(cluster) %>%
  mutate(prop = n / sum(n))


os_cluster_plot <- ggplot(os_cluster_df,
                          aes(x = cluster, y = prop, fill = os)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Distribución de sistemas operativos por cluster",
    x = "Cluster",
    y = "Proporción",
    fill = "Sistema operativo"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(output_dir, "distribucion_os_por_cluster.png"),
  plot = os_cluster_plot,
  width = 9,
  height = 6,
  dpi = 300
)

#4. Vamos a realizar PCA para una mejor exploración/visualización

pca <- prcomp(dataset_scaled)

pca_df <- data.frame(
  PC1 = pca$x[,1],
  PC2 = pca$x[,2],
  cluster = dataset_sel$cluster
)

pca_plot<- ggplot(pca_df, aes(PC1, PC2, color = cluster)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Clusters de smartphones (PCA)",
    x = "Componente principal 1",
    y = "Componente principal 2"
  )
ggsave(
  filename = file.path(output_dir, "clusters_pca.png"),
  plot = pca_plot,
  width = 8,
  height = 6,
  dpi = 300
)

#Gráficas finales para conclusión

# Rango de precios entre 1er y 99º percentil ya que algunos datos de precios estropean estas gráficas
price_lower <- quantile(dataset_sel$precio, 0.01, na.rm = TRUE)
price_upper <- quantile(dataset_sel$precio, 0.99, na.rm = TRUE)

# Filtrar dataset para graficar
dataset_plot <- dataset_sel %>%
  filter(precio >= price_lower & precio <= price_upper)


ram_cluster_plot <- ggplot(dataset_plot, aes(x = cluster, y = ram_gb, color = marca)) +
  geom_jitter(width = 0.2, alpha = 0.7, size = 2) +
  labs(
    title = "Distribución de RAM por marca y cluster (outliers filtrados)",
    x = "Cluster",
    y = "RAM (GB)",
    color = "Marca"
  ) +
  theme_minimal()

# Guardar la figura
ggsave(
  filename = file.path(output_dir, "ram_por_marca_y_cluster_filtrado.png"),
  plot = ram_cluster_plot,
  width = 9,
  height = 6,
  dpi = 300
)

bateria_cluster_plot <- ggplot(dataset_plot, aes(x = cluster, y = battery_mah, color = marca)) +
  geom_jitter(width = 0.2, alpha = 0.7, size = 2) +
  labs(
    title = "Distribución de batería por marca y cluster (outliers filtrados)",
    x = "Cluster",
    y = "Batería (mAh)",
    color = "Marca"
  ) +
  theme_minimal()

# Guardar la figura
ggsave(
  filename = file.path(output_dir, "bateria_por_marca_y_cluster_filtrado.png"),
  plot = bateria_cluster_plot,
  width = 9,
  height = 6,
  dpi = 300
)


os_precio_plot <- dataset_plot %>%
  filter(os != "" & os != "unknown") %>%
  ggplot(aes(x = cluster, y = precio, color = os)) +
  geom_jitter(width = 0.2, alpha = 0.6) +
  labs(
    title = "Distribución de precio por sistema operativo y cluster (outliers filtrados)",
    x = "Cluster",
    y = "Precio (€)",
    color = "Sistema operativo"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(output_dir, "precio_por_os_y_cluster_filtrado.png"),
  plot = os_precio_plot,
  width = 9,
  height = 6,
  dpi = 300
)

boxplot_precio <- ggplot(dataset_plot, aes(x = cluster, y = precio, fill = cluster)) +
  geom_boxplot(alpha = 0.7) +
  labs(
    title = "Distribución de precios por cluster (outliers filtrados)",
    x = "Cluster",
    y = "Precio (€)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(
  filename = file.path(output_dir, "boxplot_precio_por_cluster_filtrado.png"),
  plot = boxplot_precio,
  width = 9,
  height = 6,
  dpi = 300
)

