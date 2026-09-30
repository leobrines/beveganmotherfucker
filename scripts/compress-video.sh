#!/usr/bin/env bash
# Compress the footage into a web-friendly MP4 at assets/animal_explotaition_footage.mp4.
#
# Usage: scripts/compress-video.sh [path/to/downloaded.mp4]
#
# The downloaded file is moved into $SOURCE_DIR (default ~/Videos/beveganmotherfucker) so the
# original is kept outside Downloads; later runs can omit the argument and reuse it.
# TARGET_MB defaults to 95 because GitHub rejects files over 100 MB and the site image is built
# from the repo checkout.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${SOURCE_DIR:-$HOME/Videos/beveganmotherfucker}"
SOURCE="$SOURCE_DIR/animal_explotaition_footage_original.mp4"
OUTPUT="$REPO_DIR/assets/animal_explotaition_footage.mp4"
TARGET_MB="${TARGET_MB:-95}"
HEIGHT="${HEIGHT:-720}"
AUDIO_KBPS=64
LOGLEVEL="${LOGLEVEL:-info}"

# Check ffmpeg is installed (we don't install it)
for bin in ffmpeg ffprobe; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: $bin not found. Install ffmpeg first (e.g. sudo apt install ffmpeg / sudo pacman -S ffmpeg)." >&2
    exit 1
  fi
done

# Move the downloaded file out of Downloads
mkdir -p "$SOURCE_DIR"
if [ $# -ge 1 ]; then
  if [ ! -f "$1" ]; then
    echo "error: $1 not found" >&2
    exit 1
  fi
  mv -n "$1" "$SOURCE"
fi
if [ ! -f "$SOURCE" ]; then
  echo "error: no source video at $SOURCE; pass the downloaded file as the first argument" >&2
  exit 1
fi

# Pick the video bitrate that lands the file at TARGET_MB
DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$SOURCE")"
VIDEO_KBPS="$(awk -v mb="$TARGET_MB" -v d="$DURATION" -v a="$AUDIO_KBPS" \
  'BEGIN { printf "%d", (mb * 8192 / d) - a }')"
echo "Duration ${DURATION}s -> video ${VIDEO_KBPS}k + audio ${AUDIO_KBPS}k at ${HEIGHT}p (~${TARGET_MB} MB)"

PASSDIR="$(mktemp -d)"
trap 'rm -rf "$PASSDIR"' EXIT
mkdir -p "$(dirname "$OUTPUT")"

# Pass 1: analyses the video
ffmpeg -hide_banner -loglevel "$LOGLEVEL" -y -i "$SOURCE" -map 0:v:0 -vf "scale=-2:$HEIGHT" -c:v libx264 -preset slow -b:v "${VIDEO_KBPS}k" \
  -pass 1 -passlogfile "$PASSDIR/ffmpeg2pass" -an -f mp4 /dev/null

# Pass 2: writes the file (faststart so browsers can play before the download finishes)
ffmpeg -hide_banner -loglevel "$LOGLEVEL" -y -i "$SOURCE" -map 0:v:0 -map '0:a:0?' -vf "scale=-2:$HEIGHT" -c:v libx264 -preset slow -b:v "${VIDEO_KBPS}k" \
  -pass 2 -passlogfile "$PASSDIR/ffmpeg2pass" -c:a aac -b:a "${AUDIO_KBPS}k" -movflags +faststart "$OUTPUT"

ls -lh "$OUTPUT"
