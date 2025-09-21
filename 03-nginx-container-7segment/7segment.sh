#!/bin/bash
# Usage: ./seven_segment_number.sh <number> <output_image.png>
# Example: ./seven_segment_number.sh 42 output.png

NUMBER="$1"
OUT="$2"

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

SEG_W=6   # segment thickness
SEG_L=40  # segment length
PAD=12    # padding (used at top, bottom, left, right)
DIGIT_W=$((2*PAD + 2*SEG_W + SEG_L))
DIGIT_H=$((2*PAD + 2*SEG_L + 3*SEG_W))

SEGMENT_COLOR="red"
BG_COLOR="black"

# Corrected positions for segments: [A B C D E F G]
SEGMENT_POSITIONS=(
  "$((PAD + SEG_W)) $PAD $SEG_L $SEG_W"                                  # A
  "$((PAD + SEG_W + SEG_L)) $((PAD + SEG_W)) $SEG_W $SEG_L"              # B
  "$((PAD + SEG_W + SEG_L)) $((PAD + SEG_W + SEG_L + SEG_W)) $SEG_W $SEG_L" # C
  "$((PAD + SEG_W)) $((PAD + SEG_W + SEG_L + SEG_W + SEG_L)) $SEG_L $SEG_W" # D
  "$PAD $((PAD + SEG_W + SEG_L + SEG_W)) $SEG_W $SEG_L"                  # E
  "$PAD $((PAD + SEG_W)) $SEG_W $SEG_L"                                  # F
  "$((PAD + SEG_W)) $((PAD + SEG_W + SEG_L)) $SEG_L $SEG_W"              # G
)

TMP_DIGITS=()
for (( i=0; i<${#NUMBER}; i++ )); do
  CHAR="${NUMBER:$i:1}"
  SEG="${SEGMENTS[$CHAR]}"
  IMG="digit_${i}.png"
  convert -size ${DIGIT_W}x${DIGIT_H} canvas:$BG_COLOR "$IMG"
  read -a ACTIVE <<< $SEG
  for s in {0..6}; do
    if [ "${ACTIVE[$s]}" == "1" ]; then
      read X Y W H <<< ${SEGMENT_POSITIONS[$s]}
      convert "$IMG" -fill "$SEGMENT_COLOR" -draw "rectangle $X,$Y $((X+W)),$((Y+H))" "$IMG"
    fi
  done
  TMP_DIGITS+=("$IMG")
done

montage "${TMP_DIGITS[@]}" -tile x1 -geometry +10+0 -background $BG_COLOR "$OUT"
rm -f digit_*.png
echo "Image saved to $OUT"