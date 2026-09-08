#!/bin/bash

# Cargar configuración desde archivo externo
source "$(dirname "$0")/rclone.config" || exit 1


# ============================================================
# Función para registrar mensajes en el log
# ============================================================

log_message() {
    local message_type="$1"
    local message="$2"

    echo "$(date '+%Y-%m-%d %H:%M:%S') [$message_type] $message" >> "$LOG_FILE"
}


# ============================================================
# Función de sincronización
# ============================================================

sync_drive() {

    local sync_info="$1"
    local source="${sync_info%%|*}"
    local destination="${sync_info#*|}"

    log_message "INFO" "Iniciando sincronización"
    log_message "INFO" "Desde: $source"
    log_message "INFO" "Hacia: $destination"

    # Construir comando rclone
    local rclone_cmd="rclone sync \
    \"$source\" \
    \"$destination\" \
    $RCLONE_OPTIONS"

    # Añadir --dry-run si DRY_RUN es TRUE
    if [ "$DRY_RUN" = "TRUE" ]; then
        rclone_cmd="$rclone_cmd --dry-run"
    fi

    # Ejecutar comando
    eval $rclone_cmd >> "$LOG_FILE" 2>&1

    # Verificar resultado
    if [ $? -eq 0 ]; then
        log_message "INFO" "Sincronización completada exitosamente"
    else
        log_message "ERROR" "Error durante la sincronización"
        exit 1
    fi
}


# ============================================================
# Función de retención de backups TAR
# ============================================================

cleanup_old_backups() {

    local destination="$1"
    local folder_name="$2"

    local pattern
    local backups
    local backup_count
    local oldest_backup

    # Solo considerar archivos:
    # carpeta-YYYY-MM-DD-HHMMSS.tar
    pattern="^${folder_name}-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}\.tar$"

    log_message "INFO" "Verificando retención de backups"

    backups=$(rclone lsf "$destination" --files-only 2>> "$LOG_FILE" |
        grep -E "$pattern" |
        sort)

    if [ $? -ne 0 ]; then
        log_message "ERROR" "No se pudo listar los backups remotos"
        exit 1
    fi

    backup_count=$(printf '%s\n' "$backups" | grep -c .)

    log_message "INFO" "Backups encontrados: $backup_count"
    log_message "INFO" "Copias a conservar: $RETENTION_COPIES"

    # No hacer nada si no se supera el límite
    if [ "$backup_count" -le "$RETENTION_COPIES" ]; then
        log_message "INFO" "No es necesario eliminar backups"
        return 0
    fi

    # El primer archivo ordenado es el más viejo
    oldest_backup=$(printf '%s\n' "$backups" | head -n 1)

    log_message "INFO" "Eliminando backup más viejo: $oldest_backup"

    rclone deletefile \
        "$destination/$oldest_backup" \
        >> "$LOG_FILE" 2>&1

    if [ $? -ne 0 ]; then
        log_message "ERROR" "No se pudo eliminar el backup: $oldest_backup"
        exit 1
    fi

    log_message "INFO" "Backup antiguo eliminado correctamente"
}


# ============================================================
# Función de backup TAR
# ============================================================

tar_drive() {

    local sync_info="$1"
    local source="${sync_info%%|*}"
    local destination="${sync_info#*|}"

    local folder_name
    local timestamp
    local tar_file
    local rclone_cmd

    # Obtener nombre de la carpeta
    folder_name="$(basename "$source")"

    # Timestamp del backup
    timestamp="$(date '+%Y-%m-%d-%H%M%S')"

    # Nombre del archivo TAR
    tar_file="$TAR_PATH/${folder_name}-${timestamp}.tar"

    log_message "INFO" "Iniciando backup TAR"
    log_message "INFO" "Desde: $source"
    log_message "INFO" "Hacia: $destination"
    log_message "INFO" "Archivo TAR: $tar_file"


    # --------------------------------------------------------
    # Crear TAR
    # --------------------------------------------------------

    log_message "INFO" "Creando archivo TAR"

    tar -cf "$tar_file" \
        -C "$(dirname "$source")" \
        "$folder_name" \
        >> "$LOG_FILE" 2>&1

    if [ $? -ne 0 ]; then
        log_message "ERROR" "Error al crear el archivo TAR"
        exit 1
    fi

    log_message "INFO" "Archivo TAR creado correctamente"


    # --------------------------------------------------------
    # DRY RUN
    # --------------------------------------------------------

    if [ "$DRY_RUN" = "TRUE" ]; then

        log_message "INFO" "DRY_RUN habilitado"
        log_message "INFO" "No se realizará la copia remota"
        log_message "INFO" "El archivo TAR se conserva: $tar_file"

        return 0
    fi


    # --------------------------------------------------------
    # Copiar TAR al remoto
    # --------------------------------------------------------

    log_message "INFO" "Iniciando copia del TAR"

    rclone_cmd="rclone copy \
    \"$tar_file\" \
    \"$destination\" \
    $RCLONE_OPTIONS"

    eval $rclone_cmd >> "$LOG_FILE" 2>&1

    if [ $? -ne 0 ]; then

        log_message "ERROR" "Error durante la copia del archivo TAR"
        log_message "ERROR" "El archivo TAR se conserva: $tar_file"

        exit 1
    fi

    log_message "INFO" "Backup copiado correctamente"


    # --------------------------------------------------------
    # Eliminar TAR temporal
    # --------------------------------------------------------

    rm -f "$tar_file"

    if [ $? -ne 0 ]; then
        log_message "ERROR" "No se pudo eliminar el archivo TAR temporal: $tar_file"
        exit 1
    fi

    log_message "INFO" "Archivo TAR temporal eliminado"


    # --------------------------------------------------------
    # Retención
    # --------------------------------------------------------

    cleanup_old_backups "$destination" "$folder_name"

    log_message "INFO" "Backup TAR finalizado correctamente"
}


# ============================================================
# Ejecutar las tareas configuradas
# ============================================================

for sync_info in "${SHARED_DRIVES[@]}"; do

    if [ "$BACKUP_MODE" = "SYNC" ]; then

        sync_drive "$sync_info"

    elif [ "$BACKUP_MODE" = "TAR" ]; then

        tar_drive "$sync_info"

    else

        log_message "ERROR" "BACKUP_MODE no reconocido: $BACKUP_MODE"
        exit 1

    fi

done