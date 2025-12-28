df_oppendatabay <- read.csv(
  "source/dataset/productos2/productos2.csv",
  stringsAsFactors = FALSE)

write.csv(
  df_oppendatabay,
  "source/dataset_final/productos2/productos2.csv",
  row.names = FALSE
)
