#!/bin/zsh
# scripts/tf-plan-summary.sh

set -euo pipefail

if [[ $# -eq 0 ]]; then
  printf "Usage: tf-plan-summary.sh <plan.binary>\n"
  exit 1
fi

PLAN_FILE=$1
INFRA_DIR=$(dirname "$PLAN_FILE")
TMP_JSON=$(mktemp)

if [[ ! -f "$PLAN_FILE" ]]; then
  printf "ERROR: File not found: %s\n" "$PLAN_FILE"
  exit 1
fi

cd "$INFRA_DIR" && terraform show -json "$(basename "$PLAN_FILE")" > "$TMP_JSON"

printf "\033[1m\n=== PLAN SUMMARY ===\033[0m\n"

printf "\033[32m\n+ TO CREATE\033[0m\n"
jq -r '[.resource_changes[] | select(.change.actions == ["create"]) | .address] | to_entries[] | "  \(.key + 1). + \(.value)"' "$TMP_JSON"

printf "\033[33m\n~ TO CHANGE\033[0m\n"
jq -r '[.resource_changes[] | select(.change.actions == ["update"]) | .address] | to_entries[] | "  \(.key + 1). ~ \(.value)"' "$TMP_JSON"

printf "\033[31m\n- TO DESTROY\033[0m\n"
jq -r '[.resource_changes[] | select(.change.actions == ["delete"]) | .address] | to_entries[] | "  \(.key + 1). - \(.value)"' "$TMP_JSON"

printf "\033[35m\n↺ TO REPLACE\033[0m\n"
jq -r '[.resource_changes[] | select(.change.actions == ["delete","create"]) | .address] | to_entries[] | "  \(.key + 1). -/+ \(.value)"' "$TMP_JSON"

printf "\033[1m\n=== COUNT ===\033[0m\n"
jq -r '
  (.resource_changes | map(select(.change.actions == ["create"])) | length) as $add |
  (.resource_changes | map(select(.change.actions == ["update"])) | length) as $change |
  (.resource_changes | map(select(.change.actions == ["delete"])) | length) as $destroy |
  (.resource_changes | map(select(.change.actions == ["delete","create"])) | length) as $replace |
  "  \($add) to add, \($change) to change, \($destroy) to destroy, \($replace) to replace"
' "$TMP_JSON"

rm "$TMP_JSON"
