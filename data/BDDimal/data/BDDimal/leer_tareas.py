import requests
import pandas as pd
from io import BytesIO

# URL directa del archivo Tareas.xlsm en OneDrive (ajústala si cambia el enlace)
url_tareas = "https://dimalsrl-my.sharepoint.com/:x:/g/personal/adrianmato_dimalsrl_onmicrosoft_com/EWHNUp2277lGolzmK5zhwd0BLEPWXjtODDwMBRx0HocXhw?e=bEpGIo"

def leer_tareas():
    try:
        print("Descargando archivo Tareas.xlsm desde OneDrive...")
        response = requests.get(url_tareas)
        response.raise_for_status()
        excel_data = BytesIO(response.content)
        
        # Si el archivo tiene varias hojas, podés listar los nombres:
        xls = pd.ExcelFile(excel_data)
        print("Hojas disponibles:", xls.sheet_names)
        
        # Leer la primera hoja por defecto
        df_tareas = pd.read_excel(xls, sheet_name=0)
        print("Archivo cargado correctamente ✅")
        return df_tareas

    except Exception as e:
        print("Error al leer el archivo desde OneDrive ❌")
        print(e)
        return None

if __name__ == "__main__":
    df = leer_tareas()
    if df is not None:
        print(df.head())
