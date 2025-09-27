#!/bin/bash
# Usage: ./seven_segment_number.sh [OPTIONS] <number> <output_image.png>
# Example: ./seven_segment_number.sh 42 output.png
#
# Options:
#   -w WIDTH      Segment width (default: 6)
#   -c COLOR      Segment color (default: red)
#   -o COLOR      Off-segment color (default: none/transparent)
#   -b BGCOLOR    Background color (default: none/transparent)
#
# Example: ./7segment.sh -w 10 -c '#00DD00' -o '#d2ffd2' -b white' 1234 output.png ; display output.png

# === Defaults ===
SEG_W=6
SEGMENT_COLOR="red"
OFF_COLOR="none"
BG_COLOR="none"

# === Argument parsing ===
while getopts "w:c:o:b:" opt; do
  case "$opt" in
    w) SEG_W="$OPTARG" ;;
    c) SEGMENT_COLOR="$OPTARG" ;;
    o) OFF_COLOR="$OPTARG" ;;
    b) BG_COLOR="$OPTARG" ;;
    *) ;;
  esac
done
shift $((OPTIND-1))

if [[ "$#" -ne 2 ]]; then
  echo "Usage: $0 [OPTIONS] <number> <output_image.png>"
  echo "Options:"
  echo "  -w WIDTH      Segment width (default: 6)"
  echo "  -c COLOR      Segment color (default: red)"
  echo "  -o COLOR      Off-segment color (default: none/transparent)"
  echo "  -b BGCOLOR    Background color (default: none/transparent)"
  echo "Example: $0 -w 10 -c '#00ffff' -o '#44002244' -b '#ffffff' 1234 num.png"
  exit 1
fi

NUMBER="$1"
OUT="$2"

SEG_L=40
PAD=12
DIGIT_W=$((2*PAD + 2*SEG_W + SEG_L))
DIGIT_H=$((2*PAD + 2*SEG_L + 3*SEG_W))

# Segment definitions: [A B C D E F G]
declare -A SEGMENTS
SEGMENTS[0]="1 1 1 1 1 1 0"
SEGMENTS[1]="0 1 1 0 0 0 0"
SEGMENTS[2]="1 1 0 1 1 0 1"
SEGMENTS[3]="1 1 1 1 0 0 1"
SEGMENTS[4]="0 1 1 0 0 1 1"
SEGMENTS[5]="1 0 1 1 0 1 1"
SEGMENTS[6]="1 0 1 1 1 1 1"
SEGMENTS[7]="1 1 1 0 0 0 0"
SEGMENTS[8]="1 1 1 1 1 1 1"
SEGMENTS[9]="1 1 1 1 0 1 1"

SEGMENT_POSITIONS=(
  "$((PAD + SEG_W)) $PAD $SEG_L $SEG_W"                                  # A
  "$((PAD + SEG_W + SEG_L)) $((PAD + SEG_W)) $SEG_W $SEG_L"              # B
  "$((PAD + SEG_W + SEG_L)) $((PAD + SEG_W + SEG_L + SEG_W)) $SEG_W $SEG_L" # C
  "$((PAD + SEG_W)) $((PAD + SEG_W + SEG_L + SEG_W + SEG_L)) $SEG_L $SEG_W" # D
  "$PAD $((PAD + SEG_W + SEG_L + SEG_W)) $SEG_W $SEG_L"                  # E
  "$PAD $((PAD + SEG_W)) $SEG_W $SEG_L"                                  # F
  "$((PAD + SEG_W)) $((PAD + SEG_W + SEG_L)) $SEG_L $SEG_W"              # G
)

TMP_DIR=$(mktemp -d /tmp/7segment.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

TMP_DIGITS=()
for (( i=0; i<${#NUMBER}; i++ )); do
  CHAR="${NUMBER:$i:1}"
  SEG="${SEGMENTS[$CHAR]}"
  IMG="${TMP_DIR}/digit_${i}.png"
  convert -size ${DIGIT_W}x${DIGIT_H} canvas:$BG_COLOR "$IMG"
  read -a ACTIVE <<< $SEG
  for s in {0..6}; do
    read X Y W H <<< ${SEGMENT_POSITIONS[$s]}
    if [ "${ACTIVE[$s]}" == "1" ]; then
      convert "$IMG" -fill "$SEGMENT_COLOR" -draw "rectangle $X,$Y $((X+W)),$((Y+H))" "$IMG"
    elif [ "$OFF_COLOR" != "none" ]; then
      convert "$IMG" -fill "$OFF_COLOR" -draw "rectangle $X,$Y $((X+W)),$((Y+H))" "$IMG"
    fi
  done
  TMP_DIGITS+=("$IMG")
done

montage "${TMP_DIGITS[@]}" -tile x1 -geometry +10+0 -background "$BG_COLOR" "$OUT"
