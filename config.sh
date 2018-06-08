#MCN_TOOLS have been moved to:
source "$HOME/.mcn.conf"
# Contains all *.torrent files
TORRENT_PATH="$PWD/torrents"
# Temporarily stores all torrent data, and the resulting ".no" raw extracts
STORAGE_PATH="$PWD/download"
# Contains extracts of all urls containing ".no" from torrents
# Also used as temporary dir for extracted torrents
CACHE_PATH="$PWD/no_extract_cache"
THREADS=8
DOMAINS="mcn-source-urlteam.list"
