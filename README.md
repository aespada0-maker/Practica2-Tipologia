# Practica2-Tipologia: análisis del mercado de teléfonos móviles

## Descripción del Proyecto

Este proyecto tiene como objetivo analizar un dataset que contiene información sobre teléfonos móviles comerciales, integrando datos de diversas fuentes con el fin de proporcionar una visión global del mercado de smartphones. El dataset combina características técnicas, económicas y temporales de los dispositivos, permitiendo identificar patrones y segmentos naturales dentro del mercado.

El principal objetivo del análisis es **identificar grupos de dispositivos con características similares**, basándose en variables como el precio, la memoria, la batería, el sistema operativo, y la marca. Este tipo de análisis no requiere etiquetas previas y busca explorar cómo se agrupan los smartphones según sus características técnicas y económicas.

**Pregunta principal del análisis:**
- ¿Existen patrones o segmentos naturales en el mercado de smartphones basados en sus características técnicas y económicas, y cómo pueden caracterizarse dichos segmentos?

## Dataset

El dataset utilizado en este proyecto fue creado mediante la integración de varias fuentes de datos. A continuación, se describen las principales columnas del dataset final:

- `marca` (str): Marca del fabricante del teléfono móvil.
- `modelo` (str): Modelo específico del dispositivo.
- `precio` (float): Precio de salida del teléfono móvil.
- `valoracion_media` (float): Valoración media extraída de PcComponentes.
- `ram_gb` (int): Capacidad total de memoria RAM del dispositivo en GB.
- `battery_mah` (int): Capacidad total de la batería en miliamperios (mAh).
- `screen_size` (float): Tamaño de la pantalla en pulgadas.
- `num_cores` (int): Número de núcleos del procesador del dispositivo.
- `os` (str): Sistema operativo con el que cuenta el teléfono.
- `year` (int): Año de salida del teléfono móvil.

**Ejemplo de los primeros registros:**

| marca  | modelo                         | precio  | valoracion_media | ram_gb | battery_mah | screen_size | num_cores | os      | year |
|--------|--------------------------------|---------|------------------|--------|-------------|-------------|-----------|---------|------|
| apple  | apple iphone xr2               | 799.99  | 6                | 4      | 3060        | 6.1         | 8         | ios     | 2023 |
| asus   | asus rog phone 5s 5g           | 444.43  | 8.7              | 8      | 6000        | 6.78        | 8         | android | 2023 |
| asus   | asus rog phone 6 batman edition| 811.1   | 8.8              | 16     | 6000        | 6.78        | 8         | android | 2023 |
| blu    | blu f91 5g                     | 166.56  | 8.5              | 8      | 5000        | 6.8         | 8         | android | 2023 |
| doogee | doogee s99                     | 166.66  | 8.4              | 8      | 6000        | 6.3         | 8         | android | 2023 |

## Integración y Selección de Datos

Para este análisis, hemos utilizado tres fuentes de datos:

1. **CSV de la primera práctica**: Se realizó una limpieza y transformación básica de los datos, como la conversión de caracteres numéricos y la normalización de las valoraciones.
2. **CSV de OpenDataBay**: Se transformaron los precios de INR a euros para homogeneizar la moneda con los datos previos.
3. **CSV de Kaggle**: Se extrajeron datos adicionales sobre capacidad, modelo, RAM, entre otros. También se transformaron los precios de varias monedas a euros.

### Proceso de Limpieza de Datos

Los pasos generales seguidos en la limpieza de los datos son los siguientes:

1. **Renombrado de columnas y transformación de datos**: Se renombraron las columnas con caracteres no deseados y se transformaron datos numéricos que estaban en formato de texto.
2. **Normalización de texto**: Los textos fueron convertidos a minúsculas para asegurar la uniformidad.
3. **Unión de los tres datasets**: Los tres datasets fueron combinados en uno solo, seleccionando las columnas necesarias y renombrándolas de manera coherente.
4. **Imputación de valores faltantes**:
   - Se imputaron los valores faltantes en las columnas numéricas (como RAM, batería, pantalla, cores y año) utilizando la mediana de cada columna.
   - Para el sistema operativo (`os`), se imputaron los valores vacíos con el sistema operativo más frecuente de la marca correspondiente.
5. **Limpieza de datos erróneos**: Se eliminaron valores vacíos en algunas columnas, como `val_1` a `val_5`, que contenían el 96% de valores nulos.
6. **Conversión de texto entre comillas**: Se eliminaron las comillas de los modelos que estaban entre comillas en algunos registros.

## Librerías Utilizadas

Este proyecto hace uso de las siguientes librerías en R para realizar la limpieza, análisis y visualización de datos:

- `tidyverse`: Conjunto de librerías para la manipulación de datos.
- `dplyr`: Librería para la manipulación eficiente de datos.
- `caret`: Herramienta para la creación de modelos predictivos.
- `ggplot2`: Para la visualización de datos.
- `scales`: Para la visualización de escala en gráficos.
- `cluster`: Para la realización de análisis de clustering.
- `DataExplorer`: Para explorar y visualizar el dataset.
- `stringr`: Para trabajar con cadenas de texto de manera eficiente.

## Requisitos

Para ejecutar este proyecto, se debe tener instalado R y las siguientes librerías:

```r
install.packages(c("tidyverse", "dplyr", "caret", "ggplot2", "scales", "cluster", "DataExplorer", "stringr"))
```

## Ejecución

Ejecutamos el archivo Main.R desde R studio o ejecutamos en consola 

```r
source("main.R")
```

## Datasets externos
- https://www.opendatabay.com/data/consumer/a16cb863-a839-4245-800f-37ef284b2883?utm_source=chatgpt.com
- https://www.kaggle.com/datasets/abdulmalik1518/mobiles-dataset-2025
