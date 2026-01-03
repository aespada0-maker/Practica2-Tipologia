library(tidyverse)
library(dplyr)
library(caret)
library(ggplot2)
library(scales)
library(cluster)
# 1. Ejercutar limpieza del script original 
source("source/scripts/limpiar_csv_practica1.R")

# 2. Ejecutar lipieza del script de www.opendatabay.com
# https://www.opendatabay.com/data/consumer/a16cb863-a839-4245-800f-37ef284b2883
source("source/scripts/limpiar_csv_productos2.R")

# 3. Ejecutar limpieza del script externo
source("source/scripts/limpiar_csv_externo.R")

lapply(
  list(
    df_oppendatabay,
    df_pract1,
    df_raw
  ),
  names
)

source("source/scripts/crear_csv_final.R")

# 4. modelo supervisado
source("source/scripts/modelo_supervisado.R")

# 5. modelo no supervisado
source("source/scripts/modelo_no_supervisado.R")