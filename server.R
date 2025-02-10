#==========================================================================
# ! DEFINICIÓN DEL SERVIDOR
#==========================================================================

server <- function(input, output, session) {
  
  #--------------------------------------------------
  # ! Manejo de la capa "proyectos_originales" en el mapa
  #--------------------------------------------------
  
  # ? Observa cambios en "mostrar_todos_proyectos" y "proyectos_originales"
  observe({
    # Limpia siempre el grupo "proyectos_originales" antes de agregar nuevos marcadores
    leafletProxy("mapa") %>% clearGroup("proyectos_originales")
    
    if (input$mostrar_todos_proyectos) {
      # ! Si se activa, muestra todos los proyectos originales
      leafletProxy("mapa") %>% addMarkers(
        data = proyectos_clientes,
        lng = ~LONGITUD,
        lat = ~LATITUD,
        popup = ~paste("Cliente:", NOMCLI, "<br>Proyecto:", PROYECTO),
        group = "proyectos_originales"
      )
    } else {
      # ! Si no se activa, muestra solo los proyectos seleccionados
      if (!is.null(input$proyectos_originales) && length(input$proyectos_originales) > 0) {
        proyectos_filtrados <- proyectos_clientes %>% filter(PROYECTO %in% input$proyectos_originales)
        if (nrow(proyectos_filtrados) > 0) {
          leafletProxy("mapa") %>% addMarkers(
            data = proyectos_filtrados,
            lng = ~LONGITUD,
            lat = ~LATITUD,
            popup = ~paste("Cliente:", NOMCLI, "<br>Proyecto:", PROYECTO),
            group = "proyectos_originales"
          )
        }
      }
      # ? Si no hay proyectos seleccionados, no agrega nada
    }
  })
  
  #--------------------------------------------------
  # ! Actualización automática del checkbox "mostrar_todos_proyectos"
  #--------------------------------------------------
  
  observeEvent(input$proyectos_originales, {
    if (!is.null(input$proyectos_originales) && length(input$proyectos_originales) > 0) {
      # ! Si se seleccionan proyectos originales, activa el checkbox
      updateCheckboxInput(session, "mostrar_todos_proyectos", value = TRUE)
    } else {
      # ! Si no hay selección, desactiva el checkbox
      updateCheckboxInput(session, "mostrar_todos_proyectos", value = FALSE)
    }
  })
  
  #--------------------------------------------------
  # ! Botón para resetear todos los filtros
  #--------------------------------------------------
  
  observeEvent(input$reset_filtros, {
    # ! Primero actualizamos los controles
    # ? Restablecer fecha a valores predeterminados
    updateDateRangeInput(session, "fecha",
                        start = Sys.Date() - 1,
                        end = ultima_fecha_safetrack - 1)
    
    # ! Restablecer checkboxes principales
    updateCheckboxInput(session, "mostrar_todos_proyectos", value = FALSE)
    updateCheckboxInput(session, "mostrar_clientes", value = FALSE)
    updateCheckboxInput(session, "mostrar_demora", value = FALSE)
    
    # ! Restablecer selectores
    updateSelectizeInput(session, "proyectos_originales", selected = character(0))
    updateSelectizeInput(session, "placas_camiones", selected = character(0))
    updateSelectizeInput(session, "proyectos", selected = character(0))
    
    # ! Luego actualizamos el mapa de manera más suave
    leafletProxy("mapa") %>%
      clearGroup("proyectos_originales") %>%
      clearGroup("clientes") %>%
      clearGroup("camiones") %>%
      clearGroup("camiones_markers") %>%
      # ? Usamos flyTo en lugar de setView para una transición más suave
      flyTo(
        lat = -34.7736,
        lng = -55.7536,
        zoom = 13,
        options = list(duration = 1.5)  # duración de la animación en segundos
      )
    
    # ! Mostrar mensaje usando una notificación simple
    showNotification(
      "Filtros reseteados correctamente",
      type = "message",
      duration = 3
    )
})

  
  #--------------------------------------------------
  # ! Actualización automática del checkbox "mostrar_clientes"
  #--------------------------------------------------
  
  observeEvent(input$proyectos, {
    if (!is.null(input$proyectos) && length(input$proyectos) > 0) {
      # ! Si se seleccionan proyectos predictivos, activa el checkbox
      updateCheckboxInput(session, "mostrar_clientes", value = TRUE)
    } else {
      # ! Si no hay selección, desactiva el checkbox
      updateCheckboxInput(session, "mostrar_clientes", value = FALSE)
    }
  })
  
  #--------------------------------------------------
  # ! RELOJ con la hora de Uruguay
  #--------------------------------------------------
  
  output$currentTime <- renderText({
    invalidateLater(1000, session)  # Actualiza cada segundo
    hora_actual <- with_tz(Sys.time(), tzone = "America/Montevideo")  # Ajusta a la zona horaria de Uruguay
    paste("Hora actual:", format(hora_actual, "%H:%M:%S"))
  })
  
  #--------------------------------------------------
  # ! Preparación de datos adicionales
  #--------------------------------------------------
  
  # ? Agrega una columna de URL para ubicaciones_direcciones
  ubicaciones_direcciones <- ubicaciones_direcciones %>%
    mutate(Ubicacion_URL = paste0("https://www.google.com/maps/search/?api=1&query=", LATITUD, ",", LONGITUD))
  
  # ! Definición de colores para los gráficos que combinen con la aplicación
  colores_graficos <- list(
    primario = COLORES_APP$primario,  # Color del encabezado y barra lateral
    secundario = COLORES_APP$secundario,  # Color de acento
    exito = COLORES_APP$exito,  # Verde para indicadores positivos
    peligro = COLORES_APP$peligro,    # Rojo para indicadores negativos
    advertencia = COLORES_APP$advertencia,   # Amarillo para advertencias
    info = COLORES_APP$info,      # Azul para información
    claro = COLORES_APP$claro,     # Color de fondo claro
    oscuro = COLORES_APP$oscuro       # Negro para modo oscuro
  )
  
  #--------------------------------------------------
  # ! Alternar entre modos claro y oscuro
  #--------------------------------------------------
  
  observe({
    if (input$dark_mode_switch) {
      shinyjs::addClass(selector = "body", class = "dark-mode")
    } else {
      shinyjs::removeClass(selector = "body", class = "dark-mode")
    }
  })
  
  #--------------------------------------------------
  # ! Mostrar notificación al iniciar la aplicación
  #--------------------------------------------------
  
  # ? Variable reactiva para controlar si ya se mostró la notificación inicial
  first_load <- reactiveVal(TRUE)
  
  observe({
    if (first_load()) {
      sendSweetAlert(
        session = session,
        title = "¡Datos cargados exitosamente!",
        text = HTML(
          paste0(
            "<p><strong>Clientes último registro: ", format(ultima_fecha_clientes, "%d/%m/%Y"), ".</strong></p>",
            "<p>Clientes registros totales: <strong>", total_clientes, "</strong>.</p>",
            "<p><strong>Safetrack van del ", format(primera_fecha_safetrack, "%d/%m/%Y"),
            " hasta el ", format(ultima_fecha_safetrack, "%d/%m/%Y"), ".</strong></p>",
            "<p>Safetrack registros totales: <strong>", total_safetrack, "</strong>.</p>",
            "<p>Tareas actualizado el: <strong>", format(as.Date("2024-12-17"), "%d/%m/%Y"), "</strong>.</p>"
          )
        ),
        html = TRUE,
        type = "success",
        width = "500px"
      )
      first_load(FALSE)  # Marcar que ya se mostró la notificación
    }
  })
  
  #--------------------------------------------------
  # ! Función para mostrar alertas de éxito o error
  #--------------------------------------------------
  
  show_alert <- function(type, message) {
    removeUI(selector = "#alert_placeholder div")  # Elimina cualquier alerta previa
    insertUI(
      selector = "#alert_placeholder",
      ui = div(
        class = paste0("alert alert-", type),
        tags$b(message)
      )
    )
    if (type == "success") {
      shinyjs::delay(3000, removeUI(selector = "#alert_placeholder div"))  # Remueve la alerta después de 3 segundos
    }
  }
  
  #--------------------------------------------------
  # ! Filtrar datos para la tabla de estacionados
  #--------------------------------------------------
  
  datos_estacionados_filtrados <- reactive({
    req(input$fecha_estacionados)  # Asegura que el input no sea NULL
    
    if (length(input$fecha_estacionados) == 2) {
      fecha_inicio <- as.POSIXct(paste(input$fecha_estacionados[1], "00:00:00"), tz = "America/Montevideo")
      fecha_fin <- as.POSIXct(paste(input$fecha_estacionados[2], "23:59:59"), tz = "America/Montevideo")
      
      return(estacionados_camion %>%
        filter(
          Tiempo_de_Inicio >= fecha_inicio,
          Tiempo_de_Inicio <= fecha_fin
        ))
    } else {
      return(data.frame())  # Retorna un data frame vacío si las fechas no son válidas
    }
  })
  
  #--------------------------------------------------
  # ! Observador para mostrar u ocultar clientes en el mapa
  #--------------------------------------------------
  
  observe({
    if (input$mostrar_clientes) {
      leafletProxy("mapa") %>%
        clearGroup("markers_clientes") %>%
        addMarkers(
          data = datos_filtrados(),
          lng = ~LONGITUD,
          lat = ~LATITUD,
          popup = ~paste(
            "Cliente:", NOMCLI, "<br>",
            "Ubicación:", UBICACIÓN
          ),
          icon = cliente_icon,
          group = "markers_clientes"  # Grupo único para clientes predictivos
        )
    } else {
      leafletProxy("mapa") %>% clearGroup("markers_clientes")
    }
  })
  
  #--------------------------------------------------
  # ! Filtrar datos basado en el rango de fechas seleccionado
  #--------------------------------------------------
  
  datos_filtrados <- reactive({
    req(input$fecha)  # Asegura que el input no sea NULL
    
    tryCatch({
      # Conversión de fechas a POSIXct
      fecha_inicio <- as.POSIXct(paste(input$fecha[1], "00:00:00"), 
                                format="%Y-%m-%d %H:%M:%S", 
                                tz="America/Montevideo")
      fecha_fin <- as.POSIXct(paste(input$fecha[2], "23:59:59"), 
                             format="%Y-%m-%d %H:%M:%S", 
                             tz="America/Montevideo")
      
      # Filtra los datos por el rango de fechas
      data <- merged_df %>%
        filter(
          Tiempo_de_Inicio >= fecha_inicio & 
          Tiempo_de_Inicio <= fecha_fin
        )
      
      # Filtra por placas de camiones si se seleccionaron
      if (!is.null(input$placas_camiones) && length(input$placas_camiones) > 0) {
        data <- data %>% filter(Numero_de_placa %in% input$placas_camiones)
      }
      
      # Filtra por proyectos predictivos si se seleccionaron
      if (!is.null(input$proyectos) && length(input$proyectos) > 0) {
        data <- data %>% filter(PROYECTO %in% input$proyectos)
      }
      
      return(data)
    }, error = function(e) {
      print(paste("Error en datos_filtrados:", e$message))
      return(data.frame())  # Retorna un data frame vacío en caso de error
    })
  })
  
  #--------------------------------------------------
  # ! Actualizar opciones de 'placas_camiones' y 'proyectos' basado en el rango de fechas seleccionado
  #--------------------------------------------------
  
  observeEvent(input$fecha, {
    # Conversión de fechas a POSIXct
    fecha_inicio <- as.POSIXct(paste(input$fecha[1], "00:00:00"), 
                              format="%Y-%m-%d %H:%M:%S", 
                              tz="America/Montevideo")
    fecha_fin <- as.POSIXct(paste(input$fecha[2], "23:59:59"), 
                           format="%Y-%m-%d %H:%M:%S", 
                           tz="America/Montevideo")
    
    # Filtra los datos solo por fecha
    filtered_data <- merged_df %>%
      filter(
        Tiempo_de_Inicio >= fecha_inicio & 
        Tiempo_de_Inicio <= fecha_fin
      )
    
    # Actualiza los selectores de placas y proyectos con los datos filtrados
    updateSelectizeInput(session, "placas_camiones",
      choices = sort(unique(filtered_data$Numero_de_placa)),
      selected = input$placas_camiones
    )
    
    updateSelectizeInput(session, "proyectos",
      choices = sort(unique(filtered_data$PROYECTO)),
      selected = input$proyectos
    )
  })
  
  #--------------------------------------------------
  # ! Calcular estadísticas de duración usando datos filtrados
  #--------------------------------------------------
  
  duration_stats_by_truck <- reactive({
    filtered_data <- datos_filtrados()
    if (nrow(filtered_data) > 0) {
      stats_list <- filtered_data %>%
        group_by(Numero_de_placa) %>%
        summarize(
          min = min(Duracion, na.rm = TRUE),
          median = median(Duracion, na.rm = TRUE),
          max = max(Duracion, na.rm = TRUE)
        )
      return(stats_list)
    } else {
      return(NULL)
    }
  })
  
  #--------------------------------------------------
  # ! Renderizar mapa inicial
  #--------------------------------------------------
  
  output$mapa <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap, group = "🛣️ Calles") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "🛰️ Satélite") %>%
      clearGroup("proyectos_originales") %>%  # Asegura que el grupo esté vacío
      setView(lng = -55.7536, lat = -34.7736, zoom = 13) %>%  # Centra el mapa en una ubicación específica
      # Agrega marcadores para lugares de pago
      addMarkers(
        data = lugares_pago,
        lng = ~LONGITUD,
        lat = ~LATITUD,
        popup = ~NOMCLI,
        icon = dinero_icon,
        group = "💰 Lugares Pago"
      ) %>%
      # Agrega marcadores para la empresa
      addMarkers(
        data = ubi_empresa,
        lng = ~LONGITUD,
        lat = ~LATITUD,
        popup = ~NOMCLI,
        icon = casa_icon,
        group = "🏢 Empresa"
      ) %>%
      # Agrega marcadores para todas las ubicaciones de clientes
      addMarkers(
        data = ubicaciones_direcciones,
        lng = ~LONGITUD,
        lat = ~LATITUD,
        popup = ~paste0(
          "Cliente: ", NOMCLI, "<br>",
          "Ubicación: <a href='", Ubicacion_URL, "' target='_blank'>Ver en Mapa</a>"
        ),
        icon = cliente_icon,
        group = "👥 Ver todos los clientes"
      ) %>%
      # ! Control de Capas del Mapa
      # * Configuración mejorada con emojis y estilos modernos
      # ? Nota: collapsed = TRUE mantiene el control plegado por defecto
      # TODO: Considerar agregar más capas según necesidades futuras
      addLayersControl(
        baseGroups = c("🛣️ Calles", "🛰️ Satélite"),
        overlayGroups = c("💰 Lugares Pago", "🏢 Empresa", "👥 Ver todos los clientes"),
        options = layersControlOptions(
          collapsed = TRUE,
          position = "topright"
        )
      ) %>%
      # ! Ocultar capa de clientes por defecto
      # * Mejora la privacidad y rendimiento inicial
      hideGroup("👥 Ver todos los clientes")
  })
  
  #--------------------------------------------------
  # ! Ocultar la capa "Ver todos los clientes" por defecto
  #--------------------------------------------------
  
  observe({
    leafletProxy("mapa") %>% hideGroup("👥 Ver todos los clientes")
  })
  
  #--------------------------------------------------
  # ! Observador para mostrar u ocultar la leyenda de demora
  #--------------------------------------------------
  
  observeEvent(input$mostrar_demora, {
    if (input$mostrar_demora) {
      # Si se activa, agrega una leyenda de duración
      leafletProxy("mapa") %>%
        addLegend(
          layerId = "legend",    # ID para poder remover luego
          position = "topleft",
          colors = c("green", "orange", "red"),
          labels = c("D < 12", "12 ≤ D ≤ 20", "D > 20"),
          title = "Duración (min)",
          opacity = 1
        )
    } else {
      # Si se desactiva, remueve la leyenda
      leafletProxy("mapa") %>% removeControl("legend")
    }
  })
  
  #--------------------------------------------------
  # ! Actualizar mapa basado en filtros seleccionados
  #--------------------------------------------------
  
  observe({
    # Limpia grupos anteriores antes de agregar nuevos marcadores
    leafletProxy("mapa") %>% 
      clearGroup("camiones_markers") %>%
      clearGroup("markers_clientes") %>%
      clearGroup("camiones_placas")
    
    datos_mapa <- datos_filtrados()
    
    # Mostrar camiones con demora si está seleccionado
    if (input$mostrar_demora && nrow(datos_mapa) > 0) {
      merged_markers <- datos_mapa %>%
        filter(!is.na(camion_x) & !is.na(camion_y)) %>%
        mutate(
          markerColor = case_when(
            Duracion < 12 ~ "green",
            Duracion >= 12 & Duracion <= 20 ~ "orange",
            TRUE ~ "red"
          ),
          popup_text = paste(
            "Número de Placa:", Numero_de_placa,
            "<br>Tiempo de Inicio:", format(Tiempo_de_Inicio, "%Y-%m-%d %H:%M"),
            "<br>Duración:", round(Duracion, 2), "min",
            "<br>Proyecto:", PROYECTO,
            "<br>Cliente:", NOMCLI,
            "<br><a href='", Ubicacion_URL, "' target='_blank'>Ver en Google Maps</a>"
          )
        )
      
      if(nrow(merged_markers) > 0) {
        leafletProxy("mapa") %>%
          addAwesomeMarkers(
            data = merged_markers, 
            lng = ~camion_y,
            lat = ~camion_x,
            popup = ~popup_text,
            icon = awesomeIcons(
              icon = 'truck',
              iconColor = 'black',
              library = 'fa',
              markerColor = ~markerColor
            ),
            group = "camiones_markers"
          )
      }
    }
    
    # Mostrar clientes si está seleccionado
    if (input$mostrar_clientes && nrow(datos_mapa) > 0) {
      clientes_markers <- datos_mapa %>%
        filter(!is.na(LATITUD) & !is.na(LONGITUD)) %>%
        distinct(CODIGO, NOMCLI, PROYECTO, LATITUD, LONGITUD)
      
      if(nrow(clientes_markers) > 0) {
        leafletProxy("mapa") %>%
          addMarkers(
            data = clientes_markers,
            lng = ~LONGITUD,
            lat = ~LATITUD,
            popup = ~paste(
              "Cliente:", NOMCLI,
              "<br>Proyecto:", PROYECTO,
              "<br>Código:", CODIGO
            ),
            icon = cliente_icon,
            group = "markers_clientes"
          )
      }
    }
  })
  
  #--------------------------------------------------
  # ! Renderizar tabla de duración con mejoras visuales
  #--------------------------------------------------
  
  output$tabla_duracion <- renderDT({
    duration_stats <- duration_stats_by_truck()
    
    if (!is.null(duration_stats)) {
      datatable(
        duration_stats,
        colnames = c("Número de Placa", "Mínimo", "Mediana", "Máximo"),
        options = list(
          pageLength = 10,
          dom = 't',
          columnDefs = list(list(targets = 1:3, className = 'dt-center'))
        )
      )
    } else {
      datatable(data.frame(Mensaje = "No hay datos disponibles para el período seleccionado"))
    }
  })  
  
  #--------------------------------------------------
  # ! Mostrar fecha seleccionada en la pestaña Estadísticas
  #--------------------------------------------------
  
  output$selected_date_range <- renderText({
    fecha_inicio <- format(as.Date(input$fecha[1]), "%d/%m/%Y")
    fecha_fin <- format(as.Date(input$fecha[2]), "%d/%m/%Y")
    paste(fecha_inicio, " - ", fecha_fin)
  })
  
  #--------------------------------------------------
  # ! ================= GRAFICOS ===================
  #--------------------------------------------------
  
  # Gráfico: Duración Camiones
  output$cuanto_tarda_plot <- renderPlotly({
    filtered_data <- datos_filtrados()
    
    # Agrupar por camión y calcular duración total en horas
    duracion_total_por_camion <- filtered_data %>%
      group_by(Numero_de_placa) %>%
      summarise(Duracion_Total = sum(Duracion, na.rm = TRUE)) %>%
      mutate(Duracion_Horas = Duracion_Total / 60) %>%
      arrange(Duracion_Total)  # Orden ascendente
    
    # Calcular promedio general en horas
    promedio_duracion_horas <- mean(duracion_total_por_camion$Duracion_Horas, na.rm = TRUE)
    
    # Crear el gráfico mostrando duración en horas
    plot_ly(duracion_total_por_camion, 
            x = ~factor(Numero_de_placa, levels = duracion_total_por_camion$Numero_de_placa), 
            y = ~Duracion_Horas, 
            type = 'bar',
            name = 'Duración Total',
            marker = list(color = colores_graficos$secundario),  # Color secundario
            text = ~paste(round(Duracion_Horas, 2), "h"),  # Mostrar duración total en horas
            textposition = 'bottom',  # Posicionar el texto en la parte inferior de la barra
            hoverinfo = 'text',
            hovertext = ~paste("Duración Total:", round(Duracion_Total, 2), "min")) %>%
      add_trace(
        x = ~factor(Numero_de_placa, levels = duracion_total_por_camion$Numero_de_placa),
        y = rep(promedio_duracion_horas, nrow(duracion_total_por_camion)),  # Valores correctos del promedio
        type = 'scatter', 
        mode = 'lines+markers',  # Mostrar línea y puntos
        name = "Promedio Duración",
        line = list(color = colores_graficos$advertencia, dash = 'dash'),  # Color de la línea
        marker = list(color = 'red', size = 10),  # Cambiar el color del punto a rojo
        hoverinfo = 'text',
        hovertext = paste("Promedio Duración:", round(promedio_duracion_horas, 2), "h")
      ) %>%
      layout(title = 'Duración Camiones',
             xaxis = list(title = 'Número de Placa', tickangle = -45),
             yaxis = list(title = 'Duración Total (horas)'),
             bargap = 0.2,
             plot_bgcolor = colores_graficos$claro,
             paper_bgcolor = colores_graficos$claro)
  })
  
  # Gráfico: Proyectos por Duración
  output$proyectos_por_duracion_plot <- renderPlotly({
    filtered_data <- datos_filtrados()
    
    proyectos_duracion <- filtered_data %>%
      group_by(PROYECTO) %>%
      summarise(Duracion_Total = sum(Duracion, na.rm = TRUE)) %>%
      mutate(Duracion_Horas = Duracion_Total / 60) %>%
      arrange(Duracion_Total)  # Orden ascendente
    
    # Crear el gráfico sin la línea de promedio
    plot_ly(proyectos_duracion, 
            x = ~factor(PROYECTO, levels = proyectos_duracion$PROYECTO), 
            y = ~Duracion_Horas, 
            type = 'bar',
            name = 'Duración Total',
            marker = list(color = COLORES_APP$secundario),  # Color verde lima vibrante
            hoverinfo = 'text',
            hovertext = ~paste("Duración Total:", round(Duracion_Total, 2), "min (", round(Duracion_Horas, 2), "h)")) %>%
      layout(title = 'Proyectos por Duración',
             xaxis = list(title = 'Proyecto', tickangle = -45),
             yaxis = list(title = 'Duración Total (horas)'),
             barmode = 'group',
             plot_bgcolor = colores_graficos$claro,
             paper_bgcolor = colores_graficos$claro)
  })
  
  # Gráfico: Camiones con Más Clientes visitados
  output$camiones_mas_clientes_plot <- renderPlotly({
    filtered_data <- datos_filtrados()
    
    camiones_clientes <- filtered_data %>%
      group_by(Numero_de_placa) %>%
      summarise(Total_Clientes = n()) %>%
      arrange(Total_Clientes)  # Orden ascendente
    
    # Crear el gráfico con números más grandes en las barras
    plot_ly(camiones_clientes, 
            x = ~factor(Numero_de_placa, levels = camiones_clientes$Numero_de_placa), 
            y = ~Total_Clientes, 
            type = 'bar',
            name = 'Total de Clientes',
            marker = list(color = colores_graficos$secundario),  # Color secundario (#B1C900)
            text = ~Total_Clientes,
            textposition = 'auto',
            textfont = list(size = 16),  # Aumentar el tamaño de la fuente
            hoverinfo = 'text',
            hovertext = ~paste("Total Clientes:", Total_Clientes)) %>%
      layout(title = 'Camiones con Más Clientes visitados',
             xaxis = list(title = 'Número de Placa', tickangle = -45),
             yaxis = list(title = 'Total de Clientes'),
             bargap = 0.2,
             plot_bgcolor = colores_graficos$claro,
             paper_bgcolor = colores_graficos$claro,
             font = list(size = 12))  # Aumentar el tamaño general de la fuente
  })
  
  # Gráfico: Clientes Más Visitados
  output$clientes_mas_visitados_plot <- renderPlotly({
    filtered_data <- datos_filtrados()
    
    clientes_visitados <- filtered_data %>%
      group_by(NOMCLI) %>%
      summarise(Total_Visitas = n()) %>%
      arrange(desc(Total_Visitas)) %>%
      slice_head(n = 10)  # Cambiar a top 10
    
    # Crear el gráfico de barras horizontales
    plot_ly(clientes_visitados, 
            x = ~Total_Visitas,
            y = ~reorder(NOMCLI, Total_Visitas),
            type = 'bar',
            orientation = 'h',
            name = 'Total de Visitas',
            marker = list(color = colores_graficos$secundario),  # Color secundario
            text = ~Total_Visitas,
            textposition = 'auto',
            textfont = list(size = 9),
            hoverinfo = 'text',
            hovertext = ~paste("Total Visitas:", Total_Visitas)) %>%
      layout(title = 'Clientes Más Visitados',
             xaxis = list(title = 'Total de Visitas'),
             yaxis = list(title = 'Cliente'),
             bargap = 0.2,
             plot_bgcolor = colores_graficos$claro,
             paper_bgcolor = colores_graficos$claro)
  })
  
  # Gráfico: Scatterplot de Duración por Día y Proyecto
  output$scatter_duracion_dias_plot <- renderPlotly({
    filtered_data <- datos_filtrados() %>%
      mutate(Dia = as.Date(Tiempo_de_Inicio))
    
    plot_ly(data = filtered_data,
            x = ~Dia,
            y = ~Duracion,
            type = 'scatter',
            mode = 'markers',
            color = ~PROYECTO,
            colors = "Set1",  # Paleta de colores
            marker = list(size = 10, opacity = 0.7),
            text = ~paste("Proyecto:", PROYECTO,
                          "<br>Duración:", round(Duracion, 2), "min",
                          "<br>Camión:", Numero_de_placa),
            hoverinfo = 'text') %>%
      layout(title = 'Duración por Día y Proyecto',
             xaxis = list(title = 'Día'),
             yaxis = list(title = 'Duración (minutos)'),
             plot_bgcolor = colores_graficos$claro,
             paper_bgcolor = colores_graficos$claro)
  })
  
  #--------------------------------------------------
  # ! Observador adicional para proyectos_originales
  #--------------------------------------------------
  
  observeEvent(input$proyectos_originales, {
    req(input$proyectos_originales)  # Detiene el proceso si es NULL
    proyectos_filtrados <- proyectos_clientes %>%
      filter(PROYECTO %in% input$proyectos_originales)
    
    leafletProxy("mapa") %>%
      clearGroup("proyectos_originales") %>%
      addMarkers(
        data = proyectos_filtrados,
        lng = ~LONGITUD,
        lat = ~LATITUD,
        popup = ~paste("Cliente:", NOMCLI, "<br>Proyecto:", PROYECTO),
        group = "proyectos_originales"
      )
  })
  
  #--------------------------------------------------
  # ! Observador adicional para proyectos
  #--------------------------------------------------
  
  observeEvent(input$proyectos, {
    if (!is.null(input$proyectos) && length(input$proyectos) > 0) {
      updateCheckboxInput(session, "mostrar_clientes", value = TRUE)
    } else {
      updateCheckboxInput(session, "mostrar_clientes", value = FALSE)
    }
  })
  
  #--------------------------------------------------
  # ! Filtrar datos para la tabla final
  #--------------------------------------------------
  
  datos_tabla_final_filtrados <- reactive({
    req(input$fecha_nueva_tabla)  # Asegura que el input no sea NULL
    
    # Convertir las fechas del formato "dd-mm-yyyy" a Date
    filtered_data <- tabla_final %>%
      mutate(
        Fecha = as.Date(Dia_camion_estac, format = "%d-%m-%Y"),
        Hora = as.POSIXct(paste(Dia_camion_estac, Hora_camion_desde), 
                          format = "%d-%m-%Y %H:%M", 
                          tz = "America/Montevideo")
      )
    
    # Filtrar por rango de fechas
    filtered_data <- filtered_data %>%
      filter(Fecha >= as.Date(input$fecha_nueva_tabla[1]) & 
             Fecha <= as.Date(input$fecha_nueva_tabla[2]))
    
    # Filtrar por rango de horas si está seleccionado
    if (!is.null(input$hora_nueva_tabla)) {
      filtered_data <- filtered_data %>%
        filter(hour(Hora) >= input$hora_nueva_tabla[1] & 
               hour(Hora) <= input$hora_nueva_tabla[2])
    }
    
    # Filtrar por placas si se seleccionaron
    if (!is.null(input$placa_nueva_tabla) && length(input$placa_nueva_tabla) > 0) {
      filtered_data <- filtered_data %>% 
        filter(Numero_de_placa %in% input$placa_nueva_tabla)
    }
    
    # Seleccionar y ordenar las columnas relevantes
    filtered_data <- filtered_data %>%
      select(
        Dia_camion_estac,
        Hora_camion_desde,
        Numero_de_placa,
        CODIGO,
        NOMCLI,
        Duracion,
        distancia_predictiva,
        Ubicacion_Camion,
        Ubicacion_Cliente
      )
    
    return(filtered_data)
  })
  
  #--------------------------------------------------
  # ! ================== DESCARGAS ===================
  #--------------------------------------------------
  
  # Descarga de Tabla Final en Excel
  output$download_tabla_final <- downloadHandler(
    filename = function() {
      paste("Tabla_Final_Filtrada_", format(Sys.Date(), "%Y-%m-%d"), ".xlsx", sep = "")
    },
    content = function(file) {
      # Obtener los datos filtrados
      data_to_download <- datos_tabla_final_filtrados()
      
      # Escribir la tabla filtrada en un archivo Excel
      write_xlsx(data_to_download, path = file)
    }
  )
  
  # Descarga de Tabla de Proyectos y Clientes
  output$download_proyectos <- downloadHandler(
    filename = function() {
      paste("Proyectos_Clientes_", format(Sys.Date(), "%Y-%m-%d"), ".xlsx", sep="")
    },
    content = function(file) {
      # Crear un workbook
      wb <- createWorkbook()
      addWorksheet(wb, "Datos")
      
      # Escribir los datos
      writeData(wb, "Datos", proyectos_clientes)
      
      # Guardar el archivo
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
  
  # Descarga de Tabla de Estacionados
  output$download_estacionados <- downloadHandler(
    filename = function() {
      paste("Estacionados_Camion_", format(Sys.Date(), "%Y-%m-%d"), ".xlsx", sep="")
    },
    content = function(file) {
      # Usar los datos filtrados de la función reactiva
      filtered_data <- datos_estacionados_filtrados()
      
      # Crear un workbook
      wb <- createWorkbook()
      addWorksheet(wb, "Datos")
      writeData(wb, "Datos", filtered_data)
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
  
  #--------------------------------------------------
  # ! ================== RENDER DE TABLAS ===================
  #--------------------------------------------------
  
  # Renderizar tabla de estacionados
  output$tabla_estacionados <- renderDT({
    data_filtered <- datos_estacionados_filtrados()
    
    datatable(
      data_filtered,
      options = list(
        pageLength = 20,
        scrollX = TRUE,
        dom = 'lrtip',
        language = list(
          search = "Buscar:",
          lengthMenu = "Mostrar _MENU_ registros por página",
          info = "Mostrando _START_ a _END_ de _TOTAL_ registros",
          paginate = list(
            first = "Primero",
            last = "Último",
            siguiente = "Siguiente",
            anterior = "Anterior"
          )
        )
      ),
      selection = 'single',
      filter = list(position = 'top', clear = FALSE),
      rownames = FALSE
    )
  })
  
  # Renderizar tabla de proyectos y clientes
  output$tabla_proyectos <- renderDT({
    datatable(
      proyectos_clientes,
      options = list(
        pageLength = 20,
        scrollX = TRUE,
        dom = 'lrtip',
        language = list(
          search = "Buscar:",
          lengthMenu = "Mostrar _MENU_ registros por página",
          info = "Mostrando _START_ a _END_ de _TOTAL_ registros",
          paginate = list(
            first = "Primero",
            last = "Último",
            siguiente = "Siguiente",
            anterior = "Anterior"
          )
        )
      ),
      filter = 'top',
      rownames = FALSE
    ) %>%
    formatStyle(
      'CODIGO',
      backgroundColor = 'white',
      color = 'black'
    )
  })
  
  # Renderizar la tabla final con formato mejorado
  output$tabla_final_output <- renderDT({
    data <- datos_tabla_final_filtrados()
    
    if (is.null(data) || nrow(data) == 0) {
      return(datatable(data.frame(Mensaje = "No hay datos disponibles para los filtros seleccionados")))
    }
    
    # Verificar si existe la columna PROYECTO antes de intentar ocultarla
    columnDefs <- list()
    if ("PROYECTO" %in% names(data)) {
      columnDefs <- list(list(visible = FALSE, targets = which(names(data) == "PROYECTO") - 1))
    }
    
    DT::datatable(
      data,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        dom = 'Bfrtip',
        buttons = c('csv'),  # Solo dejar el botón CSV
        language = list(
          search = "Buscar:",
          lengthMenu = "Mostrar _MENU_ registros por página",
          info = "Mostrando _START_ a _END_ de _TOTAL_ registros",
          paginate = list(
            first = "Primero",
            last = "Último",
            siguiente = "Siguiente",
            anterior = "Anterior"
          )
        ),
        columnDefs = columnDefs
      ),
      extensions = 'Buttons',
      selection = 'none',
      filter = 'top',
      rownames = FALSE
    )
  })
  
  #--------------------------------------------------
  # ! Resetear filtros de la tabla final
  #--------------------------------------------------
  
  observeEvent(input$reset_filtros_tabla_final, {
    # Restablecer fecha a valores predeterminados
    updateDateRangeInput(session, "fecha_nueva_tabla",
                        start = ultima_fecha_tabla_final - 1,
                        end = ultima_fecha_tabla_final)
    
    # Restablecer rango de horas
    updateSliderInput(session, "hora_nueva_tabla",
                     value = c(7, 19))
    
    # Restablecer selección de placas
    updateSelectizeInput(session, "placa_nueva_tabla",
                        selected = NULL)
    
    showNotification(
      "Filtros reseteados correctamente",
      type = "message",
      duration = 3
    )
  })
  
}