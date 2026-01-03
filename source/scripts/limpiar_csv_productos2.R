df_oppendatabay <- read.csv(
  "source/dataset/productos2/productos2.csv",
  stringsAsFactors = FALSE)

# el precio parece estar en INR, lo transformamos. 1 EUR ≈ 90 INR-
df_oppendatabay$price <- round(df_oppendatabay$price / 90, 2)

write.csv(
  df_oppendatabay,
  "source/dataset_final/productos2/productos2.csv",
  row.names = FALSE
)
