from leer_ubicaciones import leer_ubicaciones
from leer_tareas import leer_tareas

def actualizar_datos():
    df_ubicaciones = leer_ubicaciones()
    df_tareas = leer_tareas()

    # Guardar los datasets localmente en el repo (por ejemplo en data/Sucia/)
    if df_ubicaciones is not None:
        df_ubicaciones.to_excel("data/Sucia/Ubicaciones.xlsx", index=False)
        print("✅ Ubicaciones.xlsx actualizado")

    if df_tareas is not None:
        df_tareas.to_excel("data/Sucia/Tareas.xlsx", index=False)
        print("✅ Tareas.xlsx actualizado")

if __name__ == "__main__":
    actualizar_datos()
