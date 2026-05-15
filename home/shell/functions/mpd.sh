#!/usr/bin/env bash

mpd() {
    # Not `mpd reload` so pass args to mpd to handle normally
    if [[ $1 != "reload" ]]; then
        command mpd "$@"
    else
        local MUSIC_DIR="$HOME/Music"
        local PLAYLIST_NAME="all"
        local PLAYLIST_ALL="$HOME/.config/mpd/playlists/$PLAYLIST_NAME.m3u"

        rm -f "$PLAYLIST_ALL"

        find -L "$MUSIC_DIR" -name '*.mp3' >"$PLAYLIST_ALL"
        find -L "$MUSIC_DIR" -name '*.m4a' >>"$PLAYLIST_ALL"
        find -L "$MUSIC_DIR" -name '*.flac' >>"$PLAYLIST_ALL"

        chmod 775 "$PLAYLIST_ALL"

        [[ $(command -v mpc) ]] &&
            mpc clear | mpc load $PLAYLIST_NAME | mpc update |
            sed -e 's|^volume.*||m'
    fi
}
