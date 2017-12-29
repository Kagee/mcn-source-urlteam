#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"
source config.sh

# Stats
#    671 urlteam_sqlite - s3 metadata
#      1 URLTeamTorrentRelease2013July_sqlite - s3 metadata
#      1 URLTeamTorrentRelease2013July_torrent
#      2 URLTeamTorrentRelease2013July_txt
#      1 URLTeamTorrentRelease2013July_xml - arcive.org metadata
#   4078 URLTeamTorrentRelease2013July_xz
#    671 urlteam_xml - arcive.org metadata
#   5438 urlteam_zip

CACHEDIR="${STORAGE_PATH}/dotno-cache"

if [ ! -e "$DOMAINS" ] || [ "x$1" = "x--update" ]; then
    mkdir -p "${CACHEDIR}/"
    #find "${STORAGE_PATH}/" -type f -name '*.xz' | \
    #parallel --jobs 7 --bar ${SOURCE_DIR}/cache_xz.sh "${CACHEDIR}" "{}";

    #find "${STORAGE_PATH}/" -type f -name '*.zip' | \
    #parallel --jobs 7 --bar ${SOURCE_DIR}/cache_zip.sh "${CACHEDIR}" "{}";

    # We use iconv to remove some invalid UTF-8 chars from stream of lines
    find ${CACHEDIR}/ -type f ! -name '*.col' -exec cat {} \; | \
        parallel --jobs ${THREADS} --pipe iconv -c -f utf-8 -t utf-8 | \
        sed -e 's/\.no\.html/.html/g' | \
        ${MCN_TOOLS}/urldecode 3 | ${MCN_TOOLS}/default_extract > "${DOMAINS}"

fi
