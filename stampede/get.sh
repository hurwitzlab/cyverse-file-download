#!/bin/bash

set -u

if [[ $# -ne 3 ]]; then
    printf "usage: %s FILE DEST UNCOMPRESS\\n" "$(basename "$0")"
    exit 1
fi

FILE=$1
DEST=$2
UNCOMPRESS=$3

TMP_DIR=$(mktemp -d -p "$SCRATCH")

cd "$TMP_DIR" || exit

wget -nv "$FILE"

LOCAL=$(basename "$FILE")

if [[ $UNCOMPRESS -gt 0 ]]; then
    EXT=${LOCAL##*.}

    if [[ "$LOCAL" =~ .*\.(tar.gz|tar.bz|tgz|tar)$ ]]; then
        tar xvf "$LOCAL"
        rm "$LOCAL"
    elif [[ $EXT == "gz" ]]; then
        gunzip "$LOCAL"
    elif [[ $EXT == "zip" ]]; then
        unzip "$LOCAL"
        rm "$LOCAL"
    elif [[ $EXT == "bz" ]] || [[ $EXT == "bz2" ]]; then
        bunzip2 "$LOCAL"
    fi
fi

FILES=$(mktemp)
find . -type f > "$FILES"

while read -r FNAME; do
    echo "Putting \"$FNAME\""
    iput -f "$FNAME" "$DEST"
done < "$FILES"

rm -rf "$TMP_DIR"
