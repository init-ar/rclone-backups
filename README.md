### README.md

## Descripción del Script

Este script de Bash está diseñado para sincronizar datos de unidades compartidas de Google Drive y carpetas lcoales . Utiliza la herramienta `rclone` para realizar la sincronización y registra el progreso y los resultados en un archivo de log.

## Requisitos

### Para Google Drive

1. **Crear un Proyecto en Google Cloud Platform (GCP)**:
   - Accede a [Google Cloud Console](https://console.cloud.google.com/).
   - Crea un nuevo proyecto.
   - Habilita la API de Google Drive para tu proyecto.

2. **Configurar `rclone`**:
   - La configuración inicial para Google Drive implica obtener un token que necesitas hacer en tu navegador. `rclone config` te guiará a través de este proceso.
   - Para más detalles sobre cómo configurar `rclone` para Google Drive, consulta la [documentación oficial de rclone](https://rclone.org/drive/).

### Para OneDrive --> FALTA TESTEO

- **Requisitos**: Si deseas sincronizar con OneDrive, necesitarás configurar `rclone` para acceder a tu cuenta de OneDrive. Esto también se puede hacer a través de `rclone config`, donde deberás seleccionar OneDrive como tipo de almacenamiento y seguir las instrucciones para autenticarte. Para más información, consulta la [documentación oficial de rclone para OneDrive](https://rclone.org/onedrive/).

## Variables de Configuración

Crear un archivo "rclone.config", usar el archivo de ejemplo para modificar las variables.
- `LOG_FILE`: Ruta del archivo donde se registrarán los mensajes de log. Por defecto, está configurado en `/var/log/rclone_log.txt`.
- `DRY_RUN`: Recomendado probar primero con el parámetro en TRUE, para chequear cuáles son los cambios que se harían antes de aplicar.
- `SHARED_DRIVES`: En este array se configuran los parámetros de origen y destino de datos, con un separador |, primero el origen y luego el destino, cada remote ya debe estar previamente configurado en rclone como "team-drive". Probar primero con DRY_RUN en TRUE ya que al sincronizar se borran los datos que no existen en el origen. 

## Unidades Compartidas

Para sincronizar unidades compartidas, es necesario configurar cada unidad como un remote "team-drive". Por cada unidad compartida se debe configurar un remote.

## Funciones

- `log_message`: Registra mensajes en el archivo de log con una marca de tiempo y el tipo de mensaje (INFO o ERROR).
- `sync_drive`: Sincroniza una unidad compartida específica utilizando `rclone`. Crea el directorio de destino si no existe y registra el estado de la sincronización.

## Ejecución

Para ejecutar el script, asegúrate de que tienes los permisos necesarios y que `rclone` está correctamente configurado. Luego, puedes ejecutar el script con el siguiente comando:

    ./rclone.sh

## Ejemplo de Uso

1. Modifica el array `SHARED_DRIVES` para incluir las unidades que deseas sincronizar.
2. Ajusta la variable `LOG_FILE` si es necesario, `DRY_RUN` viene por defecto en TRUE, poner en false para producción.
3. Ejecuta el script y verifica el archivo de log para ver el progreso y los resultados de la sincronización.

---