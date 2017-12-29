#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"
source config.sh

CACHEDIR="$1"
FILENAME="$2"
#echo "${CACHEDIR}, ${FILENAME}"
#exit
MDZ=$(md5sum "$FILENAME" | cut -d' ' -f 1);
if [ ! -e "${CACHEDIR}/${MDZ}.col" ]; then
  echo "[INFO] No dotno-cache for ${FILENAME} (${MDZ}.col)" 1>&2;
  EXTRACT="$(mktemp --directory --tmpdir="${CACHEDIR}")"
  cd "${EXTRACT}"
  #echo "$FILENAME into $EXTRACT"
  7z x "${FILENAME}" | grep "ing archive";
  SUMS="";
  find "${EXTRACT}" -name '*.xz' ! -name '*.meta.*' | \
      while read XZ; do
          echo "Extracting $XZ"
          ${SOURCE_DIR}/cache_xz.sh "${CACHEDIR}" "${XZ}" >> "${CACHEDIR}/${MDZ}.col.tmp"
      done;
  cd ..
  mv "${CACHEDIR}/${MDZ}.col.tmp" "${CACHEDIR}/${MDZ}.col"
  rm -r "${EXTRACT}"
else
    echo "[INFO] Found dotno-cache for ${FILENAME}";
fi
