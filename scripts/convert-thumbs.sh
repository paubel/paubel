#!/usr/bin/env bash
# Convert source images to small WebP thumbnails for the site.
# Usage: ./scripts/convert-thumbs.sh [source-pattern]
# Example: ./scripts/convert-thumbs.sh "images/*.{jpg,png}" or simply run without args to process images/*.jpg

set -euo pipefail
shopt -s nullglob

SRC_PATTERN="${1:-images/*.{jpg,jpeg,png}}"
OUT_DIR="images"
QUALITY=80
WIDTH=360

echo "Converting files matching: $SRC_PATTERN"

# Prefer cwebp if available for smaller files; otherwise try ImageMagick's magick/convert
if command -v cwebp >/dev/null 2>&1; then
  echo "Using cwebp to encode WebP thumbnails (quality=$QUALITY, width=$WIDTH)"
  for src in $SRC_PATTERN; do
    base=$(basename "$src")
    name="${base%.*}"
    out="$OUT_DIR/${name}-thumb.webp"
    echo " -> $src -> $out"
    # resize with imagemagick if available, otherwise rely on cwebp's -resize
    if command -v magick >/dev/null 2>&1; then
      magick "$src" -resize ${WIDTH}x -quality $QUALITY -strip -unsharp 0x.5 "$out"
    else
      # cwebp resize syntax: -resize width height (height=0 keeps aspect ratio)
      cwebp -q $QUALITY -resize $WIDTH 0 "$src" -o "$out" >/dev/null
    fi
  done
elif command -v magick >/dev/null 2>&1; then
  echo "Using ImageMagick (magick) to create WebP thumbnails (quality=$QUALITY, width=$WIDTH)"
  for src in $SRC_PATTERN; do
    base=$(basename "$src")
    name="${base%.*}"
    out="$OUT_DIR/${name}-thumb.webp"
    echo " -> $src -> $out"
    magick "$src" -resize ${WIDTH}x -quality $QUALITY -strip -unsharp 0x.5 "$out"
  done
else
  echo "Error: neither cwebp nor magick (ImageMagick) found. Install libwebp (cwebp) or ImageMagick." >&2
  exit 2
fi

echo "Done. Generated thumbnails are in $OUT_DIR"
