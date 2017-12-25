#! /bin/bash
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

if [ ! -e "$DOMAINS" ] || [ "x$1" = "x--update" ]; then
    mkdir -p "${STORAGE_PATH}/dotno-cache"
    find "${STORAGE_PATH}/" -type f -name '*.xz' | \
    while read CTXT; do
        MD=$(md5sum "$CTXT" | cut -d' ' -f 1);
        if [ ! -e "${STORAGE_PATH}/dotno-cache/${MD}" ]; then
            echo "[INFO] No dotno-cache for $CTXT, creating";
            xz --decompress --stdout "$CTXT" | \
                grep -a -F '.no' > "${STORAGE_PATH}/dotno-cache/tmp" && \
                cp "${STORAGE_PATH}/dotno-cache/tmp" "${STORAGE_PATH}/dotno-cache/${MD}";
        else
            echo "[INFO] Using dotno-cache for $CTXT";
        fi
    done;
fi

exit
if [ -e "$DOMAINS" ]; then
    LIST_AGE="$(stat --format '%Y' "$DOMAINS")"
    NOw="$(date --utc +%s)"
    AGE=$(echo "(${NOW} - ${LIST_AGE})/86400" | bc)
    if [ $AGE -gt 7 ]; then
        echo "WARNING: The cached list is $AGE days old. You might want to generate a new one using 'get_certs.sh' and 'list_domains.sh --update'" 1>&2
    fi
    #cat "$DOMAINS";
fi

