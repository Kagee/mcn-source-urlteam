#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"

source config.sh

find "$TORRENT_PATH" -type f -name '*.torrent' | \
  while read F; do 
      aria2c --show-files=true --dir="./download" --torrent-file $F | grep 'Total Length:'; 
  done | \
      cut -d'(' -f2 | tr -d ')' | tr -d , | tr '\n' '+' | head -c -1 | \
      sed -e 's#^#(#' -e 's#$#)/1024/1024/1024\n#' | bc | tr -d '\n'; echo "GB (gibibyte)"
