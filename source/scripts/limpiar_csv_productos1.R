df_kaggle_train <- read.csv("source/dataset/productos1/train.csv")
df_kaggle_test <- read.csv("source/dataset/productos1/test.csv")

# para juntar los 2 datasets, tenemos que tener en cuenta que test no tiene price_range
df_kaggle_test$price_range <- NA

# juntamos los 2 datasets
df_kaggle <- bind_rows(df_kaggle_train, df_kaggle_test)

# miramos estructura
print(str(df_kaggle))
print(summary(df_kaggle))
print(colSums(is.na(df_kaggle)))

# variable categorica
df_kaggle$price_range <- as.factor(df_kaggle$price_range)

# ponemos como numeric lo que no sea numeric
df_kaggle <- df_kaggle %>%
  mutate(across(-price_range, as.numeric))

# imputacion
df_kaggle <- df_kaggle %>%
  mutate(
    across(
      where(is.numeric),
      ~ ifelse(is.na(.), median(., na.rm = TRUE), .)
    )
  )

# guardamos el dataset limpio
write.csv(
  df_kaggle,
  "source/dataset_final/productos1/productos1.csv",
  row.names = FALSE
)

rm(df_kaggle_train)
rm(df_kaggle_test)
