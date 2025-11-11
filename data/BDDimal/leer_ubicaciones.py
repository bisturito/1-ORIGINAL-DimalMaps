import pandas as pd

# ============================================================
# Script: leer_ubicaciones.py
# Descripción: Lee el archivo Ubicaciones.xlsx alojado en OneDrive/SharePoint
# ============================================================

# URL pública o compartida del archivo de OneDrive/SharePoint
url_compartida = "https://dimalsrl-my.sharepoint.com/:x:/g/personal/adrianmato_dimalsrl_onmicrosoft_com/EaQJY8CUKy9KlRV5GA6v2bIBzoi5VT1h2d7jhcYP1ZgBgQ?e=Sggm1Q"

# 💡 IMPORTANTE:
# Para que pandas pueda leer directamente, necesitás convertir la URL compartida
# en un enlace de descarga directa. OneDrive no lo da por defecto.
# Podés hacerlo reemplazando la parte final por:
# "?download=1"
# o generando un enlace directo desde el menú "Compartir" → "Copiar vínculo directo"

# Ejemplo (si tenés el enlace directo):
# url_directa = "https://dimalsrl-my.sharepoint.com/personal/.../Ubicaciones.xlsx?download=1"

# Por ahora lo leeremos localmente o desde descarga temporal:
# Si el archivo ya está en tu carpeta local sincronizada con OneDrive:
ruta_local = "C:/Users/adrianmato/OneDrive - dimalsrl/BDDimal/Ubicaciones.xlsx"

try:
    df = pd.read_excel(ruta_local)
    print("✅ Archivo cargado correctamente:")
    print(df.head())
except Exception as e:
    print("⚠️ No se pudo cargar el archivo. Error:")
    print(e)
