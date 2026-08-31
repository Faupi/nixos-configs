#!/usr/bin/env bash

set -euo pipefail

CONFIG="${1:-config.json}"
APP_NAME="${APP_NAME:-clipboard-actions-local}"

content_file="$(mktemp)"
trap 'rm -f "$content_file"' EXIT

cat >"$content_file"

content="$(cat "$content_file")"

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
# NOTE: Get from file rather than variable to avoid hitting the argument limit in jq
matching_commands="$(
  jq -c \
    --rawfile content "$content_file" '
      .rules[]
      | . as $rule
      | ($content | match($rule.regex)) as $match
      | .commands[]
      | . + {
          captures: ($match.captures | map(.string))
        }
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

# Ellipse prompt if the content is too long (65 chars max, 50 of start, 15 of end)
if ((${#content} > 50)); then
  prompt="${content:0:50}…${content: -15}"
else
  prompt="$content"
fi

if ! selection="$(
  printf '%s\n' "$menu_input" |
    wofi \
      --show dmenu \
      --prompt "$prompt" \
      --style="$WOFI_CSS" \
      --width="25%"
)"; then
  exit 0
fi

[[ -z "$selection" ]] && exit 0

command_json="${commands[$selection]}"

command="$(jq -r '.command' <<<"$command_json")"
output_mode="$(jq -r '.output' <<<"$command_json")"

# Substitute the full clipboard contents and regex captures.
command="${command//%s/$content}"

mapfile -t captures < <(jq -r '.captures[]' <<<"$command_json")

for i in "${!captures[@]}"; do
  capture_number=$((i + 1))
  command="${command//%$capture_number/${captures[$i]}}"
done

# Run command
if result="$(bash -c "$command")"; then
  status=0
else
  status=$?
  notify-send --app-name="$APP_NAME" \
    "Command failed" \
    "Exit status: $status"
  exit "$status"
fi

# Output
case "$output_mode" in
copy)
  [[ -z "$result" ]] && exit 0

  printf '%s' "$result" >"$STATE_FILE"
  printf '%s' "$result" | wl-copy
  notify-send --app-name="$APP_NAME" --transient \
    "Copied result" \
    "$result"
  ;;
ignore)
  ;;
*)
  notify-send --app-name="$APP_NAME" \
    "Configuration error" \
    "Unknown output mode: $output_mode"
  ;;
esac
