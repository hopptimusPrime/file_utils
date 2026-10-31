#!/usr/bin/env bash

set -euo pipefail

MUSIC_DIR="${1:-.}"
OUTPUT="music_library.csv"

# Create a temporary file for sorting
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

# Find Artist/Album directories, ignoring Genre
find "$MUSIC_DIR" -mindepth 3 -maxdepth 3 -type d |
while IFS= read -r album_path; do
    artist=$(basename "$(dirname "$album_path")")
    album=$(basename "$album_path")

    printf '%s\t%s\n' "$artist" "$album"
done | sort -t $'\t' -k1,1 -k2,2 > "$TMP"

# Get unique artist names
mapfile -t artists < <(cut -f1 "$TMP" | sort -u)

# Find maximum number of albums for any artist
max_albums=$(cut -f1 "$TMP" | sort | uniq -c | awk 'BEGIN {max=0} $1>max {max=$1} END {print max}')

# CSV escaping function
csv_escape() {
    local value="$1"
    value="${value//\"/\"\"}"
    printf '"%s"' "$value"
}

# Generate CSV
for artist in "${artists[@]}"; do
    csv_escape "$artist"

    while IFS= read -r album; do
        printf ','
        csv_escape "$album"
    done < <(awk -F '\t' -v a="$artist" '$1 == a {print $2}' "$TMP")

    printf '\n'
done > "$OUTPUT"

echo "CSV generated: $OUTPUT"
