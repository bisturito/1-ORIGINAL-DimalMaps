#=================================================================
# ░█▀▀█ ░█▀▀▀█ ░█▄─░█ ░█▀▀▀ ▀█▀ ░█▀▀█ ░█─░█ ░█▀▀█ ─█▀▀█ ░█▀▀█ ▀█▀ ░█▀▀▀█ ░█▄─░█ 
# ░█─── ░█──░█ ░█░█░█ ░█▀▀▀ ░█─ ░█─▄▄ ░█─░█ ░█▄▄▀ ░█▄▄█ ░█─── ░█─ ░█──░█ ░█░█░█ 
# ░█▄▄█ ░█▄▄▄█ ░█──▀█ ░█─── ▄█▄ ░█▄▄█ ─▀▄▄▀ ░█─░█ ░█─░█ ░█▄▄█ ▄█▄ ░█▄▄▄█ ░█──▀█
# ! CONFIGURACIÓN INICIAL Y LIBRERÍAS
#=============================================================
# ! Cargar archivo de configuración
source("CONFIG.R")

#===============================================================
# ░█─── ░█▀▀▀ ░█▀▀▀ ░█▀▀█ 
# ░█─── ░█▀▀▀ ░█▀▀▀ ░█▄▄▀ 
# ░█▄▄█ ░█▄▄▄ ░█▄▄▄ ░█─░█
leer_datos_seguro <- function(archivo, tipo = "excel") {
  tryCatch({
    if (!file.exists(archivo)) {
      return(data.frame())
    }

    if (tipo == "excel") {
      datos <- read_excel(archivo)
    } else {
      datos <- read.csv(archivo)
    }
    return(datos)
  }, error = function(e) {
    return(data.frame())
  })
}
# ! Cargar datos con manejo de errores
merged_df <- leer_datos_seguro(DATA_PATH$merged_df)
if (nrow(merged_df) > 0) {
  merged_df <- merged_df %>%
    mutate(
      Tiempo_de_Inicio = as.POSIXct(Tiempo_de_Inicio, 
                                   format="%Y-%m-%d %H:%M:%S", 
                                   tz="America/Montevideo"),
      fecha = as.Date(Tiempo_de_Inicio),
      Duracion = as.numeric(Duracion),
      CODIGO = as.numeric(CODIGO),
      LATITUD = as.numeric(LATITUD),
      LONGITUD = as.numeric(LONGITUD),
      camion_x = as.numeric(camion_x),
      camion_y = as.numeric(camion_y),
      Ubicacion_URL = ifelse(
        str_detect(UBICACIÓN, "^http://") | str_detect(UBICACIÓN, "^https://"),
        UBICACIÓN,
        ifelse(!is.na(camion_x) & !is.na(camion_y),
               paste0("https://www.google.com/maps/search/?api=1&query=", 
                      camion_x, ",", camion_y),
               NA)
      )
    )
}

# ! Cargar datos secundarios
lugares_pago <- leer_datos_seguro(DATA_PATH$lugares_pago)
if (nrow(lugares_pago) > 0) {
  lugares_pago <- lugares_pago %>%
    mutate(
      CODIGO = as.numeric(CODIGO),
      LATITUD = as.numeric(LATITUD),
      LONGITUD = as.numeric(LONGITUD),
      NOMCLI = tolower(NOMCLI) %>%
        str_replace_all("[^a-z]", " ") %>%
        str_squish()
    )
}

ubi_empresa <- leer_datos_seguro(DATA_PATH$ubi_empresa)
if (nrow(ubi_empresa) > 0) {
  ubi_empresa <- ubi_empresa %>%
    mutate(
      CODIGO = as.numeric(CODIGO),
      LATITUD = as.numeric(LATITUD),
      LONGITUD = as.numeric(LONGITUD)
    )
}

tabla_final <- leer_datos_seguro(DATA_PATH$tabla_final)
if (nrow(tabla_final) > 0) {
  tabla_final <- tabla_final %>%
    mutate(
      fecha = as.Date(Dia_camion_estac, format = "%d-%m-%Y"),
      CODIGO = as.numeric(CODIGO),
      distancia_predictiva = as.numeric(distancia_predictiva)
    )
}

ubicaciones_direcciones <- leer_datos_seguro(DATA_PATH$ubicaciones)
if (nrow(ubicaciones_direcciones) > 0) {
  ubicaciones_direcciones <- ubicaciones_direcciones %>%
    mutate(
      FECHA = as.Date(FECHA),
      CODIGO = as.numeric(CODIGO),
      LATITUD = as.numeric(LATITUD),
      LONGITUD = as.numeric(LONGITUD)
    )
}

estacionados_camion <- leer_datos_seguro(DATA_PATH$estacionados)
if (nrow(estacionados_camion) > 0) {
  estacionados_camion <- estacionados_camion %>%
    mutate(
      Tiempo_de_Inicio = as.POSIXct(as.numeric(Tiempo_de_Inicio), 
                                   origin="1970-01-01", 
                                   tz="America/Montevideo"),
      Tiempo_Final = as.POSIXct(as.numeric(Tiempo_Final), 
                               origin="1970-01-01", 
                               tz="America/Montevideo"),
      fecha = as.Date(Tiempo_de_Inicio),
      Duracion = as.numeric(Duracion),
      camion_x = as.numeric(camion_x),
      camion_y = as.numeric(camion_y)
    )
}

proyectos_clientes <- leer_datos_seguro(DATA_PATH$proyectos)
if (nrow(proyectos_clientes) > 0) {
  proyectos_clientes <- proyectos_clientes %>%
    mutate(
      CODIGO = as.numeric(CODIGO),
      LATITUD = as.numeric(LATITUD),
      LONGITUD = as.numeric(LONGITUD)
    )
}

#=================================================================
# ! FECHAS Y TOTALES UNIFICADOS
# █▀▀ █▀▀█ █── █▀▀ █──█ █── █▀▀█ 
# █── █▄▄█ █── █── █──█ █── █──█ 
# ▀▀▀ ▀──▀ ▀▀▀ ▀▀▀ ─▀▀▀ ▀▀▀ ▀▀▀▀

# ░█▀▀▀ ░█▀▀▀ ░█▀▀█ ░█─░█ ─█▀▀█ 
# ░█▀▀▀ ░█▀▀▀ ░█─── ░█▀▀█ ░█▄▄█ 
# ░█─── ░█▄▄▄ ░█▄▄█ ░█─░█ ░█─░█

# ▀▀█▀▀ ░█▀▀▀█ ▀▀█▀▀ ─█▀▀█ ░█─── ░█▀▀▀ ░█▀▀▀█ 
# ─░█── ░█──░█ ─░█── ░█▄▄█ ░█─── ░█▀▀▀ ─▀▀▀▄▄ 
# ─░█── ░█▄▄▄█ ─░█── ░█─░█ ░█▄▄█ ░█▄▄▄ ░█▄▄▄█

# ! Calcular fechas límite para los datos de merged_df
if (nrow(merged_df) > 0) {
  ultima_fecha_datos <- max(merged_df$fecha, na.rm = TRUE)
  fecha_fin_default <- ultima_fecha_datos
  fecha_inicio_default <- ultima_fecha_datos - 1
} else {
  ultima_fecha_datos <- Sys.Date()
  fecha_fin_default <- ultima_fecha_datos
  fecha_inicio_default <- ultima_fecha_datos - 1
}

# ! Calcular las fechas y totales para Clientes
primera_fecha_clientes <- min(ubicaciones_direcciones$FECHA, na.rm = TRUE)
ultima_fecha_clientes <- max(ubicaciones_direcciones$FECHA, na.rm = TRUE)
total_clientes <- nrow(ubicaciones_direcciones)

# ! Calcular las fechas y totales para Safetrack
if (nrow(merged_df) > 0) {
  primera_fecha_safetrack <- min(merged_df$fecha, na.rm = TRUE)
  ultima_fecha_safetrack <- max(merged_df$fecha, na.rm = TRUE)
  total_safetrack <- nrow(merged_df)
} else {
  primera_fecha_safetrack <- Sys.Date() - 30
  ultima_fecha_safetrack <- Sys.Date()
  total_safetrack <- 0
}

# ! Definir variables globales para los selectores
PLACAS_DISPONIBLES <- if (nrow(merged_df) > 0) sort(unique(merged_df$Numero_de_placa)) else character(0)
PROYECTOS_DISPONIBLES <- if (nrow(merged_df) > 0) sort(unique(merged_df$PROYECTO)) else character(0)

# ! Calcular las fechas mínimas y máximas para estacionados_camion
if (nrow(estacionados_camion) > 0) {
  estacionados_fechas <- estacionados_camion %>% 
    summarise(
      min_fecha = min(Tiempo_de_Inicio, na.rm = TRUE),
      max_fecha = max(Tiempo_de_Inicio, na.rm = TRUE)
    )
}

# ! Calcular el rango de fechas de tabla_final
tabla_final_fechas <- as.Date(tabla_final$Dia_camion_estac, format = "%d-%m-%Y")
primera_fecha_tabla_final <- min(tabla_final_fechas, na.rm = TRUE)
ultima_fecha_tabla_final <- max(tabla_final_fechas, na.rm = TRUE)

