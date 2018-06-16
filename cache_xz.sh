#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ME="$(basename "${BASH_SOURCE[0]}")"
cd "${SOURCE_DIR}"
source config.sh

CACHEDIR="$1"
FILENAME="$2"
MD="$(md5sum "$FILENAME" | cut -d' ' -f 1).xz";
if [ ! -e "$CACHEDIR/$MD" ]; then
  INFO "No dotno-cache for $FILENAME ($MD) [$ME]"
  echo -n "[INFO] "
  xz --decompress --stdout "$FILENAME" | \
    grep -a -F '.no' | xz --compress --stdout > "$CACHEDIR/$MD.tmp";
  mv "$CACHEDIR/$MD.tmp" "$CACHEDIR/$MD" && \
    echo "$MD";
else
    VERB "Found dotno-cache for $FILENAME ($MD) [$ME]"
    echo "$MD";
fi
