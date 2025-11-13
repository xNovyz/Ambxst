#!/usr/bin/env bash
# Wrapper para ejecutar ambxst-auth con contraseña desde stdin
# Uso: PAM_PASSWORD="password" PAM_USER="username" ./ambxst-auth-stdin.sh

set -e

if [ -z "$PAM_USER" ]; then
    echo "Error: PAM_USER no definido" >&2
    exit 100
fi

SCRIPT_DIR="$(dirname "$0")"

# Buscar el binario ambxst-auth en varias ubicaciones posibles
if [ -x "$SCRIPT_DIR/ambxst-auth" ]; then
    AMBXST_AUTH="$SCRIPT_DIR/ambxst-auth"
elif command -v ambxst-auth >/dev/null 2>&1; then
    AMBXST_AUTH="ambxst-auth"
else
    echo "Error: No se encuentra el binario ambxst-auth" >&2
    exit 102
fi

# Pasar la contraseña al binario PAM
printf '%s\n' "$PAM_PASSWORD" | "$AMBXST_AUTH" "$PAM_USER"
