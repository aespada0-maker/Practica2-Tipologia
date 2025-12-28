library(tidyverse)

# 1. Ejercutar limpieza del script original 
source("source/scripts/limpiar_csv_practica1.R")

# 2. Ejecutar lipieza del script de kaggle
# https://www.kaggle.com/datasets/iabhishekofficial/mobile-price-classification?resource=download
source("source/scripts/limpiar_csv_productos1.R")

# 3. Ejecutar lipieza del script de www.opendatabay.com
# https://www.opendatabay.com/data/consumer/a16cb863-a839-4245-800f-37ef284b2883?utm_source=chatgpt.com
source("source/scripts/limpiar_csv_productos2.R")

# 4. Ejecutar limpieza del script externo
source("source/scripts/limpiar_csv_externo.R")