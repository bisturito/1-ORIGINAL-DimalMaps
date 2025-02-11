#================================================================

# ▀█▀ ░█▄─░█ ▀▀█▀▀ ░█▀▀▀ ░█▀▀█ ░█▀▀▀ ─█▀▀█ ░█▀▀▀█ 
# ░█─ ░█░█░█ ─░█── ░█▀▀▀ ░█▄▄▀ ░█▀▀▀ ░█▄▄█ ─▄▄▄▀▀ 
# ▄█▄ ░█──▀█ ─░█── ░█▄▄▄ ░█─░█ ░█─── ░█─░█ ░█▄▄▄█

#================================================================

# ! Cargar configuración global
source("CONFIG.R")

# ! Definición de la interfaz de usuario utilizando shinydashboard
ui <- dashboardPage(
  
  # ! Encabezado del dashboard con el título de la aplicación
  dashboardHeader(title = "Dimal Mapas"),
  
  # ! Barra lateral del dashboard
  dashboardSidebar(
    sidebarMenu(
      # ! Elementos del menú principal
      menuItem("Mapa", tabName = "mapas", icon = icon("map")),
      menuItem("Estadísticas", tabName = "estadisticas", icon = icon("chart-bar")),
      
      # ? Submenú dentro de "Datos" para diferentes tablas de datos
      menuItem("Datos", icon = icon("table"),
               menuSubItem("Safetrack Camiones", tabName = "datos_estacionados"),
               menuSubItem("Proyectos Clientes", tabName = "datos_proyectos"),
               menuSubItem("Predictivo Cli-Camion", tabName = "datos_nueva_tabla")
      ),
      
      # ! Nueva pestaña "Guía de uso" a nivel principal
      menuItem("Guía de uso", tabName = "guia_uso", icon = icon("book-open")),
      
      br(),  # Línea en blanco para separación
      
      # ! Interruptor para cambiar entre modo claro y oscuro
      switchInput("dark_mode_switch", "Modo Nocturno", onLabel = "ON", offLabel = "OFF"),
      
      br(),  # Otra línea en blanco
      
      # ! Mostrar la hora actual en la barra lateral
      textOutput("currentTime")
    )
  ),
  

# 
# ░█▀▀▄ ─█▀▀█ ░█▀▀▀█ ░█─░█ 　 ░█▀▀█ ░█▀▀▀█ ░█▀▀▄ ░█──░█ 
# ░█─░█ ░█▄▄█ ─▀▀▀▄▄ ░█▀▀█ 　 ░█▀▀▄ ░█──░█ ░█─░█ ░█▄▄▄█ 
# ░█▄▄▀ ░█─░█ ░█▄▄▄█ ░█─░█ 　 ░█▄▄█ ░█▄▄▄█ ░█▄▄▀ ──░█──

  # ! Cuerpo del dashboard
  dashboardBody(
    useShinyjs(),  # ? Permite el uso de funciones de shinyjs para manipular el DOM
    
    # ! Inclusión de estilos personalizados y fuentes
    tags$head(
      # ! Fuente personalizada desde Google Fonts
      tags$link(rel = "stylesheet", href = CSS_CONFIG$google_fonts),
      
      # ! Archivo CSS personalizado
      tags$link(rel = "stylesheet", href = CSS_CONFIG$custom_css),
      
      # ! Variables CSS para colores de la aplicación
      tags$style(HTML(CSS_CONFIG$css_variables)),
      
      # ! JavaScript para manejar el botón de filtros
      tags$script(HTML("
        $(document).ready(function() {
          // Crear el botón de filtros
          var filterButton = $('<button class=\"filtros-toggle\"></button>');
          
          // Agregar el botón al control personalizado
          $('.leaflet-control-custom').html(filterButton);
          
          // Manejar el clic en el botón
          filterButton.click(function() {
            $('.box-filtros').toggle();
          });
        });
      "))
    ),
    
    # ! Placeholder para alertas dinámicas
    div(id = "alert_placeholder"),
    
    # ! Definición de las diferentes pestañas de contenido
    tabItems(
      
# 
# ░█▀▀█ ░█▀▀▀ ░█▀▀▀█ ▀▀█▀▀ ─█▀▀█ ░█▄─░█ ─█▀▀█ ░█▀▀▀█ 
# ░█▄▄█ ░█▀▀▀ ─▀▀▀▄▄ ─░█── ░█▄▄█ ░█░█░█ ░█▄▄█ ─▀▀▀▄▄ 
# ░█─── ░█▄▄▄ ░█▄▄▄█ ─░█── ░█─░█ ░█──▀█ ░█─░█ ░█▄▄▄█    
# ! Definición de las diferentes pestañas de contenido
      tabItem(
# 
# ░█▀▄▀█ ─█▀▀█ ░█▀▀█ ─█▀▀█ 
# ░█░█░█ ░█▄▄█ ░█▄▄█ ░█▄▄█ 
# ░█──░█ ░█─░█ ░█─── ░█─░█      
      # ! Pestaña MAPA
        tabName = "mapas",
        fluidRow(
          # ! Columna para las opciones de filtrado del mapa
          column(
            width = 4,
            box(
              # title = "Opciones del Mapa predictivo", # Eliminado
              width = 12,
              class = "box-filtros",
              
              # ======================================================
              # ! Bloque 1: Datos Safetrack
              h4("Datos Safetrack"),
              
              # 1) Rango de fechas
              dateRangeInput(
                "fecha", "Seleccionar Rango de Fechas:",
                start = Sys.Date() - 1,   # antes: fecha_inicio_default
                end   = Sys.Date() - 1,   # antes: fecha_fin_default
                min = min(merged_df$fecha, na.rm = TRUE),
                max = max(merged_df$fecha, na.rm = TRUE),
                format = "dd/mm/yyyy",
                language = "es",
                separator = " hasta "
              ),
              
              # 2) Mostrar camiones (sin la palabra "demora")
              checkboxInput("mostrar_demora", "Mostrar Camiones", value = TRUE),
              
              # 3) Seleccionar placas de camiones
              selectizeInput(
                "placas_camiones", "Seleccionar Placas de Camiones",
                choices = if (exists("merged_df")) sort(unique(merged_df$Numero_de_placa)) else NULL,
                multiple = TRUE,
                options = list(
                  placeholder = "Seleccionar placas...",
                  plugins = list("remove_button")
                )
              ),
              br(),
              
              # ======================================================
              # Bloque 2: Datos Predictivos
              h4("Datos Predictivos"),
              
              # Mostrar Clientes Predictivos (por defecto TRUE/ FALSE según lo desees)
              checkboxInput("mostrar_clientes", "Mostrar Clientes(Predictivos)", value = TRUE),
              
              # Seleccionar Proyectos Predictivos
              selectizeInput(
                "proyectos", "Seleccionar Proyectos(Predictivos)",
                choices = if (exists("merged_df")) sort(unique(merged_df$PROYECTO)) else NULL,
                multiple = TRUE,
                options = list(
                  placeholder = "Seleccionar proyectos...",
                  plugins = list("remove_button")
                )
              ),
              br(),
              
              # ======================================================
              # Bloque 3: Datos Proyectos Originales
              h4("Datos Proyectos Originales"),
              
              checkboxInput("mostrar_todos_proyectos", "Mostrar proyectos (Originales)", value = FALSE),
              selectizeInput(
                "proyectos_originales", "Seleccionar Proyectos(Originales)",
                choices = unique(as.character(proyectos_clientes$PROYECTO)),
                multiple = TRUE,
                options = list(placeholder = 'Seleccionar proyectos originales...')
              ),
              
              # ! Botón para resetear todos los filtros
              actionButton(
                "reset_filtros", "Resetear Filtros",
                style = "background-color: #dc3545; color: white",
                class = "btn-default"
              )
            )
          ),
          
          # ! Columna para el mapa y la tabla de duración por camión
          column(
            width = 8,
            box(
              title = "Mapa",
              width = 12,
              leafletOutput("mapa", height = 600)
            ),
            box(
              title = "Duración por Camión",
              width = 12,
              DTOutput("tabla_duracion")
            )
          )
        )
      ),
      
      #------------------------------------------------------
# 
# ░█▀▀▀ ░█▀▀▀█ ▀▀█▀▀ ─█▀▀█ ░█▀▀▄ ▀█▀ ░█▀▀▀█ ▀▀█▀▀ ▀█▀ ░█▀▀█ ─█▀▀█ ░█▀▀▀█ 
# ░█▀▀▀ ─▀▀▀▄▄ ─░█── ░█▄▄█ ░█─░█ ░█─ ─▀▀▀▄▄ ─░█── ░█─ ░█─── ░█▄▄█ ─▀▀▀▄▄ 
# ░█▄▄▄ ░█▄▄▄█ ─░█── ░█─░█ ░█▄▄▀ ▄█▄ ░█▄▄▄█ ─░█── ▄█▄ ░█▄▄█ ░█─░█ ░█▄▄▄█
      #------------------------------------------------------
      tabItem(
        tabName = "estadisticas",
        fluidRow(
          column(
            width = 12,
            h3("Estadísticas"),
            box(title = "Duración Camiones", width = 12, plotlyOutput("cuanto_tarda_plot")),
            box(title = "Proyectos por Duración", width = 12, plotlyOutput("proyectos_por_duracion_plot")),
            box(title = "Camiones con Más Clientes visitados", width = 12, plotlyOutput("camiones_mas_clientes_plot")),
            box(title = "Clientes Más Visitados", width = 12, plotlyOutput("clientes_mas_visitados_plot")),
            box(title = "Duración por Día y Proyecto", width = 12, plotlyOutput("scatter_duracion_dias_plot"))
          )
        )
      ),
      
#------------------------------------------------------
# 
# ░█▀▀▀ ░█▀▀▀█ ▀▀█▀▀ ─█▀▀█ ░█▀▀█ ▀█▀ ░█▀▀▀█ ░█▄─░█ ─█▀▀█ ░█▀▀▄ ░█▀▀▀█ ░█▀▀▀█ 
# ░█▀▀▀ ─▀▀▀▄▄ ─░█── ░█▄▄█ ░█─── ░█─ ░█──░█ ░█░█░█ ░█▄▄█ ░█─░█ ░█──░█ ─▀▀▀▄▄ 
# ░█▄▄▄ ░█▄▄▄█ ─░█── ░█─░█ ░█▄▄█ ▄█▄ ░█▄▄▄█ ░█──▀█ ░█─░█ ░█▄▄▀ ░█▄▄▄█ ░█▄▄▄█
#------------------------------------------------------
      tabItem(
        tabName = "datos_estacionados",
        fluidRow(
          column(
            width = 12,
            h3("Safetrack Camiones"),
            box(
              title = "Tabla de Estacionados",
              width = 12,
              fluidRow(
                column(
                  width = 6,
                  dateRangeInput(
                    "fecha_estacionados", "Filtrar por rango de fechas:",
                    start = estacionados_fechas$max_fecha - 1,
                    end   = estacionados_fechas$max_fecha,
                    min   = estacionados_fechas$min_fecha,
                    max   = estacionados_fechas$max_fecha,
                    separator = " hasta "
                  )
                )
              ),
              downloadButton("download_estacionados", "Descargar lo filtrado"),
              br(), br(),
              DTOutput("tabla_estacionados")
            )
          )
        )
      ),
      
      #------------------------------------------------------
# 
# ░█▀▀█ ░█▀▀█ ░█▀▀▀█ ░█──░█ ░█▀▀▀ ░█▀▀█ ▀▀█▀▀ ░█▀▀▀█ ░█▀▀▀█ 
# ░█▄▄█ ░█▄▄▀ ░█──░█ ░█▄▄▄█ ░█▀▀▀ ░█─── ─░█── ░█──░█ ─▀▀▀▄▄ 
# ░█─── ░█─░█ ░█▄▄▄█ ──░█── ░█▄▄▄ ░█▄▄█ ─░█── ░█▄▄▄█ ░█▄▄▄█ 
# 
# ░█▀▀█ ░█─── ▀█▀
# ░█─── ░█─── ░█─
# ░█▄▄█ ░█▄▄█ ▄█▄ 
      #------------------------------------------------------
      tabItem(
        tabName = "datos_proyectos",
        fluidRow(
          column(
            width = 12,
            h3("Proyectos y Clientes"),
            box(
              title = "Tabla de Proyectos y Clientes",
              width = 12,
              downloadButton("download_proyectos", "Descargar excell completo"),
              br(), br(),
              DTOutput("tabla_proyectos")
            )
          )
        )
      ),
      
      #------------------------------------------------------
# 
# ░█▀▀█ ░█▀▀█ ░█▀▀▀ ░█▀▀▄ ▀█▀ ░█▀▀█ ▀▀█▀▀ ▀█▀ ░█──░█ ░█▀▀▀█ 
# ░█▄▄█ ░█▄▄▀ ░█▀▀▀ ░█─░█ ░█─ ░█─── ─░█── ░█─ ─░█░█─ ░█──░█ 
# ░█─── ░█─░█ ░█▄▄▄ ░█▄▄▀ ▄█▄ ░█▄▄█ ─░█── ▄█▄ ──▀▄▀─ ░█▄▄▄█ 
# 
# ░█▀▀█ ░█─── ▀█▀ 　 ░█▀▀█ ─█▀▀█ ░█▀▄▀█ ▀█▀ ░█▀▀▀█ ░█▄─░█ 
# ░█─── ░█─── ░█─ 　 ░█─── ░█▄▄█ ░█░█░█ ░█─ ░█──░█ ░█░█░█ 
# ░█▄▄█ ░█▄▄█ ▄█▄ 　 ░█▄▄█ ░█─░█ ░█──░█ ▄█▄ ░█▄▄▄█ ░█──▀█
      #------------------------------------------------------
      tabItem(
        tabName = "datos_nueva_tabla",
        fluidRow(
          column(
            width = 12,
            h3("Tabla Final predictivo cliente camion"),
            box(
              title = "Filtro datos unidos",
              width = 12,
              fluidRow(
                column(
                  width = 4,
                  dateRangeInput(
                    "fecha_nueva_tabla", "Seleccionar Rango de Fechas:",
                    start = ultima_fecha_tabla_final - 1,
                    end   = ultima_fecha_tabla_final,
                    min   = primera_fecha_tabla_final,
                    max   = ultima_fecha_tabla_final,
                    separator = " hasta "
                  )
                ),
                column(
                  width = 4,
                  sliderInput(
                    "hora_nueva_tabla", "Seleccionar Rango de Horas:",
                    min = 0, max = 23,
                    value = c(7, 19),
                    step = 1,
                    ticks = FALSE,
                    sep = ""
                  )
                ),
                column(
                  width = 4,
                  selectizeInput(
                    "placa_nueva_tabla", "Seleccionar Número de Placa:",
                    choices = unique(tabla_final$Numero_de_placa),
                    multiple = TRUE,
                    options = list(placeholder = 'Seleccionar placas...')
                  )
                )
              ),
              downloadButton("download_tabla_final", "Descargar lo filtrado", class = "btn-primary"),
              DTOutput("tabla_final_output")
            )
          )
        )
      ),
      
#------------------------------------------------------
      
# ░█▀▀█ ░█─░█ ▀█▀ ─█▀▀█ 
# ░█─▄▄ ░█─░█ ░█─ ░█▄▄█ 
# ░█▄▄█ ─▀▄▄▀ ▄█▄ ░█─░█

#------------------------------------------------------
      tabItem(
        tabName = "guia_uso",
        fluidRow(
          column(
            width = 12,
            h2("Guía de uso"),
            
            # 1) Texto inicial
            p("DIMAL MAPAS es una app que muestra las paradas de los camiones en sus recorridos diarios 
               del horario de 7am a 6pm. Al mismo tiempo, los vincula con el cliente que se encuentre 
               a la distancia más cercana y con el o los proyectos que tenga vinculado dicho cliente. 
               Esta última vinculación se realiza a modo de predicción, teniendo en cuenta la 
               lógica mencionada."),
            p("Datos que se utilizan: información diaria de Safetrack, datos de proyectos en archivo 
               de Tareas de DIMAL y datos de ubicaciones de clientes."),
            
            br(),
            
            # 2) Cómo usarlo
            h3("COMO USARLO"),
            p("Hay tres tipos de menú con información pertinente:"),
            p("Mapas"),
            p("Estadísticas"),
            p("Datos"),
            tags$img(
              src = "png/como_usarlo.png", 
              style = "max-width:200px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            
            br(),
            
            # 3) Sección: Mapas
            h3("Menú: Mapa"),
            h4("Datos Safetrack"),            
            p(strong("Filtro: Rango de fechas:")),
            p("Se puede filtrar por rango de fechas. La app al comenzar siempre 
               mostrará los datos cargados del día anterior (de 7am a 6pm)."),
            
            tags$img(
              src = "png/rango_fechas.png", 
              style = "max-width:400px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            
            p("Mostrará los camiones estacionados. Los camiones tienen el ícono de camión y los colores 
               representan el tiempo que permanecieron estacionados:"),
               tags$img(
              src = "png/duracion_mapa.png", 
              style = "max-width:200px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            p("- Verde: menos de 12 minutos."),
            p("- Amarillo: entre 12 y 20 minutos."),
            p("- Rojo: más de 20 minutos."),
            p("Al mismo tiempo se puede observar la información de duración (mínimo, mediana y máximo) 
               debajo del mapa."),
            
            br(),
            
            # Filtro: Seleccionar Placas de Camiones
            p(strong("Filtro: Seleccionar Placas de Camiones")),
            p("Se podrá filtrar por placas de camiones para visibilizar el recorrido de solo un camión 
               durante un rango determinado de tiempo."),
  tags$img(
              src = "png/selector_placas_camiones.png", 
              style = "max-width:400px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
               
            p("Al hacer clic en el ícono de camión, encontramos 
               datos como: Número de placa, tiempo de inicio, duración y la predicción de Proyecto/Cliente."),
tags$img(
              src = "png/click_camion.png", 
              style = "max-width:400px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            
          
            
            br(),
            
            # Filtro: Mostrar Clientes Predictivos
            h4("Datos Predictivos"),
            p(strong("Filtro: Mostrar Clientes Predictivos")),
            p("El menú 'Mostrar Clientes (Predictivos)' ubica en el mapa los clientes que se encuentren 
               más cercanos a las paradas de los camiones. Así se estima el potencial cliente visitado 
               según la distancia de la parada. En el mapa, los clientes están representados por un ícono 
               de una persona de color verde gris."),
            
            tags$img(
              src = "png/mostrar_clientes_predictivos.png", 
              style = "max-width:400px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            
            p("Al hacer clic en el ícono de la persona, vemos el cliente más cercano al camión 
               y el proyecto vinculado, junto al código del camión. Generalmente se deja activado 
               por defecto para vincular rápidamente ambos."),
            
            tags$img(
              src = "png/click_cliente.png", 
              style = "max-width:400px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            
            p("NOTA: Si quisiéramos ver todos los clientes, en el cartel 'Capas del Mapa' se pueden 
               seleccionar recursos adicionales como ver todos los clientes, lugares de pago y la 
               ubicación de la empresa."),
            
            tags$img(
              src = "png/capa_del_mapa.png", 
              style = "max-width:400px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            
            br(),
            
            # Filtro: Seleccionar Proyectos Predictivos
            p(strong("Filtro: Seleccionar Proyectos Predictivos")),
            p("Permite seleccionar y visibilizar el camión vinculado con un proyecto específico. Al ser 
               predictivo, responde al atributo del proyecto que esté vinculado con el cliente más cercano 
               al camión."),
               br(),
            
            # Filtro: Mostrar proyectos (Originales)
            h4("Datos Proyectos Originales"),
            tags$img(
              src = "png/datos_proyectos_originales.png", 
              style = "max-width:400px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            p(strong("Filtro: Mostrar proyectos (Originales)")),
            p("Permite mostrar todos los proyectos y sus ubicaciones, representados por un ícono celeste."),
            
            # Filtro: Seleccionar Proyectos (Originales)
            p(strong("Filtro: Seleccionar Proyectos (Originales)")),
            p("Permite seleccionar proyectos específicos."),
            
            tags$img(
              src = "png/proyectos_originales.png", 
              style = "max-width:400px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            
            br(),
            
            # 4) Menú: Estadísticas
            h3(strong("Menú: Estadísticas")),
            p("Muestra estadísticas descriptivas relacionadas al filtro realizado en la sección 'Mapas', 
               para profundizar en la información."),
            
            br(),
            
            # 5) Menú: Datos
            h3(strong("Menú: Datos")),
            p("Hay tres tipos de tablas:"),
            tags$img(
              src = "png/menu_datos.png", 
              style = "max-width:800px; display:block; margin-bottom:20px; margin-top:10px;"
            ),
            p("- Safetrack Camiones: muestra la información de Safetrack, filtrable por rango de fecha."),
            p("- Proyectos Clientes: muestra los proyectos según el archivo Tareas de DIMAL."),
            p("- Proyectos Cli-Camion: vincula, a modo predictivo, la ubicación de los camiones con los 
               clientes cercanos. Las tablas son dinámicas y pueden descargarse."),
            
            tags$img(
              src = "png/ejemplo_tablas.png", 
              style = "max-width:800px; display:block; margin-bottom:20px; margin-top:10px;"
            )
          )
        )
      )
    )
  )
)
