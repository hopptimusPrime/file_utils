#!/usr/bin/env bash

set -euo pipefail

MUSIC_DIR="${1:-.}"
MAX_SONGS=3
OUTPUT="short_albums.txt"

# Audio file extensions to recognize
AUDIO_EXTENSIONS="mp3|flac|m4a|ogg|opus|wav|aac|wma|aiff|ape"

# Clear output file
> "$OUTPUT"

echo "Scanning: $MUSIC_DIR"
echo "Looking for albums with $MAX_SONGS songs or fewer..."
echo

while IFS= read -r -d '' album; do

    count=$(find "$album" -maxdepth 1 -type f \
        | grep -Eic "\.($AUDIO_EXTENSIONS)$" || true)

    if (( count <= MAX_SONGS )); then
        echo "$count songs | $album" | tee -a "$OUTPUT"
    fi

done < <(find "$MUSIC_DIR" -mindepth 3 -type d -print0)

echo
echo "Results saved to: $OUTPUT"
