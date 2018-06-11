#!/bin/bash

set -u

if [[ $# -ne 2 ]]; then
    printf "usage: %s FILE DEST\\n" "$(basename "$0")"
    exit 1
fi

FILE=$1
DEST=$2

TMP_DIR=$(mktemp -d -p "$SCRATCH")

cd "$TMP_DIR" || exit

wget -nv "$FILE"

iput -f "$(basename "$FILE")" "$DEST"

rm -rf "$TMP_DIR"
