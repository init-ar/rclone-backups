### README.md

## Descripción del Script

Este script de Bash está diseñado para sincronizar datos desde unidades compartidas de Google Drive a un directorio local específico. Utiliza la herramienta `rclone` para realizar la sincronización y registra el progreso y los resultados en un archivo de log.

## Requisitos

### Para Google Drive

1. **Crear un Proyecto en Google Cloud Platform (GCP)**:
   - Accede a [Google Cloud Console](https://console.cloud.google.com/).
   - Crea un nuevo proyecto.
   - Habilita la API de Google Drive para tu proyecto.

2. **Configurar `rclone`**:
   - La configuración inicial para Google Drive implica obtener un token que necesitas hacer en tu navegador. `rclone config` te guiará a través de este proceso.
   - Para más detalles sobre cómo configurar `rclone` para Google Drive, consulta la [documentación oficial de rclone](https://rclone.org/drive/).

### Para OneDrive

- **Requisitos**: Si deseas sincronizar con OneDrive, necesitarás configurar `rclone` para acceder a tu cuenta de OneDrive. Esto también se puede hacer a través de `rclone config`, donde deberás seleccionar OneDrive como tipo de almacenamiento y seguir las instrucciones para autenticarte. Para más información, consulta la [documentación oficial de rclone para OneDrive](https://rclone.org/onedrive/).

## Variables de Configuración

- `LOG_FILE`: Ruta del archivo donde se registrarán los mensajes de log. Por defecto, está configurado en `/var/log/rclone_log.txt`.
- `DESTINATION`: Ruta del directorio local donde se sincronizarán los datos. Configurar la ruta deseada.
- `REMOTE`: El nombre del remoto de `rclone` que se utilizará para la sincronización. Cambiar por el nombre del remote configurado previamente en `rclone`.

## Unidades Compartidas

El script utiliza un array llamado `SHARED_DRIVES` que debe contener los nombres y IDs de las unidades compartidas en el formato `nombre-de-drive:ID-del-drive`. Puedes agregar o modificar las unidades compartidas según sea necesario.

## Funciones

- `log_message`: Registra mensajes en el archivo de log con una marca de tiempo y el tipo de mensaje (INFO o ERROR).
- `sync_drive`: Sincroniza una unidad compartida específica utilizando `rclone`. Crea el directorio de destino si no existe y registra el estado de la sincronización.

## Ejecución

Para ejecutar el script, asegúrate de que tienes los permisos necesarios y que `rclone` está correctamente configurado. Luego, puedes ejecutar el script con el siguiente comando:

    ./nombre_del_script.sh

Asegúrate de reemplazar `nombre_del_script.sh` con el nombre real del archivo del script.

## Ejemplo de Uso

1. Modifica el array `SHARED_DRIVES` para incluir las unidades que deseas sincronizar.
2. Ajusta las variables `LOG_FILE`, `DESTINATION` y `REMOTE` si es necesario.
3. Ejecuta el script y verifica el archivo de log para ver el progreso y los resultados de la sincronización.

---