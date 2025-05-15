#!/bin/bash

# Variables de configuración
LOG_FILE="/var/log/rclone_log.txt"  # Archivo de log
DESTINATION="/path/to/destination"   # Carpeta de destino
REMOTE="remote-name"                     # Remote de rclone (sin los dos puntos)

# Array de Shared Drives con nombres reconocibles
SHARED_DRIVES=(
  "name-de-drive:ID-del-drive"
  "name-de-drive2:ID-del-drive2"
)

# Función para registrar mensajes en el log
log_message() {
    local message_type="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$message_type] $message" >> "$LOG_FILE"
}

# Función para sincronizar el drive
sync_drive() {
    local drive_info="$1"
    local drive_name="${drive_info%%:*}"  # Extraer el nombre del drive
    local drive_id="${drive_info##*:}"      # Extraer el ID del drive
    local drive_destination="$DESTINATION$drive_name/"  # Carpeta de destino específica para el drive

    # Verificar si la carpeta de destino existe, si no, crearla
    if [ ! -d "$drive_destination" ]; then
        mkdir -p "$drive_destination"
        log_message "INFO" "Carpeta creada: $drive_destination"
    fi

    log_message "INFO" "Iniciando sincronización para el ID de Drive: $drive_name ($drive_id)"
    
    # Ejecutar el comando rclone
    rclone sync "$REMOTE:" --drive-team-drive "$drive_id" "$drive_destination" --progress --transfers=4 --checkers=8 --drive-acknowledge-abuse
    
    # Verificar el estado de la última ejecución
    if [ $? -eq 0 ]; then
        log_message "INFO" "Sincronización completada exitosamente para el ID: $drive_name ($drive_id)"
    else
        log_message "ERROR" "Error durante la sincronización para el ID: $drive_name ($drive_id)"
    fi
}

# Recorrer cada Shared Drive y sincronizar
for drive_info in "${SHARED_DRIVES[@]}"; do
    sync_drive "$drive_info"
done
