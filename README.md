# 🚚 Bisturito Maps - Sistema de Visualización y Análisis de Rutas

## 📋 Descripción General
Bisturito Maps es una aplicación Shiny diseñada para la visualización y análisis de rutas de camiones de la Distribuidora Dimal. Su objetivo principal es optimizar la distribución mediante herramientas interactivas y análisis predictivo.

## 🎯 Funcionalidades Principales

### 1️⃣ Mapa Interactivo 🗺️- **Control de Capas:**
  - 📍 Botón "Capas del Mapa" con diseño moderno
  - 🛣️ Vista de Calles
  - 🛰️ Vista Satélite
  - 💰 Lugares de Pago
  - 🏢 Ubicaciones de Empresa
  - 👥 Lista completa de clientes (oculta por defecto)

- **Filtros Dinámicos:**
  - 📅 Selector de rango de fechas
  - 🚛 Selector de placas de camiones
  - 📍 Opción de mostrar/ocultar clientes
  - ⏱️ Opción de mostrar/ocultar demoras de camiones

- **Visualización personalizada:**
  - 🎯 Marcadores únicos por tipo de ubicación.
  - 📍⏱️Rutas y paradas con detalles de tiempos y demoras

### 2️⃣ Estadísticas 📊
- 📈 Gráficos interactivos de rendimiento
- ⏱️ Análisis de tiempos de entrega
- 📊 Visualización de datos históricos

### 3️⃣ Gestión de Datos 📋

#### Estacionados Camión 🚛
- 📍 Ubicaciones de estacionamiento
- ⏱️ Tiempos de parada
- 📊 Análisis de demoras

#### Proyectos Clientes 👥
- 💼 Gestión y Categorización de proyectos

#### Predictivo Cliente-Camión 📊
- ⏱️ Optimización de rutas y estimación de tiempos

## 🛠️ Características del Sistema

### 🔄 Sistema de Logs y Monitoreo
- 📝 Registro detallado de eventos y errores
- ⚠️ Sistema de validación de datos
- 🔍 Monitoreo de carga de archivos
- 📊 Registro de uso del sistema

### 🎨 Personalización y Temas
- 🌙 Modo nocturno/claro integrado
- ⏰ Reloj en tiempo real
- 🎯 Configuración personalizada de mapas
- 📱 Diseño responsive

### ⚙️ Configuración Avanzada
- 🗺️ Coordenadas y zoom personalizables
- 📦 Gestión de dependencias CRAN
- 🔒 Validación de archivos y datos
- 💾 Estructura de logs organizada

## 📁 Estructura del Proyecto

### 📂 Carpetas Principales
- `📂 data`: Datos del sistema
  - `📂 0_ETL`: Procesamiento y transformación de datos
  - `📂 Limpia`: Datos procesados y validados
  - `📂 Safetrack`: Datos del sistema de seguimiento
  - `📂 Sucia`: Datos sin procesar
- `📂 logs`: Registros del sistema
- `📂 www`: Recursos web (CSS, JS, imágenes)
- `📂 rsconnect`: Configuración de despliegue
- `📂 .venv`: Entorno virtual de Python

### 📂 Archivos de la Aplicación
- `app.R`: Punto de entrada de la aplicación
- `global.R`: Configuración global y carga de datos
- `ui.R`: Interfaz de usuario
- `server.R`: Lógica del servidor
- `CONFIG.R`: Configuraciones de entorno (desarrollo/producción)
- `config_prod.R`: Configuraciones específicas de producción
- `init.R`: Inicialización del sistema
- `logger.R`: Sistema de logging para monitoreo

### 📂 Archivos de Configuración
- `.gitignore`: Control de versiones Git
- `.windsurfignore`: Configuración de Windsurf
- `requirements.txt`: Dependencias del proyecto

### 📝 Archivos de Registro
- `diagnostico_datos.log`: Registro de diagnóstico y validación de datos

## 📊 Estructura de Datos

### 1️⃣ Organización de Datos
#### 📂 0_ETL
- Scripts y procesos de transformación
- Validación de datos de entrada

#### 📂 Limpia
- Datos procesados y validados
- Archivos listos para análisis

#### 📂 Safetrack
- Datos de seguimiento de vehículos
- Registros de GPS y rutas

#### 📂 Sucia
- Datos sin procesar
- Archivos de entrada originales

## 🔧 Instalación y Configuración

### Requisitos Previos 📋
- R (versión recomendada: 4.0.0 o superior)
- RStudio (opcional pero recomendado)
- Python (para entorno virtual)
- Extensión Better Comments para VS Code

### Configuración del Entorno 🛠️
1. Clonar el repositorio
2. Crear y activar entorno virtual:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate
   ```
3. Instalar dependencias:
   ```bash
   pip install -r requirements.txt
   ```
4. Configurar el entorno R:
   ```R
   source("init.R")
   source("CONFIG.R")
   ```

## 📈 Recomendaciones futuras

### Sistema de Logging Mejorado
- Implementar logs detallados para:
  - 🔍 Acciones del usuario
  - ⚠️ Errores y excepciones
  - 📊 Rendimiento del sistema
  - 🔄 Operaciones de datos


### Optimización de Rendimiento
- Mejoras en consultas de datos:
  - 💾 Implementar caching
  - 🔍 Optimizar filtros
  - 📊 Reducir duplicación
  - ⚡ Mejorar tiempos de respuesta

## Futuras Mejoras

### Visualización de Rutas de Camiones
- [ ] Implementar trazado de rutas para cada camión
- [ ] Agregar control para mostrar/ocultar rutas
- [ ] Colorear rutas según el camión
- [ ] Agregar animación del recorrido
- [ ] Implementar flechas direccionales
- [ ] Agregar estadísticas de recorrido (distancia, tiempo, paradas)

Detalles de implementación:
```r
# Requerirá:
library(leaflet)
library(leaflet.extras)  # Para animaciones

# Principales funciones a utilizar:
# - addPolylines() para trazar rutas
# - addArrows() para dirección
# - addPlayback() para animación

```
