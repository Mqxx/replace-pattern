#!/bin/bash

directory="$1"
search_pattern="$2"
replacement_string="$3"
logging="${4:-true}"

if [ $# -ne 3 ]; then
echo "
Missing parameter.

DESCRIPTION
    Replace pattern in files, the file content and directories recursively.

PARAMETERS
    \$1  Specifies the root directory to start the replacement process.
    \$2  Specifies the pattern to be replaced in directory names, file names, and file contents.
    \$3  Specifies the string that will replace the specified pattern.
    \$4  Switch to enable verbose output showing what is being replaced.

EXAMPLE
    $0 ./path/to/directory 'PATTERN' 'REPLACEMENT'
"
  exit 1
fi

if [ ! -d "$directory" ]; then
    echo "Replace-Pattern: '$1': No such file or directory."
    exit 1
fi

search_and_replace() {
  local dir="$1"
  local pattern="$2"
  local replacement="$3"
  local logging="$4"

  find "$dir" -depth -type d -name "*$pattern*" -exec bash -c '
    new_path="${1//$2/$3}";
    if [ "$1" != "$new_path" ]; then
      mv "$1" "$new_path";
      if [ "$4" == "true" ]; then
        echo -e "Replace-Pattern: \x1b[36m'\''$1'\''\x1b[0m: Renaming \x1b[36m'\''$(basename "$1")'\''\x1b[0m to \x1b[36m'\''$(basename "$new_path")'\''\x1b[0m";
      fi
    fi
  ' _ {} "$pattern" "$replacement" "$logging" \;

  find "$dir" -type f -execdir bash -c '
    sed -i "s|$(printf '\''%s'\'' "$2" | sed '\''s/[\/&]/\\&/g'\'')|$3|g" "$1";
    new_file="$(echo "$1" | sed "s/$2/$3/g")";
    if [ "$1" != "$new_file" ]; then
      mv "$1" "$new_file";
      if [ "$4" == "true" ]; then
        echo -e "Replace-Pattern: \x1b[36m'\''$1'\''\x1b[0m: Renaming \x1b[36m'\''$1'\''\x1b[0m to \x1b[36m'\''$new_file'\''\x1b[0m";
      fi
    fi
  ' _ {} "$pattern" "$replacement" "$logging" \;
}

search_and_replace "$directory" "$search_pattern" "$replacement_string" "$logging"

echo "Replace-Pattern: Done!"
