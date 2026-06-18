#!/usr/bin/env bash

set -euo pipefail

CONFIG="${1:-config.json}"

content="$(cat)"

[[ -z "$content" ]] && exit 0

STATE_FILE="${XDG_RUNTIME_DIR}/clipboard-actions-ignore"

# Ignore clipboard contents we intentionally copied ourselves.
if [[ -f "$STATE_FILE" ]]; then
  ignored="$(cat "$STATE_FILE")"

  if [[ "$ignored" == "$content" ]]; then
    rm -f "$STATE_FILE"
    exit 0
  fi
fi

# Collect matching commands.
matching_commands="$(
  jq -c \
    --arg content "$content" '
      .rules[]
      | . as $rule
      | select($content | test($rule.regex))
      | .commands[]
    ' "$CONFIG"
)"

[[ -z "$matching_commands" ]] && exit 0

declare -A commands

while IFS= read -r cmd; do
  label="$(jq -r '.label' <<<"$cmd")"

  # Deduplicate by label.
  commands["$label"]="$cmd"
done <<<"$matching_commands"

menu_input="$(
  printf '%s\n' "${!commands[@]}" | sort
)"

if ! selection="$(
  printf '%s\n' "$menu_input" |
    wofi \
      --show dmenu \
      --prompt "$content" \
      --style="$WOFI_CSS" \
      --width="25%"
)"; then
  exit 0
fi

[[ -z "$selection" ]] && exit 0

command_json="${commands[$selection]}"

command="$(jq -r '.command' <<<"$command_json")"
output_mode="$(jq -r '.output' <<<"$command_json")"

command="${command//%s/$content}"

case "$output_mode" in
copy)
  result="$(
    bash -c "$command"
  )"

  [[ -z "$result" ]] && exit 0

  printf '%s' "$result" >"$STATE_FILE"
  printf '%s' "$result" | wl-copy
  notify-send \
    "Clipboard Actions" \
    "Copied: $result"
  ;;
ignore)
  bash -c "$command"
  ;;
*)
  notify-send \
    "Clipboard Actions" \
    "Unknown output mode: $output_mode"
  ;;
esac
