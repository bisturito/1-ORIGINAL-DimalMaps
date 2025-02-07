#=================================================================
# ! INTERFAZ DE USUARIO (UI)
#=================================================================

# ! Cargar configuración global
source("CONFIG.R")

# ! Definición de la interfaz de usuario utilizando shinydashboard
ui <- dashboardPage(
  
  # ! Encabezado del dashboard con el título de la aplicación
  dashboardHeader(title = "Mapas Distribuidora Dimal"),
  
  # ! Barra lateral del dashboard
  dashboardSidebar(
    sidebarMenu(
      # ! Elementos del menú principal
      menuItem("Mapa", tabName = "mapas", icon = icon("map")),
      menuItem("Estadísticas", tabName = "estadisticas", icon = icon("chart-bar")),
      
      # ? Submenú dentro de "Datos" para diferentes tablas de datos
      menuItem("Datos", icon = icon("table"),
        menuSubItem("Estacionados Camión", tabName = "datos_estacionados"),
        menuSubItem("Proyectos Clientes", tabName = "datos_proyectos"),
        menuSubItem("Predictivo Cli-Camion", tabName = "datos_nueva_tabla")
      ),
      
      br(),  # Línea en blanco para separación
      
      # ! Interruptor para cambiar entre modo claro y oscuro
      switchInput("dark_mode_switch", "Modo Nocturno", onLabel = "ON", offLabel = "OFF"),
      
      br(),  # Otra línea en blanco
      
      # ! Mostrar la hora actual en la barra lateral
      textOutput("currentTime")
    )
  ),
  
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
      
      # ! Pestaña MAPA
      tabItem(tabName = "mapas",
        fluidRow(
          # ! Columna para las opciones de filtrado del mapa
          column(width = 4,
                 box(
                   title = "Opciones del Mapa predictivo",
                   width = 12,
                   class = "box-filtros",
                   
                   # ? Selector de rango de fechas
                   dateRangeInput("fecha", "Seleccionar Rango de Fechas:",
                                  start = fecha_inicio_default,
                                  end = fecha_fin_default,
                                  min = min(merged_df$fecha, na.rm = TRUE),
                                  max = max(merged_df$fecha, na.rm = TRUE),
                                  format = "dd/mm/yyyy",
                                  language = "es",
                                  separator = " hasta "),
                   
                   # ! Checkboxes para mostrar diferentes capas en el mapa
                   checkboxInput("mostrar_clientes", "Mostrar Clientes(Predictivos)", value = TRUE),
                   checkboxInput("mostrar_demora", "Mostrar Camiones(Demora)", value = TRUE),
                   
                   # ? Selector de placas de camiones
                   selectizeInput("placas_camiones", "Seleccionar Placas de Camiones",
                                  choices = if(exists("merged_df")) sort(unique(merged_df$Numero_de_placa)) else NULL,
                                  multiple = TRUE,
                                  options = list(
                                    placeholder = "Seleccionar placas...",
                                    plugins = list("remove_button")
                                  )),
                   
                   # ? Selector de proyectos
                   selectizeInput("proyectos", "Seleccionar Proyectos(Predictivos)",
                                  choices = if(exists("merged_df")) sort(unique(merged_df$PROYECTO)) else NULL,
                                  multiple = TRUE,
                                  options = list(
                                    placeholder = "Seleccionar proyectos...",
                                    plugins = list("remove_button")
                                  )),
                   
                   # ! Checkbox para mostrar proyectos originales
                   checkboxInput("mostrar_todos_proyectos", "Mostrar proyectos (Originales)", value = FALSE),
                   
                   # ? Selector de proyectos originales
                   selectizeInput("proyectos_originales", "Seleccionar Proyectos(Originales)",
                                  choices = unique(as.character(proyectos_clientes$PROYECTO)),
                                  multiple = TRUE,
                                  options = list(placeholder = 'Seleccionar proyectos originales...')),
                   
                   # ! Botón para resetear todos los filtros
                   actionButton("reset_filtros", "Resetear Filtros", style = "background-color: #dc3545; color: white", class = "btn-default")
                 )
          ),
          
          # ! Columna para el mapa y la tabla de duración por camión
          column(width = 8,
                 # ! Caja que contiene el mapa interactivo
                 box(
                   title = "Mapa",
                   width = 12,
                   leafletOutput("mapa", height = 600)
                 ),
                 # ! Caja que contiene la tabla de duración por camión
                 box(
                   title = "Duración por Camión",
                   width = 12,
                   DTOutput("tabla_duracion")
                 )
          )
        )
      ),
      
      # ! Pestaña ESTADÍSTICAS
      tabItem(tabName = "estadisticas",
        fluidRow(
          column(width = 12,
            h3("Estadísticas"),
            # ! Gráficos de diferentes estadísticas
            box(title = "Duración Camiones", width = 12, plotlyOutput("cuanto_tarda_plot")),
            box(title = "Proyectos por Duración", width = 12, plotlyOutput("proyectos_por_duracion_plot")),
            box(title = "Camiones con Más Clientes visitados", width = 12, plotlyOutput("camiones_mas_clientes_plot")),
            box(title = "Clientes Más Visitados", width = 12, plotlyOutput("clientes_mas_visitados_plot")),
            box(title = "Duración por Día y Proyecto", width = 12, plotlyOutput("scatter_duracion_dias_plot"))
          )
        )
      ),
      
      # ! Pestaña DATOS ESTACIONADOS
      tabItem(tabName = "datos_estacionados",
        fluidRow(
          column(width = 12,
                 h3("Estacionados Camión"),
                 box(
                   title = "Tabla de Estacionados",
                   width = 12,
                   fluidRow(
                     column(width = 6,
                            # ? Selector de rango de fechas para estacionados
                            dateRangeInput("fecha_estacionados", "Filtrar por rango de fechas:",
                                           start = estacionados_fechas$max_fecha - 1,
                                           end = estacionados_fechas$max_fecha,
                                           min = estacionados_fechas$min_fecha,
                                           max = estacionados_fechas$max_fecha,
                                           separator = " hasta "
                            )
                     )
                   ),
                   # ! Botón para descargar los datos filtrados
                   downloadButton("download_estacionados", "Descargar lo filtrado"),
                   br(), br(),
                   # ! Tabla interactiva de datos estacionados
                   DTOutput("tabla_estacionados")
                 )
          )
        )
      ),
      
      # ! Pestaña DATOS PROYECTOS CLIENTES
      tabItem(tabName = "datos_proyectos",
        fluidRow(
          column(width = 12,
                 h3("Proyectos y Clientes"),
                 box(
                   title = "Tabla de Proyectos y Clientes",
                   width = 12,
                   # ! Botón para descargar la tabla completa
                   downloadButton("download_proyectos", "Descargar excell completo"),
                   br(), br(),
                   # ! Tabla interactiva de proyectos y clientes
                   DTOutput("tabla_proyectos")
                 )
          )
        )
      ),
      
      # ! Pestaña PREDICTIVO CLI-CAMION
      tabItem(tabName = "datos_nueva_tabla",
        fluidRow(
          column(width = 12,
                 h3("Tabla Final predictivo cliente camion"),
                 box(
                   title = "Filtro datos unidos",
                   width = 12,
                   fluidRow(
                     # ? Selector de rango de fechas
                     column(width = 4,
                            dateRangeInput("fecha_nueva_tabla", "Seleccionar Rango de Fechas:",
                                           start = ultima_fecha_tabla_final - 1,
                                           end = ultima_fecha_tabla_final,
                                           min = primera_fecha_tabla_final,
                                           max = ultima_fecha_tabla_final,
                                           separator = " hasta "
                            )
                     ),
                     # ? Selector de rango de horas
                     column(width = 4,
                            sliderInput("hora_nueva_tabla", "Seleccionar Rango de Horas:",
                                        min = 0, max = 23, value = c(7, 19), step = 1,
                                        ticks = FALSE, sep = "")
                     ),
                     # ? Selector de número de placa
                     column(width = 4,
                            selectizeInput("placa_nueva_tabla", "Seleccionar Número de Placa:",
                                           choices = unique(tabla_final$Numero_de_placa),
                                           multiple = TRUE,
                                           options = list(placeholder = 'Seleccionar placas...'))
                     )
                   ),
                   # ! Botón para descargar los datos filtrados
                   downloadButton("download_tabla_final", "Descargar lo filtrado", class = "btn-primary"),
                   # ! Tabla interactiva final
                   DTOutput("tabla_final_output")
                 )
          )
        )
      )
    )
  )
)
