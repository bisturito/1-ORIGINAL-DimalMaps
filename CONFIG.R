# # ===============================================================

# ░█▀▀█ ░█▀▀▀█ ░█▄─░█ ░█▀▀▀ ▀█▀ ░█▀▀█ ░█─░█ ░█▀▀█ ─█▀▀█ ░█▀▀█ ▀█▀ ░█▀▀▀█ ░█▄─░█ 
# ░█─── ░█──░█ ░█░█░█ ░█▀▀▀ ░█─ ░█─▄▄ ░█─░█ ░█▄▄▀ ░█▄▄█ ░█─── ░█─ ░█──░█ ░█░█░█ 
# ░█▄▄█ ░█▄▄▄█ ░█──▀█ ░█─── ▄█▄ ░█▄▄█ ─▀▄▄▀ ░█─░█ ░█─░█ ░█▄▄█ ▄█▄ ░█▄▄▄█ ░█──▀█
# ! CONFIGURACIÓN GLOBAL DE LA APLICACIÓN

# ! Configuración del repositorio CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

# ! Configuración de memoria y timeouts
options(shiny.maxRequestSize = 30*1024^2)
options(timeout = 300)

# # ===============================================================
# ░█─── ▀█▀ ░█▀▀█ ░█▀▀█ ░█▀▀▀ ░█▀▀█ ▀█▀ ─█▀▀█ ░█▀▀▀█ 
# ░█─── ░█─ ░█▀▀▄ ░█▄▄▀ ░█▀▀▀ ░█▄▄▀ ░█─ ░█▄▄█ ─▀▀▀▄▄ 
# ░█▄▄█ ▄█▄ ░█▄▄█ ░█─░█ ░█▄▄▄ ░█─░█ ▄█▄ ░█─░█ ░█▄▄▄█

# ! Carga silenciosa de librerías necesarias
suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(leaflet)
  library(readxl)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(plotly)
  library(shinyjs)
  library(shinyWidgets)
  library(jsonlite)
  library(writexl)
  library(DT)
  library(openxlsx)
  library(logger)
})

# # ===============================================================
# ░█▀▀█ ░█─░█ ▀▀█▀▀ ─█▀▀█ ░█▀▀▀█ 
# ░█▄▄▀ ░█─░█ ─░█── ░█▄▄█ ─▀▀▀▄▄ 
# ░█─░█ ─▀▄▄▀ ─░█── ░█─░█ ░█▄▄▄█
# !  RUTAS Y ARCHIVOS
# !  RUTAS Y ARCHIVOS / AHORA GOOGLE SHEET
# ! Rutas de archivos
DATA_PATH <- list(
  lugares_pago = "./data/Limpia/lugares_pago.xlsx",
  ubi_empresa = "./data/Limpia/ubi_empresa.xlsx",
  merged_df = "./data/Limpia/merged_df.xlsx",
  tabla_final = "./data/Limpia/Tabla_Final_menuDatos.xlsx",
  ubicaciones = "./data/Limpia/Ubicaciones_direcciones.xlsx",
  estacionados = "./data/Limpia/estacionados_camion_todos_estados.xlsx",
  proyectos = "./data/Limpia/Tabla_Proyectos_Clientes.xlsx"
)

# # ===============================================================
# 
# ░█▀▄▀█ ─█▀▀█ ░█▀▀█ ─█▀▀█ 
# ░█░█░█ ░█▄▄█ ░█▄▄█ ░█▄▄█ 
# ░█──░█ ░█─░█ ░█─── ░█─░█
# ! Coordenadas y zoom por defecto
MAPA_CONFIG <- list(
  lat = -34.7737,  # Latitud de Atlántida
  lng = -55.7631,  # Longitud de Atlántida
  zoom_default = 13,  # Zoom más cercano para ver Atlántida y alrededores
  zoom_min = 11,   # Zoom mínimo permitido
  zoom_max = 18    # Zoom máximo permitido
)
# # ===============================================================
# 
# ░█▀▀▀ ░█▀▀▀█ ▀▀█▀▀ ▀█▀ ░█─── ░█▀▀▀█ 
# ░█▀▀▀ ─▀▀▀▄▄ ─░█── ░█─ ░█─── ░█──░█ 
# ░█▄▄▄ ░█▄▄▄█ ─░█── ▄█▄ ░█▄▄█ ░█▄▄▄█
# ! CONFIGURACIÓN DE COLORES E ÍCONOS
# ! Configuración de colores de la aplicación
COLORES_APP <- list(
  primario = "#567472",      # Verde grisáceo
  secundario = "#B1C900",    # Verde lima
  exito = "#2ecc71",         # Verde
  peligro = "#e74c3c",       # Rojo
  advertencia = "#f1c40f",   # Amarillo
  info = "#3498db",          # Azul info
  claro = "#ecf0f1",         # Gris claro
  oscuro = "#2c3e50"         # Azul oscuro
)

# ! Colores para placas de camiones
COLORES_PLACAS <- list(
  'PARTNER 4251' = 'blue',
  'BERLINGO7008' = 'purple',
  'BYD1006' = 'darkgreen',
  'BYD1004' = 'darkred',
  'PartnerABG9758' = 'cadetblue',
  'defecto' = 'pink'  # Color por defecto
)

# ! Íconos personalizados para el mapa
dinero_icon <- makeIcon(
  iconUrl = "https://img.icons8.com/?size=100&id=eYaVJ9Nbqqbw&format=png&color=00FF00",
  iconWidth = 25, iconHeight = 25
)

casa_icon <- makeIcon(
  iconUrl = "https://img.icons8.com/ios-filled/50/0000FF/home.png",
  iconWidth = 25, iconHeight = 25
)

cliente_icon <- makeIcon(
  iconUrl = "https://img.icons8.com/ios-filled/50/557371/user.png",  
  iconWidth = 25, iconHeight = 25
)

# ! Íconos para diferentes tipos de proyectos
iconos_proyectos <- list(
  "Rutas" = makeIcon(iconUrl = "https://img.icons8.com/ios-filled/50/006400/road.png", 
                     iconWidth = 25, iconHeight = 25),
  "Creditos" = makeIcon(iconUrl = "https://img.icons8.com/ios-filled/50/006400/bank-card-back-side.png", 
                        iconWidth = 25, iconHeight = 25),
  "Visitas periodicas" = makeIcon(iconUrl = "https://img.icons8.com/ios-filled/50/000000/recurring-appointment.png", 
                                 iconWidth = 25, iconHeight = 25),
  "Cliente especial" = makeIcon(iconUrl = "https://img.icons8.com/ios-filled/50/FFFF00/star.png", 
                               iconWidth = 25, iconHeight = 25)
)


# # ===============================================================
# █▀▀ █▀▀ █▀▀ 
# █── ▀▀█ ▀▀█ 
# ▀▀▀ ▀▀▀ ▀▀▀
# !ESTILOS FUENTES y CSS (Ya probe unificarlo a www/custom.css pero se re complica todo, lo dejo asi)
# # ===============================================================


# ! Configuración de fuentes y estilos CSS
CSS_CONFIG <- list(
  google_fonts = "https://fonts.googleapis.com/css2?family=Raleway:wght@300;400;700&display=swap",
  custom_css = "custom.css",
  css_variables = sprintf("
    :root {
      --primary-color: %s;
      --secondary-color: %s;
      --success-color: %s;
      --danger-color: %s;
      --warning-color: %s;
      --info-color: %s;
      --light-color: %s;
      --dark-color: %s;
    }

    /* Estilos para los controles del mapa */
    .leaflet-control-layers {
      background-color: white !important;
      border-radius: 6px !important;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1) !important;
      font-family: 'Raleway', sans-serif !important;
      transition: all 0.3s ease !important;
    }

    .leaflet-control-layers:hover {
      box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
    }

    .leaflet-control-layers-toggle {
      width: auto !important;
      min-width: 36px !important;
      height: 36px !important;
      background-color: white !important;
      border-radius: 6px !important;
      padding: 0 15px !important;
      display: flex !important;
      align-items: center !important;
      white-space: nowrap !important;
      color: var(--primary-color) !important;
      font-weight: 600 !important;
      font-size: 14px !important;
      letter-spacing: 0.3px !important;
      transition: all 0.3s ease !important;
      background-image: none !important;
    }

    .leaflet-control-layers-toggle::before {
      content: '📍' !important;
      margin-right: 8px !important;
      font-size: 16px !important;
    }

    .leaflet-control-layers-toggle::after {
      content: 'Capas del Mapa' !important;
    }

    .leaflet-control-layers-expanded {
      padding: 12px 15px !important;
      min-width: 200px !important;
      border-top: 3px solid var(--primary-color) !important;
    }

    .leaflet-control-layers-expanded label {
      margin: 6px 0 !important;
      padding: 6px 8px !important;
      border-radius: 4px !important;
      transition: background-color 0.2s !important;
      font-size: 13px !important;
    }

    .leaflet-control-layers-expanded label:hover {
      background-color: rgba(0,0,0,0.05) !important;
    }

    .leaflet-control-layers-separator {
      margin: 10px 0 !important;
      border-top: 1px solid rgba(0,0,0,0.1) !important;
    }

    /* Leyenda de duración */
    .info.legend {
      margin-top: 10px !important;
      background-color: white !important;
      border-radius: 6px !important;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1) !important;
      padding: 12px !important;
    }
  ",
  COLORES_APP$primario,
  COLORES_APP$secundario,
  COLORES_APP$exito,
  COLORES_APP$peligro,
  COLORES_APP$advertencia,
  COLORES_APP$info,
  COLORES_APP$claro,
  COLORES_APP$oscuro
  )
)



# # ===============================================================
# 
# ░█▀▀▀ ─█▀▀█ ░█─── ▀▀█▀▀ ─█▀▀█ 
# ░█▀▀▀ ░█▄▄█ ░█─── ─░█── ░█▄▄█ 
# ░█─── ░█─░█ ░█▄▄█ ─░█── ░█─░█
# TODAVIA NO SE IMPLEMENTA ESTO PERO QUEDA ACA PARA USARSE 
# Variables no implementadas 

# ! Colores para placas de camiones (TODAVIA NO IMPLEMENTADO)
COLORES_PLACAS <- list(
  'PARTNER 4251' = 'blue',
  'BERLINGO7008' = 'purple',
  'BYD1006' = 'darkgreen',
  'BYD1004' = 'darkred',
  'PartnerABG9758' = 'cadetblue',
  'defecto' = 'pink'
)

# ! Íconos para diferentes tipos de proyectos
iconos_proyectos <- list(
  "Rutas" = makeIcon(iconUrl = "https://img.icons8.com/ios-filled/50/006400/road.png", iconWidth = 25, iconHeight = 25),
  "Creditos" = makeIcon(iconUrl = "https://img.icons8.com/ios-filled/50/006400/bank-card-back-side.png", iconWidth = 25, iconHeight = 25),
  "Visitas periodicas" = makeIcon(iconUrl = "https://img.icons8.com/ios-filled/50/000000/recurring-appointment.png", iconWidth = 25, iconHeight = 25),
  "Cliente especial" = makeIcon(iconUrl = "https://img.icons8.com/ios-filled/50/FFFF00/star.png", iconWidth = 25, iconHeight = 25)
)

# # ===============================================================
