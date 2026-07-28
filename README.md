# README.md

## Descripción del Script

Este script de Bash está diseñado para sincronizar datos entre carpetas locales y/o remotos configurados en `rclone`. Utiliza la herramienta `rclone` para realizar la sincronización y registra el progreso y los resultados en un archivo de log.

## Requisitos

### Configuración de `rclone`

Antes de utilizar el script, es necesario tener instalado y configurado `rclone`.

Cada proveedor de almacenamiento tiene su propio procedimiento de configuración mediante:

```bash
rclone config
```

La documentación oficial de cada backend puede consultarse en:

https://rclone.org/

### Google Drive

Para utilizar Google Drive:

1. Crear un proyecto en Google Cloud Platform (GCP).
2. Habilitar la API de Google Drive.
3. Configurar el remote mediante `rclone config`.

Más información:

https://rclone.org/drive/

### OneDrive

Para utilizar OneDrive, configurar el remote mediante `rclone config` siguiendo la documentación oficial:

https://rclone.org/onedrive/

### Otros proveedores

El script puede utilizar cualquier backend soportado por `rclone` (WebDAV, S3, Dropbox, Proton Drive, SMB, almacenamiento local, etc.), siempre que el remote haya sido configurado previamente mediante `rclone config`.

## Variables de Configuración

Crear un archivo `rclone.config` utilizando como base `rclone.config.example`.

Las variables disponibles son:

- **LOG_FILE**: Ruta del archivo donde se registrarán los mensajes del script.
- **DRY_RUN**: Se recomienda mantener el valor `TRUE` durante las pruebas para verificar las acciones que realizará `rclone` sin efectuar cambios.
- **RCLONE_OPTIONS**: Permite definir las opciones que se pasarán al comando `rclone sync`. Estas opciones dependen del proveedor utilizado y de los requerimientos de la sincronización.

Ejemplo para Google Drive:

```text
RCLONE_OPTIONS="\
--progress \
--transfers=4 \
--checkers=8 \
--drive-acknowledge-abuse"
```

Ejemplo para LiveDrive:

```text
RCLONE_OPTIONS="\
--progress \
--transfers=4 \
--checkers=8 \
--retries=5 \
--low-level-retries=20 \
--timeout=5m \
--contimeout=30s \
--stats=60s \
--stats-one-line"
```

- **SHARED_DRIVES**: Array que define las tareas de sincronización.

Formato:

```text
"ORIGEN|DESTINO"
```

Ejemplos:

```text
"remote1:|/backup/local"
"/datos|onedrive:Backup"
"gdrive:Empresa|livedrive:Empresa"
```

El origen y el destino pueden ser indistintamente una carpeta local o un remote configurado en `rclone`.

> **Importante:** `rclone sync` elimina del destino los archivos que no existen en el origen. Se recomienda realizar las primeras ejecuciones con `DRY_RUN="TRUE"`.

## Unidades Compartidas de Google Drive

Si se utilizan Unidades Compartidas (Shared Drives), cada una debe configurarse como un remote independiente de tipo `team-drive` mediante `rclone config`.

## Funciones

- **log_message**: Registra mensajes en el archivo de log con fecha, hora y tipo de mensaje.
- **sync_drive**: Ejecuta una tarea de sincronización utilizando `rclone sync`.

## Ejecución

Una vez configurado `rclone` y creado el archivo `rclone.config`, ejecutar:

```bash
./rclone.sh
```

## Ejemplo de Uso

1. Crear el archivo `rclone.config` a partir de `rclone.config.example`.
2. Configurar `RCLONE_OPTIONS` según el proveedor utilizado.
3. Configurar el array `SHARED_DRIVES`.
4. Mantener `DRY_RUN="TRUE"` durante las pruebas.
5. Ejecutar el script.
6. Revisar el archivo de log para verificar el resultado de la sincronización.