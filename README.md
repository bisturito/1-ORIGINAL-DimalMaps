# 1-ORIGINAL-DimalMaps

Repositorio de datos para el Sistema de Distribución Dimal SRL - Uruguay.

## Descripción

Este repositorio contiene los archivos de datos que alimentan la aplicación de gestión de distribución y visualización de clientes en mapa.

## Estructura del Repositorio
data/
├── Limpia/ # Datos procesados y listos para uso
│ ├── Ubicaciones_direcciones.xlsx # Base de clientes con coordenadas GPS
│ ├── Tabla_Proyectos_Clientes.xlsx # Relación proyectos-clientes
│ ├── Tareas-limpio.xlsx # Historial de tareas/visitas
│ ├── lugares_pago.xlsx # Ubicaciones de lugares de pago
│ └── ubi_empresa.xlsx # Ubicaciones de la empresa
│
├── BDDimal/ # Scripts de base de datos
└── 0_ETL/ # Procesos ETL


## Archivos de Datos Principales

### 📍 Ubicaciones_direcciones.xlsx
Base de datos principal de clientes (~ registros).

| Campo | Descripción |
|-------|-------------|
| CODCLI2 | Código único del cliente |
| NOMBRE | Nombre del cliente |
| LATITUD/LONGITUD | Coordenadas GPS |

### 📋 Tabla_Proyectos_Clientes.xlsx
Relación proyectos-clientes (~1,210 registros, 29 proyectos).

### 📝 Tareas-limpio.xlsx
Historial de visitas (~9,998 registros).

### 💳 lugares_pago.xlsx / 🏢 ubi_empresa.xlsx
Puntos de pago (~30) y ubicaciones empresa (~6).

## Aplicación Web

**Repositorio de la app:** [Bisturito/mi-app](https://github.com/Bisturito/1-ORIGINAL-DimalMaps)
**APP Online** https://dimalsrl.com/mapa  
**Redirección** https://mapas-distribucion-maragdestefanis.replit.app/ 

---

**Última actualización:** Noviembre 2025
