#!/usr/bin/env bash
# Insert clipboard item into database
# Usage: clipboard_insert.sh <db_path> <hash> <mime_type> <is_image> <binary_path>
# Content is read from stdin

set -euo pipefail

DB_PATH="$1"
HASH="$2"
MIME_TYPE="$3"
IS_IMAGE="$4"
BINARY_PATH="$5"

# Read content from stdin
CONTENT=$(cat)

# Create preview
if [ "$IS_IMAGE" = "1" ]; then
    PREVIEW="[Image]"
elif [ ${#CONTENT} -gt 100 ]; then
    PREVIEW="${CONTENT:0:97}..."
else
    PREVIEW="$CONTENT"
fi

# Get timestamp in milliseconds
TIMESTAMP=$(date +%s)000

# Escape single quotes by replacing ' with ''
ESCAPED_PREVIEW="${PREVIEW//\'/\'\'}"
ESCAPED_CONTENT="${CONTENT//\'/\'\'}"

sqlite3 "$DB_PATH" <<EOSQL
INSERT OR REPLACE INTO clipboard_items 
(content_hash, mime_type, preview, full_content, is_image, binary_path, created_at, updated_at) 
VALUES ('$HASH', '$MIME_TYPE', '$ESCAPED_PREVIEW', '$ESCAPED_CONTENT', $IS_IMAGE, '$BINARY_PATH', $TIMESTAMP, $TIMESTAMP);
EOSQL
