# rclone-backups
Script para descargar y empaquetar archivos de la nube

En el script, modificar estas variables:

# Variables de configuración
LOG_FILE="ruta/al/log"  # Archivo de log
DESTINATION="/ruta/a/carpeta/local/"   # Carpeta de destino

Para completar estas variables, es neceario ya tener configurado el remote de rclone (Ver documentación oficial para esto)

El comando a usar es:

rclone backend drives init-test:

Devuelve estos datos, usar ID y name según corresponda:

[
	{
		"id": "0AIGBJMf6M_XTUk9PVA",
		"kind": "drive#teamDrive",
		"name": "INIT"
	},
	{
		"id": "0AHBlLtOeW2ftUk9PVA",
		"kind": "drive#teamDrive",
		"name": "Soporte"
	},
	{
		"id": "0ANMk3V85rrRkUk9PVA",
		"kind": "drive#teamDrive",
		"name": "SysAdmin"
	}
]


# Array de Shared Drives con nombres reconocibles
SHARED_DRIVES=(
  "Soporte:0AHBlLtOeW2ftUk9PVA"
  "Sysadmin:0ANMk3V85rrRkUk9PVA"
)