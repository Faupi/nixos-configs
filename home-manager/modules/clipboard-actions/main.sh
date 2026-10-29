#!/usr/bin/env bash

set -euo pipefail

export CONFIG="${1:-config.json}"
export APP_NAME="${APP_NAME:-clipboard-actions-local}"
export MENU_BACKEND="${MENU_BACKEND:-auto}"

read_clipboard_content() {
  content_file="$(mktemp)"
  trap 'rm -f "$content_file"' EXIT
  cat >"$content_file"
  content="$(cat "$content_file")"
}

should_ignore_content() {
  local state_file="${XDG_RUNTIME_DIR}/clipboard-actions-ignore"

  [[ -f "$state_file" ]] || return 1

  local ignored
  ignored="$(cat "$state_file")"

  if [[ "$ignored" == "$content" ]]; then
    rm -f "$state_file"
    return 0
  fi

  return 1
}

collect_matching_commands() {
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
}

deduplicate_commands_by_label() {
  local matching_commands="$1"
  declare -gA commands=()

  while IFS= read -r cmd; do
    [[ -z "$cmd" ]] && continue
    local label
    label="$(jq -r '.label' <<<"$cmd")"
    commands["$label"]="$cmd"
  done <<<"$matching_commands"
}

make_menu_input() {
  printf '%s\n' "${!commands[@]}" | sort
}

make_mango_menu_input() {
  local label icon
  for label in "${!commands[@]}"; do
    icon="$(jq -r '.icon // empty' <<<"${commands[$label]}")"
    if [[ -n "$icon" ]]; then
      printf '%s|%s\n' "$icon" "$label"
    else
      printf '%s\n' "$label"
    fi
  done | sort
}

make_prompt() {
  if ((${#content} > 65)); then
    printf '%s…%s' "${content:0:50}" "${content: -15}"
  else
    printf '%s' "$content"
  fi
}

choose_menu_backend() {
  case "$MENU_BACKEND" in
  auto)
    if command -v mango-context-menu >/dev/null 2>&1; then
      printf '%s' "mango-context-menu"
    else
      printf '%s' "wofi"
    fi
    ;;
  mango-context-menu | wofi)
    printf '%s' "$MENU_BACKEND"
    ;;
  *)
    notify-send --app-name="$APP_NAME" \
      "Configuration error" \
      "Unknown MENU_BACKEND: $MENU_BACKEND"
    return 2
    ;;
  esac
}

show_menu() {
  local backend="$1"
  local menu_input="$2"
  local prompt="$3"

  case "$backend" in
  mango-context-menu)
    if ! command -v mango-context-menu >/dev/null 2>&1; then
      notify-send --app-name="$APP_NAME" \
        "Menu unavailable" \
        "mango-context-menu is not installed"
      return 127
    fi

    local mango_menu_input
    mango_menu_input="$(make_mango_menu_input)"
    printf '%s\n' "$mango_menu_input" | mango-context-menu
    ;;
  wofi)
    local -a wofi_args=(--show dmenu --prompt "$prompt" --width="25%")
    if [[ -n "${WOFI_CSS:-}" ]]; then
      wofi_args+=(--style="$WOFI_CSS")
    fi

    printf '%s\n' "$menu_input" | wofi "${wofi_args[@]}"
    ;;
  esac
}

run_selected_command() {
  local command_json="$1"
  local command output_mode result status
  local -a captures

  command="$(jq -r '.command' <<<"$command_json")"
  output_mode="$(jq -r '.output' <<<"$command_json")"

  # Substitute the full clipboard contents and regex captures.
  command="${command//%s/$content}"
  mapfile -t captures < <(jq -r '.captures[]' <<<"$command_json")

  for i in "${!captures[@]}"; do
    local capture_number=$((i + 1))
    command="${command//%$capture_number/${captures[$i]}}"
  done

  if result="$(bash -c "$command")"; then
    status=0
  else
    status=$?
    notify-send --app-name="$APP_NAME" \
      "Command failed" \
      "Exit status: $status"
    return "$status"
  fi

  handle_command_output "$output_mode" "$result"
}

handle_command_output() {
  local output_mode="$1"
  local result="$2"
  local state_file="${XDG_RUNTIME_DIR}/clipboard-actions-ignore"

  case "$output_mode" in
  copy)
    [[ -z "$result" ]] && return 0

    printf '%s' "$result" >"$state_file"
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
    return 2
    ;;
  esac
}

main() {
  read_clipboard_content

  [[ -z "$content" ]] && return 0
  should_ignore_content && return 0

  local matching_commands
  matching_commands="$(collect_matching_commands)"
  [[ -z "$matching_commands" ]] && return 0

  deduplicate_commands_by_label "$matching_commands"

  local menu_input prompt selection backend
  menu_input="$(make_menu_input)"
  prompt="$(make_prompt)"
  backend="$(choose_menu_backend)" || return $?

  if ! selection="$(show_menu "$backend" "$menu_input" "$prompt")"; then
    # Dismissal/cancellation is not an error; preserve explicit backend config errors.
    [[ "$MENU_BACKEND" != "auto" ]] || return 0
    return 0
  fi

  [[ -z "$selection" ]] && return 0
  run_selected_command "${commands[$selection]}"
}

main "$@"
