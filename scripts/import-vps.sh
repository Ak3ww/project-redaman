#!/bin/bash
# Script to import all Virtual Parameters and Provisions to GenieACS NBI
set -e

GENIEACS_NBI_URL="${1:-http://localhost:7557}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VP_DIR="$ROOT_DIR/virtual-parameters"
PROV_DIR="$ROOT_DIR/provisions"

echo "=================================================="
echo "Importing Virtual Parameters to GenieACS NBI at $GENIEACS_NBI_URL"
echo "=================================================="

# Check if NBI is reachable
if ! curl -s -f "$GENIEACS_NBI_URL/devices" >/dev/null 2>&1; then
  echo "Error: GenieACS NBI at $GENIEACS_NBI_URL is not responding yet."
  echo "Please make sure GenieACS NBI is running."
  exit 1
fi

# Import Virtual Parameters
if [ -d "$VP_DIR" ]; then
  for file in "$VP_DIR"/*.js; do
    if [ -f "$file" ]; then
      vp_name="$(basename "$file" .js)"
      echo "-> Uploading Virtual Parameter: $vp_name"
      
      # Read script and JSON-escape it using python or node or jq
      json_payload=$(node -e '
        const fs = require("fs");
        const script = fs.readFileSync(process.argv[1], "utf8");
        process.stdout.write(JSON.stringify({ script: script }));
      ' "$file" 2>/dev/null || python3 -c '
import json, sys
with open(sys.argv[1], "r") as f:
    print(json.dumps({"script": f.read()}))
' "$file")

      curl -s -X PUT "$GENIEACS_NBI_URL/virtual_parameters/$vp_name" \
        -H "Content-Type: application/json" \
        -d "$json_payload"
      echo " [OK]"
    fi
  done
fi

# Import Provisions
if [ -d "$PROV_DIR" ]; then
  for file in "$PROV_DIR"/*.js; do
    if [ -f "$file" ]; then
      prov_name="$(basename "$file" .js)"
      echo "-> Uploading Provision: $prov_name"
      
      json_payload=$(node -e '
        const fs = require("fs");
        const script = fs.readFileSync(process.argv[1], "utf8");
        process.stdout.write(JSON.stringify({ script: script }));
      ' "$file" 2>/dev/null || python3 -c '
import json, sys
with open(sys.argv[1], "r") as f:
    print(json.dumps({"script": f.read()}))
' "$file")

      curl -s -X PUT "$GENIEACS_NBI_URL/provisions/$prov_name" \
        -H "Content-Type: application/json" \
        -d "$json_payload"
      echo " [OK]"
    fi
  done
fi

echo "=================================================="
echo "All Virtual Parameters & Provisions synced successfully!"
echo "=================================================="
