#!/usr/bin/env bash
# Wrapper para ejecutar pam-auth con contraseña desde stdin
# Uso: PAM_PASSWORD="password" PAM_USER="username" ./pam-auth-stdin.sh

set -e

if [ -z "$PAM_USER" ]; then
    echo "Error: PAM_USER no definido" >&2
    exit 100
fi

SCRIPT_DIR="$(dirname "$0")"

# Pasar la contraseña al binario PAM
printf '%s\n' "$PAM_PASSWORD" | "$SCRIPT_DIR/pam-auth" "$PAM_USER"
