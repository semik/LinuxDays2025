#!/bin/bash

# Allow override via env or arg: $1 is optional path, else $COUNTER_DIR, else /data
COUNTER_DIR="${1:-${COUNTER_DIR:-/tmp}}"
COUNTER_FILE="$COUNTER_DIR/counter"

# Ensure /data exists
mkdir -p "$(dirname "$COUNTER_FILE")"

# Read or initialize counter
if [[ -f "$COUNTER_FILE" ]]; then
    count=$(cat "$COUNTER_FILE")
else
    count="00000"
fi

# Increment counter, keep 5 digits
next=$(printf "%05d" $((10#$count + 1)))
echo "$next" > "$COUNTER_FILE"

# Helper: url decode
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# Parse params into associative array
declare -A params
IFS='&' read -ra pairs <<< "$QUERY_STRING"
for pair in "${pairs[@]}"; do
    IFS='=' read -r key val <<< "$pair"
    params["$key"]="$(urldecode "$val")"
done

# Set defaults if not provided
w="${params[w]:-10}"
c="${params[c]:-#00DD00}"
o="${params[o]:-#d2ffd2}"
b="${params[b]:-white}"
H="${params[H]:-'0'}"
if [ "$H" != "0" ]; then
  H="-H"
fi

# Use the incremented counter as the number
n="$next"

# Call the real script (output to temp)
outfile=$(mktemp /tmp/counter.XXXXXX)
./7segment.sh -w "$w" -c "$c" -o "$o" -b "$b" "$H" "$n" "$outfile"

echo "Content-Type: image/png"
echo
cat "$outfile"
rm "$outfile"