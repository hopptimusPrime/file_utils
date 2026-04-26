#!/bin/bash

################################################################################
# fileman - Music Library File Renaming Utility
#
# This script provides useful utilities for organizing and cleaning up music
# library filenames. It includes several operations to normalize file naming
# conventions commonly found in music collections:
#
#   dehy   - Remove hyphenated prefixes (e.g., "Artist-Song.mp3" → "Song.mp3")
#   unthe      - Move "The" from beginning to end (e.g., "The Beatles" → "Beatles, The")
#   unnum      - Strip leading track numbers (e.g., "01 Song.mp3" → "Song.mp3")
#   unscore    - Replace underscores with spaces (e.g., "Song_Title_1" → "Song Title")
#   all        - Apply all of the above operations in sequence
#
# These operations help standardize music file naming across different sources
# and import formats, making it easier to manage and organize large music libraries.
################################################################################

if [[ "$1" == "dehy" || "$1" == "all" ]]; then
    # loop through all files in the current directory
    echo "Processing dehyphenation routine"
    for f in *; do
    # Skip directories
    [ -f "$f" ] || continue

    # Check if filename contains a hyphen
    if [[ "$f" == *-* ]]; then
        # Remove up to and including the first hyphen
        newname="${f#*-}"

        # Remove leading spaces
        newname="$(echo "$newname" | sed 's/^[[:space:]]*//')"

        # Only rename if new name is not empty and not identical
        if [[ -n "$newname" && "$newname" != "$f" ]]; then
            # Check if target already exists
            if [[ -e "$newname" ]]; then
                echo "Skipping '$f' → '$newname' (target exists)"
            else
                echo "Renaming '$f' → '$newname'"
                mv -- "$f" "$newname"
            fi
        fi
    fi
    done
fi

if [[ "$1" == "unscore" || "$1" == "all" ]]; then
  for file in *; do
    # Skip directories
    [ -f "$file" ] || continue

    new_name="$file"

    if [[ "$new_name" == *_1 ]]; then
      new_name="${new_name%_1}"
    fi

    new_name="${new_name//_/ }"

    if [[ "$new_name" != "$file" ]]; then
      if [[ -e "$new_name" ]]; then
        echo "Skipping '$file' → '$new_name' (target exists)"
      else
        echo "Renaming '$file' → '$new_name'"
        mv -- "$file" "$new_name"
      fi
    fi
  done
fi

if [[ "$1" == "unthe" ]]; then
   shopt -s nullglob

for dir in THE\ */; do
  # Remove trailing slash
  dir="${dir%/}"

  # Extract name without "The "
  rest="${dir#The }"

  new_name="${rest}, The"

  # Rename
  mv -- "$dir" "$new_name"
done
fi

if [[ "$1" == "unnum" || "$1" == "all" ]]; then
  for file in *; do
    # Skip directories
    [ -f "$file" ] || continue

    # Check if filename starts with a number followed by a space
    if [[ "$file" =~ ^[0-9]+[[:space:]]+(.*) ]]; then
      new_name="${BASH_REMATCH[1]}"
      new_name="$(echo "$new_name" | sed 's/^[[:space:]]*//')"
      # Check if target already exists
      if [[ -e "$new_name" ]]; then
        echo "Skipping '$file' → '$new_name' (target exists)"
      else
        echo "Renaming '$file' → '$new_name'"
        mv -- "$file" "$new_name"
      fi
    fi
done
fi
