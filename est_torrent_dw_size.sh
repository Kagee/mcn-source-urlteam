#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SOURCE_DIR" || exit

source config.sh

SIZES="$(find "$TORRENT_PATH" -type f -name '*.torrent' | \
  while read -r F; do
    TL=$(aria2c --show-files=true --dir="./download" --torrent-file "$F" | \
      grep 'Total Length:' | cut -d'(' -f2 | tr -d ')');
    echo "$TL $(basename "$F") ";
  done | sort -n)"

echo >&2 "[INFO] Five largest:"
echo "$SIZES" | tail -5 | tac | while read -r LARGE; do
  SIZE="$(echo "$LARGE" | awk '{ print $1 }' | \
    tr -d , | tr '\n' '+' | head -c -1 | \
    sed -e 's#^#(#' -e 's#$#)/1024/1024\n#' | \
    bc | tr -d '\n'; echo " MiB (mebibyte)")"
  NAME="$(echo "$LARGE" | awk '{ print $2 }')"
  echo "$NAME $SIZE"
done
echo -n >&2 "[INFO] Total: "
echo "$SIZES" | awk '{ print $1 }' | \
  tr -d , | tr '\n' '+' | head -c -1 | \
  sed -e 's#^#(#' -e 's#$#)/1024/1024/1024\n#' | \
  bc | tr -d '\n'; echo " GiB (gibibyte)"
