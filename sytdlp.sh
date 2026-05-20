#!/bin/bash

# ------------------------------------------------------
# Simple ytdlp
# A Bash wrapper for yt-dlp that streamlines downloads
# of audio and video into organized folders
# ------------------------------------------------------

# --- Configuration. Remember, set $SYTDLP_BASE_DIR if you
#  want to change the default path this script writes to!
#  Or do it in here. Up to you at this point really ---

BASE_DIR="${SYTDLP_BASE_DIR:-$HOME/Downloads/YTDlp}"
MEDIA_TYPE="video"
DL_ARGS=( "--merge-output-format" "mp4" "-f" "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" )
MODE_MSG="Mode: Video + Audio (Container: MP4)"
DATE_FORMAT="default"
TIMESTAMP=0

# --- Help function ---
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] URL1 [URL2 URL3 ...]

A wrapper for yt-dlp that organizes downloads by date and media type

Ensure URLs are in quotes to avoid parsing issues

Dates are YYYY-MM-DD by default

Options:
  -h, --help    Show this help message
  -a            Download audio only (MP3)
  -v            Download video (Default)
  -t            Include timestamp in file name
  -f            Swap date format to YYYY-DD-MM

Example:
  $(basename "$0") -fa "https://youtu.be/abc123" "https://youtu.be/xyz789"
EOF
}

# --- Check help / No arguments ---
if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

URLS=()

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    arg="$1"
    case "$arg" in
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            combined="${arg#-}"
            for ((i=0;i<${#combined};i++)); do
                flag="${combined:$i:1}"
                case "$flag" in
                    a)
                        MEDIA_TYPE="audio"
                        DL_ARGS=("-x" "--audio-format" "mp3")
                        MODE_MSG="Mode: Audio Only (Format: MP3)"
                        ;;
                    v)
                        MEDIA_TYPE="video"
                        DL_ARGS=( "--merge-output-format" "mp4" "-f" "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" )
                        MODE_MSG="Mode: Video + Audio (Container: MP4)"
                        ;;
                    f)
                        DATE_FORMAT="alt"
                        ;;
                    t)
                        TIMESTAMP=1
                        ;;
                    *)
                        echo "Warning: Unknown flag '-$flag'"
                        ;;
                esac
            done
            shift
            ;;
        *)
            URLS+=("$arg")
            shift
            ;;
    esac
done

# --- Check yt-dlp installed ---
if ! command -v yt-dlp &> /dev/null; then
    echo "Error: yt-dlp is not installed."
    exit 1
fi

# --- Start download ---
run_download() {
    local URL="$1"
    
    YEAR=$(date +%Y)
    if [[ "$DATE_FORMAT" == "alt" ]]; then
        MONTH_DAY=$(date +"%d-%B")
        OUTPUT_DATE_FORMAT="%(upload_date>%Y-%d-%m)s"
    else
        MONTH_DAY=$(date +"%B %d")
        OUTPUT_DATE_FORMAT="%(upload_date>%Y-%m-%d)s"
    fi

    TARGET_DIR="$BASE_DIR/$MEDIA_TYPE/$YEAR/$MONTH_DAY"
    mkdir -p "$TARGET_DIR"

    if [[ "$TIMESTAMP" == 1 ]]; then
        OUTPUT_TEMPLATE="$TARGET_DIR/%(title)s - %(uploader)s - $OUTPUT_DATE_FORMAT.%(ext)s"
    else
        OUTPUT_TEMPLATE="$TARGET_DIR/%(title)s - %(uploader)s.%(ext)s"
    fi
    
    echo "---------------------------------------------------"
    echo "Target Directory: $TARGET_DIR"
    echo "$MODE_MSG"
    echo "Downloading: $URL"
    echo "---------------------------------------------------"

    ERROR_LOG=$(mktemp)
    yt-dlp "${DL_ARGS[@]}" --add-metadata -o "$OUTPUT_TEMPLATE" "$URL" 2> "$ERROR_LOG"
    EXIT_CODE=$?

    if [[ $EXIT_CODE -ne 0 ]]; then
        if grep -Ei "sign in|login|confirm your age|adult content|geo restricted|premium" "$ERROR_LOG" &> /dev/null; then
            echo "Notice: Content may require login/cookies."
            echo "Retrying with Firefox cookies..."
            yt-dlp "${DL_ARGS[@]}" --add-metadata --cookies-from-browser firefox -o "$OUTPUT_TEMPLATE" "$URL"
            EXIT_CODE=$?
        else
            echo "Download failed. See details below:"
            cat "$ERROR_LOG"
            echo "$URL" >> "$BASE_DIR/failed_downloads.log"
        fi
    fi

    rm -f "$ERROR_LOG"

    if [[ $EXIT_CODE -eq 0 ]]; then
        echo "Success! Saved to $TARGET_DIR"
    else
        echo "Download failed even after retry. Logged in failed_downloads.log"
    fi
}

# --- Process URLs ---
for URL in "${URLS[@]}"; do
    run_download "$URL"
done