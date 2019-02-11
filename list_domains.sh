#! /usr/bin/env bash
# Info: 
# Download: 
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SOURCE_DIR" || exit
source "./config.sh"

set -euo pipefail
#set -x

LOG_INFO=1
LOG_VERB=0

function def_ex {
  set -euo pipefail
  XZ_FILE="${1:-}"
  MCN_TOOLS="${3:-}"
  FILENAME="$(basename "$XZ_FILE")"
  CACHE_FOLDER="${2:-}"
  CACHE_FILE="$CACHE_FOLDER/$FILENAME";
  JOD_ID="${4:-}"
  echo "$XZ_FILE $FILENAME $CACHE_FOLDER $CACHE_FILE $JOD_ID"
  if [ ! -f "$CACHE_FILE" ]; then
    INFO "Extracting domains from $XZ_FILE to $CACHE_FILE"
    # We do some hacks to remove the number of false positive domains
    # urldecode: 20finn.no -> 
    #     http://blogg.no/share?url=http://pitoresk.blogg.no/1297370777_10feb2011.html&title=Antikviteter%20fra%20finn.no
    # sed: 300367.no -> 
    #     http://www.tromso.kommune.no/skriftlige-spoersmaal.300367.no.html
    xzcat "$XZ_FILE" | sed -e 's/\.no\.html/.html/g' | \
      "$MCN_TOOLS/urldecode" 3 | \
      "$MCN_TOOLS/default_extract" | \
      sort | uniq | \
      xz --compress --stdout > "$CACHE_FILE.tmp" && \
      mv "$CACHE_FILE.tmp" "$CACHE_FILE"
  else
    VERB "Found $CACHE_FILE.xz, not extracting domains from $XZ_FILE"
  fi
}

export -f def_ex
export LOG_INFO
export LOG_VERB

SIMPLE_EXTRACTS="$STORAGE_PATH/simple_extract"
REGEXP_EXTRACTS="$STORAGE_PATH/regexp_extract"
YM="$(date +%F)"
COUNT="$(find . -name "$YM-$DOMAINS" 2>/dev/null | wc -l)";
if [ "$COUNT" -eq "0" ] || [ "x${1:-}" = "x--update-list" ]; then
  INFO "$DOMAINS not found, extracting ..."

  TIMESTAMP="$(date +%F-%T | tr ':' '-')"
  YM="$(date +%F)"
  mkdir -p "$REGEXP_EXTRACTS"
  XZ_FILES="$(mktemp "$PWD/xz-files-$TIMESTAMP-XXXXXXXXXX.tmp")"
  find "$SIMPLE_EXTRACTS/" -type f -name '*.no.xz' > "$XZ_FILES"

  # Parallel extraction of domains from all gzs, stored to xz
  cat "$XZ_FILES" | parallel def_ex '{}' "$REGEXP_EXTRACTS" "$MCN_TOOLS" '{#}'
  rm "$XZ_FILES"

  INFO "Combining extract into onw output file ..."
  EXTRACT_TMP="$(mktemp "$PWD/ET-$TIMESTAMP-XXXXXXXXXX")"
  EXTRACT_TMP2="$(mktemp "$PWD/ET2-$TIMESTAMP-XXXXXXXXXX")"
  find "$REGEXP_EXTRACTS" -name '*.xz' | \
  while read -r EXTRACT; do
    xzcat "$EXTRACT" >> "$EXTRACT_TMP";
  done
  cat old/* "$EXTRACT_TMP" | "$MCN_TOOLS/default_extract" > "$EXTRACT_TMP2"
  mv output/* old/ || true
  mv "$EXTRACT_TMP2" "output/$YM-$DOMAINS"
  rm "$EXTRACT_TMP" || true
  INFO "Extraction complete. Saved to output/$YM-$DOMAINS"
else
    INFO "$DOMAINS found. Use '$0 --update-list' create a new extract."
fi
