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
    local sync_info="$1"
    local source="${sync_info%%|*}"     # Extraer SOURCE
    local destination="${sync_info#*|}"  # Extraer DESTINATION
    
    log_message "INFO" "Iniciando sincronización"
    log_message "INFO" "Desde: $source"
    log_message "INFO" "Hacia: $destination"
    
    # Construir el comando base
    local rclone_cmd="rclone sync \
    "$source" \
    "$destination" \
    --progress \
    --transfers=4 \
    --checkers=8 \
    $RCLONE_EXTRA_ARGS"
    
    # Añadir --dry-run si DRY_RUN es TRUE
    if [ "$DRY_RUN" = "TRUE" ]; then
        rclone_cmd="$rclone_cmd --dry-run"
    fi
    
    # Ejecutar el comando rclone
    eval $rclone_cmd
    
    # Verificar el estado de la última ejecución
    if [ $? -eq 0 ]; then
        log_message "info" "Sincronización completada exitosamente"
    else
        log_message "error" "Error durante la sincronización"
    fi
}

# Recorrer cada tarea de sincronización
for sync_info in "${SHARED_DRIVES[@]}"; do
    sync_drive "$sync_info"
done