#!/usr/bin/env bash

# frames: a contact sheet of a video, for reviewing motion a frame at a
# time. One PNG, frames in a grid, each stamped with its time in the
# clip. Reads well by eye and by Claude.
#
#   frames clip.mp4                       whole clip, 4 frames a second
#   frames clip.mp4 -s 12 -t 3            3 seconds from 0:12
#   frames clip.mp4 -f 10 -c 5            denser, five across
#   frames clip.mp4 --scene 0.08          only frames where something changed
#   frames clip.mp4 --crop 800:600:0:90   a region: W:H:X:Y
#
# Options
#   -s, --start   seconds into the clip to start at      0
#   -t, --length  seconds to cover                       the rest
#   -f, --fps     frames a second to sample              4
#   -c, --cols    frames across                          4
#   -w, --width   width of each frame in pixels          480
#   --scene       pick frames on change instead, by a 0 to 1 threshold
#   --crop        W:H:X:Y of the clip to keep
#   -o, --out     output file                            <clip>-frames.png
#
# A sheet holds up to 48 frames; past that it writes <out>-1.png,
# <out>-2.png and so on. Needs ffmpeg with the drawtext and tile filters,
# and ffprobe.
frames() {
    local clip="" start=0 length="" fps=4 cols=4 width=480 scene="" crop="" out=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--start) start="$2"; shift 2 ;;
            -t|--length) length="$2"; shift 2 ;;
            -f|--fps) fps="$2"; shift 2 ;;
            -c|--cols) cols="$2"; shift 2 ;;
            -w|--width) width="$2"; shift 2 ;;
            --scene) scene="$2"; shift 2 ;;
            --crop) crop="$2"; shift 2 ;;
            -o|--out) out="$2"; shift 2 ;;
            -h|--help) sed -n '3,25p' "${BASH_SOURCE[0]:-$0}" | sed 's/^# \{0,1\}//'; return 0 ;;
            -*) echo "frames: unknown option $1" >&2; return 1 ;;
            *) clip="$1"; shift ;;
        esac
    done

    if [[ -z "$clip" || ! -f "$clip" ]]; then
        echo "usage: frames <clip> [-s start] [-t length] [-f fps] [-c cols] [-w width] [--scene 0.08] [--crop W:H:X:Y] [-o out.png]" >&2
        return 1
    fi

    if ! command -v ffmpeg >/dev/null || ! command -v ffprobe >/dev/null; then
        echo "frames: needs ffmpeg and ffprobe" >&2
        return 1
    fi

    # The clip's length, so the grid fits the frames
    local duration
    duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$clip")

    if [[ -z "$length" ]]; then
        length=$(awk -v d="$duration" -v s="$start" 'BEGIN { l = d - s; if (l < 0) l = 0; print l }')
    fi

    [[ -z "$out" ]] && out="${clip%.*}-frames.png"

    # The grid: rows from the frame count, at most 48 a sheet
    local count rows max_rows=12 pattern
    count=$(awk -v f="$fps" -v l="$length" 'BEGIN { c = int(f * l + 0.999); if (c < 1) c = 1; print c }')
    rows=$(awk -v c="$count" -v k="$cols" 'BEGIN { r = int((c + k - 1) / k); if (r < 1) r = 1; print r }')

    if [[ -n "$scene" ]]; then
        rows=$max_rows
    fi

    local filter="" pick=""

    [[ -n "$crop" ]] && filter="crop=${crop},"

    if [[ -n "$scene" ]]; then
        pick="select='gt(scene,${scene})'"
    else
        pick="fps=${fps}"
    fi

    # The stamp is the clip's own time, with the start added back since
    # seeking resets the clock
    filter="${filter}${pick},scale=${width}:-2,drawtext=text='%{pts\\:hms\\:${start}}':x=8:y=8:fontsize=18:fontcolor=white:box=1:boxcolor=black@0.5:boxborderw=4"

    if [[ -n "$scene" || "$rows" -gt "$max_rows" ]]; then
        # More than one sheet
        rows=$max_rows
        pattern="${out%.*}-%d.${out##*.}"
        ffmpeg -v error -y -ss "$start" -t "$length" -i "$clip" -vf "${filter},tile=${cols}x${rows}" "$pattern" || return 1

        # No shell glob: zsh complains when nothing matched
        local written
        written=$(find "$(dirname "$out")" -maxdepth 1 -name "$(basename "${out%.*}")-[0-9]*.${out##*.}" | sort)

        if [[ -z "$written" ]]; then
            echo "frames: nothing picked; lower --scene or use --fps" >&2
            return 1
        fi

        echo "$written"
    else
        ffmpeg -v error -y -ss "$start" -t "$length" -i "$clip" -vf "${filter},tile=${cols}x${rows}" -frames:v 1 "$out" || return 1
        echo "$out"
    fi
}
