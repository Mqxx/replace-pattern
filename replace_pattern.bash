#!/bin/bash

search_and_replace() {
  local dir="$1"
  local pattern="$2"
  local replacement="$3"

  find "$dir" -depth -type d -name "*$pattern*" -exec bash -c 'new_path="${1//$2/$3}"; if [ "$1" != "$new_path" ]; then mv "$1" "$new_path"; fi' _ {} "$pattern" "$replacement" \;

  find "$dir" -type f -execdir bash -c 'sed -i "s|$(printf '\''%s'\'' "$2" | sed '\''s/[\/&]/\\&/g'\'')|$3|g" "$1"; new_file="$(echo "$1" | sed "s/$2/$3/g")"; if [ "$1" != "$new_file" ]; then mv "$1" "$new_file"; fi' _ {} "$pattern" "$replacement" \;
}

if [ $# -ne 3 ]; then
  echo "Search and replace in filenames, folder names, and file contents."
  echo "Usage: $0 <Directory> <Pattern> <Replacement>"
  echo ""
  echo "Example: $0 ./path/to/directory 'PATTERN' 'REPLACEMENT'"
  exit 1
fi

directory="$1"
search_pattern="$2"
replacement_string="$3"

if [ ! -d "$directory" ]; then
    echo "$0: '$1': No such file or directory."
    exit 1
fi

search_and_replace "$directory" "$search_pattern" "$replacement_string"

echo "Replacement done."
