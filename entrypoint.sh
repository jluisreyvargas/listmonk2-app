#!/bin/sh
set -eu

CONFIG=/tmp/config.toml

: "${DB_HOST:?Missing DB_HOST}"
: "${DB_PORT:=5432}"
: "${DB_NAME:?Missing DB_NAME}"
: "${DB_USER:?Missing DB_USER}"
: "${DB_PASSWORD:?Missing DB_PASSWORD}"

: "${LISTMONK_ADMIN_USER:=admin}"
: "${LISTMONK_ADMIN_PASSWORD:=changeme}"

: "${LISTMONK_APP_ADDRESS:=0.0.0.0:9000}"
: "${LISTMONK_APP_ROOT_URL:=http://listmonk.local/}"

cat > "$CONFIG" <<EOF2
[app]
address = "${LISTMONK_APP_ADDRESS}"
root_url = "${LISTMONK_APP_ROOT_URL}"

[db]
host = "${DB_HOST}"
port = ${DB_PORT}
user = "${DB_USER}"
password = "${DB_PASSWORD}"
database = "${DB_NAME}"
ssl_mode = "disable"
max_open = 25
max_idle = 25
max_lifetime = "300s"

# Solo se importa en la primera instalación (y en upgrades antiguos)
admin_username = "${LISTMONK_ADMIN_USER}"
admin_password = "${LISTMONK_ADMIN_PASSWORD}"
EOF2

# Ejecuta el binario tal cual lo recibe CMD.
exec "$@"
