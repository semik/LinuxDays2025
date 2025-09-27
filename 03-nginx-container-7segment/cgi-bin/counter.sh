#!/bin/bash

COUNTER_FILE="/tmp/counter"

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

# Use the incremented counter as the number
n="$next"

# Call the real script (output to temp)
outfile=$(mktemp --suffix=.png)
./7segment.sh -w "$w" -c "$c" -o "$o" -b "$b" "$n" "$outfile"

echo "Content-Type: image/png"
echo
cat "$outfile"
rm "$outfile"