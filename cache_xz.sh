#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"
source config.sh

CACHEDIR="$1"
FILENAME="$2"
MD=$(md5sum "$FILENAME" | cut -d' ' -f 1);
if [ ! -e "${CACHEDIR}/${MD}" ]; then
    echo "[INFO] No dotno-cache for ${FILENAME} ($MD)" 1>&2;
  xz --decompress --stdout "$FILENAME" | \
      grep -a -F '.no' > "${CACHEDIR}/${MD}.tmp"; \
          mv "${CACHEDIR}/${MD}.tmp" "${CACHEDIR}/${MD}" && \
          echo "${MD}";
else
    echo "[INFO] Found dotno-cache for ${FILENAME} ($MD)" 1>&2;
    echo "${MD}";
fi
