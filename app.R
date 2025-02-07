#=================================================================
# ! IMPORTANTE: Este es el archivo principal de la aplicación Shiny
# # ===============================================================
# # MAPAS DISTRIBUIDORA DIMAL - APLICACIÓN SHINY - BISTURITO MAPS
# # Sistema de visualización y análisis de rutas de camiones
# # ===============================================================

#=================================================================
# # ===============================================================
# # CONFIGURACIÓN DE MODULOS
# # ===============================================================

# ! Cargar librerías necesarias para la aplicación
library(shiny)

# # ===============================================================
# ! APLICACIÓN PRINCIPAL - BISTURITO MAPS
# # ===============================================================

# ! Cargar configuración global
source("CONFIG.R")

# ! Cargar módulos principales
source("global.R") # 1_ GLOBAL: Configuración y variables globales
source("ui.R")     # 2_ UI: Interfaz de usuario
source("server.R") # 3_ SERVER: Lógica del servidor

#=================================================================
# # ===============================================================
# # APP
# # ===============================================================
# ! Inicialización de la aplicación Shiny
shinyApp(ui = ui, server = server)
#=================================================================
