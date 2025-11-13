#!/usr/bin/env bash
# Compiles the PAM authentication binary for the lockscreen

set -e

cd "$(dirname "$0")"

echo "Compiling pam-auth..."
gcc -o pam-auth auth.c -lpam -Wall -Wextra -O2

echo "✓ Binary compiled: modules/lockscreen/pam-auth"
echo ""
echo "IMPORTANT: The binary must run with permissions for PAM."
echo "For local testing it may work directly."
echo "For production, consider configuring sudo or capabilities for your system."
