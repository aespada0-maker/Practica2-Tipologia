df_oppendatabay <- read.table(
  "source/dataset/productos2/productos2.csv",
  sep = ",")

write.csv(
  df_oppendatabay,
  "source/dataset_final/productos2/productos2.csv",
  row.names = FALSE
)
