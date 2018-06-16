#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"
source config.sh
ME="$(basename "${BASH_SOURCE[0]}")"

CACHEDIR="$1"
FILENAME="$2"
#echo "${CACHEDIR}, ${FILENAME}"
#exit
MDZ=$(md5sum "$FILENAME" | cut -d' ' -f 1);
if [ ! -e "${CACHEDIR}/${MDZ}.col" ]; then
  INFO "No dotno-cache for ${FILENAME} (${MDZ}.col) [$ME]"
  EXTRACT="$(mktemp --directory --tmpdir="${CACHEDIR}")"
  cd "${EXTRACT}"
  INFO "$FILENAME into $EXTRACT [$ME]"
  7z x "${FILENAME}" | grep "ing archive";
  find "${EXTRACT}" -name '*.xz' ! -name '*.meta.*' | \
      while read XZ; do
          INFO "Extracting $XZ [$ME]"
          ${SOURCE_DIR}/cache_xz.sh "${CACHEDIR}" "${XZ}" >> "${CACHEDIR}/${MDZ}.col.tmp"
      done;
  cd ..
  mv "${CACHEDIR}/${MDZ}.col.tmp" "${CACHEDIR}/${MDZ}.col"
  rm -r "${EXTRACT}"
else
    INFO "Found dotno-cache for ${FILENAME} [$ME]";
fi
