#!/bin/bash

# Cargar configuración desde archivo externo
source "$(dirname "$0")/rclone.config" || exit 1

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
    
    log_message "INFO" "Iniciando sincronización para el ID de Drive: $drive_name ($drive_id)"
    log_message "INFO" "Desde: $SOURCE"
    log_message "INFO" "Hacia: $DESTINATION"
    
    # Construir el comando base
    local rclone_cmd="rclone sync \"$SOURCE\" \"$DESTINATION\" --drive-team-drive \"$drive_id\" --progress --transfers=4 --checkers=8 --drive-acknowledge-abuse"
    
    # Añadir --dry-run si DRY_RUN es TRUE
    if [ "$DRY_RUN" = "TRUE" ]; then
        rclone_cmd="$rclone_cmd --dry-run"
    fi
    
    # Ejecutar el comando rclone
    eval $rclone_cmd
    
    # Verificar el estado de la última ejecución
    if [ $? -eq 0 ]; then
        log_message "info" "Sincronización completada exitosamente para el ID: $drive_name ($drive_id)"
    else
        log_message "error" "Error durante la sincronización para el ID: $drive_name ($drive_id)"
    fi
}

# Recorrer cada Shared Drive y sincronizar
for drive_info in "${SHARED_DRIVES[@]}"; do
    sync_drive "$drive_info"
done